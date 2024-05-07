//
//  EPSUserSessionManager.m
//  AniPhoto
//
//  Created by PhatCH on 9/5/24.
//

#import "EPSUserSessionManager.h"

#import "EPSDefines.h"
#import "AppDelegate.h"

#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>

@import AppAuth;

@interface EPSUserSessionManager () {
    dispatch_queue_t        _actionQueue;
    const char*             _actionQueueName;
    NSString*               _actionQueueNameStr;
}

@property (nonatomic, copy, readwrite) NSString *deviceID;
@property (nonatomic, copy, readwrite) EPSUserSession *userSession;

@end

@implementation EPSUserSessionManager

+ (EPSUserSessionManager *)shared {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self.class alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _actionQueueNameStr = @"com.PhatCH.AniPhoto.EPSSignInManager";
        _actionQueueName = [_actionQueueNameStr UTF8String];
        _actionQueue = createDispatchQueueWithObject(self, _actionQueueName, YES);
        _deviceID = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] copy];

        NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kUserAccessToken];
        if (IS_NONEMPTY_STRING(accessToken)) {
            _userSession = [[EPSUserSession alloc] initWithAccessToken:accessToken];
        }

        [[NSNotificationCenter defaultCenter] 
         addObserver:self
         selector:@selector(_storeKitDidPurchaseSubscription)
         name:kEPSStoreKitManagerDidFinishPurchaseSubscription
         object:nil];
    }
    return self;
}

- (BOOL)isAuthenticated {
    return self.userSession.isSignedIn;
}

- (void)signInUserWithAccessToken:(NSString *)accessToken {
    if (IS_NONEMPTY_STRING(accessToken)) {
        _userSession = [[EPSUserSession alloc] initWithAccessToken:accessToken];
        [self _saveUserSession];
        [self fetchUserInfo];
        [self fetchUserCredit];
        [self fetchUserSubscription];
    }
}

- (void)signOutUser {
    self.userSession = nil;
    [self _saveUserSession];
    [NSNotificationCenter.defaultCenter postNotificationName:kEPSSignInManagerDidSignOutUser object:nil];
}

- (void)initiateUserSession {
    if (IS_NONEMPTY_STRING(self.userSession.accessToken)) {
        [self fetchUserInfo];
        [self fetchUserCredit];
        [self fetchUserSubscription];
    } else {
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kUserAccessToken];
        NSInteger lastSignInDate = EPSDynamicCast([[NSUserDefaults standardUserDefaults] objectForKey:kUserLastSignInDate], NSNumber).integerValue;
        if (IS_NONEMPTY_STRING(accessToken) && NSDate.date.timeIntervalSince1970 - lastSignInDate < 1 * 24 * 60) {
            self.userSession = [[EPSUserSession alloc] initWithAccessToken:accessToken];
            [self fetchUserInfo];
            [self fetchUserCredit];
            [self fetchUserSubscription];
        }
    }
}

- (void)_saveUserSession {
    NSString *accessToken = self.userSession.accessToken;
    NSInteger lastSignInDate = NSDate.date.timeIntervalSince1970;
    [[NSUserDefaults standardUserDefaults] setObject:accessToken ? accessToken : @"" forKey:kUserAccessToken];
    [[NSUserDefaults standardUserDefaults] setObject:@(lastSignInDate) forKey:kUserLastSignInDate];
}

- (void)fetchUserInfo {
    NSString *urlString = [NSString stringWithFormat:@"%@/user/", kServerEndPointURL];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionConfiguration *sessionConfiguration = [EPSRequestBuilder defaultSessionConfiguration];

    [EPSRequestBuilder dataTaskForURL:url 
                 sessionConfiguration:sessionConfiguration
                          requestType:EPSHTTPRequestTypeGet
                             bodyData:nil
                           completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        if (IS_NONEMPTY_DICT(response)) {
            NSString *firstName = [response eps_stringForKey:@"first_name"];
            NSString *lastName = [response eps_stringForKey:@"last_name"];
            NSString *userID = [response eps_stringForKey:@"id"];
            NSString *userEmail = [response eps_stringForKey:@"email"];
            NSString *userName = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
            [TSHelper dispatchOnMainQueue:^{
                [self.userSession updateWithID:userID name:userName email:userEmail];
                [NSNotificationCenter.defaultCenter postNotificationName:kEPSSignInManagerDidFetchUserInfo object:nil];
            }];
        }
    }];
}

- (void)fetchUserCredit {
    NSString *urlString = [NSString stringWithFormat:@"%@/quotas/total", kServerEndPointURL];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionConfiguration *sessionConfiguration = [EPSRequestBuilder defaultSessionConfiguration];

    [EPSRequestBuilder dataTaskForURL:url
                 sessionConfiguration:sessionConfiguration
                          requestType:EPSHTTPRequestTypeGet
                             bodyData:nil
                           completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        if (IS_NONEMPTY_DICT(response)) {
            [TSHelper dispatchOnMainQueue:^{
                NSInteger totalCreditCount = [response eps_integerForKey:@"total_quota_amount"];
                [self.userSession updateWithTotalCreditCount:totalCreditCount];
                [NSNotificationCenter.defaultCenter postNotificationName:kEPSSignInManagerDidFetchUserCredit object:nil];
            }];
        }
    }];
}

- (void)fetchUserSubscription {
    NSString *urlString = [NSString stringWithFormat:@"%@/subscriptions/active-subscription", kServerEndPointURL];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionConfiguration *sessionConfiguration = [EPSRequestBuilder defaultSessionConfiguration];

    [EPSRequestBuilder dataTaskForURL:url
                 sessionConfiguration:sessionConfiguration
                          requestType:EPSHTTPRequestTypeGet
                             bodyData:nil
                           completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {

        if (IS_NONEMPTY_DICT(response)) {
            [TSHelper dispatchOnMainQueue:^{
                NSString *purchaseDateString = [response eps_stringForKey:@"created_at"];
                NSDate *purchaseDate = [NSDateFormatter.serverParser dateFromString:purchaseDateString];
                NSString *expireDateString = [response eps_stringForKey:@"created_at"];
                NSDate *expireDate = [NSDateFormatter.serverParser dateFromString:expireDateString];
                NSString *subscriptionID = [response eps_stringForKey:@"subscription_id"];
                [self.userSession updateWithSubscriptionID:subscriptionID 
                                              purchaseTime:purchaseDate.timeIntervalSince1970
                                                expireTime:expireDate.timeIntervalSince1970];
                [NSNotificationCenter.defaultCenter postNotificationName:kEPSSignInManagerDidFetchUserSubscription object:nil];
            }];
        }
    }];
}

- (EPSSubscriptionPlanType)getCurrentSubscriptionType {
    if ([self.userSession.currentSubscription.subscriptionID hasPrefix:@"com.PhatCH.AniPhoto.ProPlus"]) {
        return EPSSubscriptionPlanTypeProPlus;
    } else if ([self.userSession.currentSubscription.subscriptionID hasPrefix:@"com.PhatCH.AniPhoto.Pro"]) {
        return EPSSubscriptionPlanTypePro;
    }
    return EPSSubscriptionPlanTypeUnknown;
}

- (EPSSubscriptionPlanType)getPromoteSubscriptionType {
    EPSSubscriptionPlanType currentSubscriptionType = [self getCurrentSubscriptionType];
    switch (currentSubscriptionType) {
        case EPSSubscriptionPlanTypePro:
            return EPSSubscriptionPlanTypeProPlus;
        case EPSSubscriptionPlanTypeProPlus:
            return EPSSubscriptionPlanTypeHide;
        case EPSSubscriptionPlanTypeUnknown:
        default:
            return EPSSubscriptionPlanTypePro;
    }
}

- (void)presentSignInWithViewController:(__kindof UIViewController *)rootVC
                             completion:(nullable void (^)(BOOL success, NSError *_Nullable error))completion {
    if (!rootVC) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"com.PhatCH.AniPhoto.SignInError" code:1 userInfo:nil];
            completion(NO, error);
            return;
        }
    }
    NSURL *authorizationEndpoint = [NSURL URLWithString:@"https://keycloak.vohuynh19.info/realms/ios-entertainment-photography/protocol/openid-connect/auth"];
    NSURL *tokenEndpoint = [NSURL URLWithString:@"https://keycloak.vohuynh19.info/realms/ios-entertainment-photography/protocol/openid-connect/token"];
    NSURL *issuer = [NSURL URLWithString:@"https://keycloak.vohuynh19.info/realms/ios-entertainment-photography"];
    NSURL *registrationEndpoint = [NSURL URLWithString:@"https://keycloak.vohuynh19.info/realms/ios-entertainment-photography/clients-registrations/openid-connect"];
    NSURL *endSessionEndpoint = [NSURL URLWithString:@"https://keycloak.vohuynh19.info/realms/ios-entertainment-photography/protocol/openid-connect/logoutt"];

    OIDServiceConfiguration *configuration = [[OIDServiceConfiguration alloc]
                                              initWithAuthorizationEndpoint:authorizationEndpoint
                                              tokenEndpoint:tokenEndpoint
                                              issuer:issuer
                                              registrationEndpoint:registrationEndpoint
                                              endSessionEndpoint:endSessionEndpoint];

    // perform the auth request...
    OIDAuthorizationRequest *request = [[OIDAuthorizationRequest alloc]
                                        initWithConfiguration:configuration
                                        clientId:@"iOS_AniPhoto"
                                        clientSecret:@"TkYf2zOddqj58mELgXkAIYVmShAobQgm"
                                        scopes:@[OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail]
                                        redirectURL:[NSURL URLWithString:@"aniphoto://login"]
                                        responseType:OIDResponseTypeCode
                                        additionalParameters:nil];

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.currentAuthorizationFlow = [OIDAuthState
                                            authStateByPresentingAuthorizationRequest:request
                                            presentingViewController:rootVC
                                            callback:^(OIDAuthState *_Nullable authState,
                                                       NSError *_Nullable error) {
        if (authState) {
            [self signInUserWithAccessToken:authState.lastTokenResponse.accessToken];
            [self _deleteWebViewCache];
            [TSHelper dispatchOnMainQueue:^{
                if (completion) {
                    completion(YES, nil);
                }
            }];
        } else {
            NSLog(@"Authorization error: %@", [error localizedDescription]);
        }
    }];
}

- (void)_deleteWebViewCache {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 16.0, *)) {
            [SFSafariViewControllerDataStore.defaultDataStore clearWebsiteDataWithCompletionHandler:nil];
        }
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            NSLog(@"Delete Web View Cache Done");
        }];
    });
}

- (void)_storeKitDidPurchaseSubscription {
    [self fetchUserCredit];
    [self fetchUserSubscription];
}

@end
