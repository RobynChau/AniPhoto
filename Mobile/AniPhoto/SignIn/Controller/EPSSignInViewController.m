//
//  EPSSignInViewController.m
//  AniPhoto
//
//  Created by PhatCH on 02/02/2024.
//

#import "EPSSignInViewController.h"
#import "EPSUserSessionManager.h"
#import "EPSHomeViewController.h"

#import "AppDelegate.h"
#import "EPSDefines.h"

#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>

@import AppAuth;

@interface EPSSignInViewController ()
@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;
@property (nonatomic, strong) UIButton *signUpButton;
@end

@implementation EPSSignInViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;

        _label1 = [[UILabel alloc] init];
        _label1.text = @"Sign up";
        _label1.textColor = UIColor.labelColor;
        _label1.textAlignment = NSTextAlignmentCenter;
        _label1.font = [UIFont boldSystemFontOfSize:18];
        [self.view addSubview:_label1];

        _label2 = [[UILabel alloc] init];
        _label2.text = @"Join us now! Unlock more features and sync your designs to the cloud for easy access.";
        _label2.textAlignment = NSTextAlignmentCenter;
        _label2.textColor = UIColor.labelColor;
        _label2.numberOfLines = 2;
        _label2.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:_label2];


        _signUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _signUpButton.backgroundColor = UIColor.secondaryLabelColor;
        _signUpButton.layer.cornerRadius = 10.0f;
        [_signUpButton setTitle:@"Sign up with AniPhoto" forState:UIControlStateNormal];
        [_signUpButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_signUpButton addTarget:self action:@selector(signUpButtonPressed) forControlEvents:UIControlEventTouchDown];
        _signUpButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_signUpButton];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemClose
                                             target:self
                                             action:@selector(_closeButtonTapped)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)updateViewConstraints {
    CGSize label1Size = [self.label1.text sizeOfStringWithStyledFont:self.label1.font withSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width * 0.8, CGFLOAT_MAX)];
    CGSize label2Size = [self.label2.text sizeOfStringWithStyledFont:self.label2.font withSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width * 0.8, CGFLOAT_MAX)];
    [self.label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view.mas_safeAreaLayoutGuide).insets(UIEdgeInsetsMake(20, 0, 0, 0));
        make.height.equalTo(@(label1Size.height));
    }];
    [self.label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view.mas_safeAreaLayoutGuide).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        make.top.equalTo(self.label1.mas_bottom).inset(8);
        make.height.equalTo(@(label2Size.height));
    }];
    [self.signUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_safeAreaLayoutGuide);
        make.top.equalTo(self.label2.mas_bottom).inset(16);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(@32);
    }];
    [super updateViewConstraints];
}

- (void)signUpButtonPressed {
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

    // performs authentication request
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.currentAuthorizationFlow = [OIDAuthState
                                            authStateByPresentingAuthorizationRequest:request
                                            presentingViewController:self
                                            callback:^(OIDAuthState *_Nullable authState,
                                                       NSError *_Nullable error) {
        if (authState) {
            [[EPSUserSessionManager shared] signInUserWithAccessToken:authState.lastTokenResponse.accessToken];
            [self deleteWebViewCache];
            [TSHelper dispatchOnMainQueue:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        } else {
            NSLog(@"Authorization error: %@", [error localizedDescription]);
        }
    }];
}

- (void)deleteWebViewCache {
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

- (void)_closeButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
