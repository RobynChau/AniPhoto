//
//  AppDelegate.m
//  AniPhoto
//
//  Created by PhatCH on 18/01/2024.
//

#import "AppDelegate.h"

// View Controllers
#import "EPSSignInViewController.h"
#import "EPSHomeViewController.h"
#import "EPSModelOptionSectionViewController.h"
#import "EPSResultWaitingViewController.h"
// Helpers
#import "EPSDefines.h"
#import <FirebaseCore/FirebaseCore.h>

@interface AppDelegate ()
// property of the containing class
@property(nonatomic, strong, nullable) OIDAuthState *authState;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Config Firebase
    [FIRApp configure];
    
    BOOL hasSignedIn = YES;
    
    UIViewController *vc;
    if (!hasSignedIn) {
        vc = [[EPSSignInViewController alloc] init];
    } else {
        vc = [[EPSHomeViewController alloc] init];
    }
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = navVC;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    // Sends the URL to the current authorization flow (if any) which will
    // process it if it relates to an authorization response.
    if ([_currentAuthorizationFlow resumeExternalUserAgentFlowWithURL:url]) {
        _currentAuthorizationFlow = nil;
        return YES;
    }

    // Your additional URL handling (if any) goes here.

    return NO;
}

- (nonnull ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(nonnull ASWebAuthenticationSession *)session { 
    return UIApplication.sharedApplication.windows.firstObject;
}

@end
