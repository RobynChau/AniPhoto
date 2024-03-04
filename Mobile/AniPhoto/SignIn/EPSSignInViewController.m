//
//  EPSSignInViewController.m
//  AniPhoto
//
//  Created by PhatCH on 02/02/2024.
//

#import "EPSSignInViewController.h"
#import "AppDelegate.h"
#import "EPSHomeViewController.h"
#import <WebKit/WebKit.h>
#import "UIColor+EPS.h"
@import AppAuth;

@interface EPSSignInViewController ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *signUpButton;
@end

@implementation EPSSignInViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundImageView.image = [UIImage imageNamed:@"signup_background"];
        [self.view addSubview:_backgroundImageView];
        
        _signUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _signUpButton.backgroundColor = UIColor.whiteColor;
        _signUpButton.layer.cornerRadius = 20.0f;
        [_signUpButton setTitle:@"Sign Up With AniPhoto" forState:UIControlStateNormal];
        [_signUpButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_signUpButton addTarget:self action:@selector(signUpButtonPressed) forControlEvents:UIControlEventTouchDown];
        _signUpButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_signUpButton];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
}

- (void)updateViewConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.backgroundImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.backgroundImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.backgroundImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.backgroundImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [self.signUpButton.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
        [self.signUpButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-80],
        [self.signUpButton.widthAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.widthAnchor multiplier:0.7],
        [self.signUpButton.heightAnchor constraintEqualToConstant:50],
    ]];
    [super updateViewConstraints];
}

- (void)signUpButtonPressed {
    NSURL *authorizationEndpoint = [NSURL URLWithString:@"https://keycloak.vohuynh19.info/realms/iOS_AniPhoto/protocol/openid-connect/auth"];
    NSURL *tokenEndpoint = [NSURL URLWithString:@"https://keycloak.vohuynh19.info/realms/iOS_AniPhoto/protocol/openid-connect/token"];
    NSURL *issuer = [NSURL URLWithString:@"https://keycloak.vohuynh19.info/realms/iOS_AniPhoto"];
    NSURL *registrationEndpoint = [NSURL URLWithString:@"https://keycloak.vohuynh19.info/realms/iOS_AniPhoto/clients-registrations/openid-connect"];
    NSURL *endSessionEndpoint = [NSURL URLWithString:@"https://keycloak.vohuynh19.info/realms/iOS_AniPhoto/protocol/openid-connect/logout"];

    OIDServiceConfiguration *configuration = [[OIDServiceConfiguration alloc]
                                              initWithAuthorizationEndpoint:authorizationEndpoint
                                              tokenEndpoint:tokenEndpoint
                                              issuer:issuer
                                              registrationEndpoint:registrationEndpoint
                                              endSessionEndpoint:endSessionEndpoint];

    // perform the auth request...
    OIDAuthorizationRequest *request = [[OIDAuthorizationRequest alloc]
                                        initWithConfiguration:configuration
                                        clientId:@"iOSClient"
                                        clientSecret:@"xZ08Gcpbfu6RJhFefitDBqvV6yGA9i5r"
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
            [self deleteWebViewCache];
            EPSHomeViewController *homeVC = [[EPSHomeViewController alloc] init];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:homeVC];
            navVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navigationController presentViewController:navVC animated:NO completion:nil];
        } else {
            NSLog(@"Authorization error: %@", [error localizedDescription]);
        }
    }];
}

- (void)deleteWebViewCache {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            NSLog(@"Delete Web View Cache Done");
        }];
    });
}

- (void)authenticateWithGoogle {
    NSURL *authorizationEndpoint = [NSURL URLWithString:@"https://accounts.google.com/o/oauth2/auth"];
    NSURL *tokenEndpoint = [NSURL URLWithString:@"https://oauth2.googleapis.com/token"];
    
    OIDServiceConfiguration *configuration = [[OIDServiceConfiguration alloc]
                                              initWithAuthorizationEndpoint:authorizationEndpoint
                                              tokenEndpoint:tokenEndpoint];
    
    // perform the auth request...
    OIDAuthorizationRequest *request = [[OIDAuthorizationRequest alloc]
                                        initWithConfiguration:configuration
                                        clientId:@"766660101034-hfuefc9cg7lqhqn7iri9ukg3esco7ir2.apps.googleusercontent.com"
                                        clientSecret:nil
                                        scopes:@[OIDScopeOpenID, OIDScopeProfile]
                                        redirectURL:[NSURL URLWithString:@"com.googleusercontent.apps.766660101034-hfuefc9cg7lqhqn7iri9ukg3esco7ir2:/oauth2redirect/google"]
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
            NSLog(@"Got authorization tokens. Access token: %@",
                  authState.lastTokenResponse.accessToken);
            //[self setAuthState:authState];
        } else {
            NSLog(@"Authorization error: %@", [error localizedDescription]);
            //[self setAuthState:nil];
        }
    }];
}

@end
