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
#import "EPSUserSessionManager.h"
#import "EPSTabBarController.h"
#import "EPSStoreKitManager.h"
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
    [EPSUserSessionManager.shared initiateUserSession];
    [[EPSStoreKitManager shared] requestAllProducts];

    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithTransparentBackground];
    appearance.backgroundColor = UIColor.clearColor;
    UINavigationBar.appearance.standardAppearance = appearance;
    UINavigationBar.appearance.compactAppearance = appearance;
    UINavigationBar.appearance.scrollEdgeAppearance = appearance;

    UIViewController *vc = [[EPSTabBarController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.tintColor = UIColor.labelColor;
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    return YES;
}


- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([_currentAuthorizationFlow resumeExternalUserAgentFlowWithURL:url]) {
        _currentAuthorizationFlow = nil;
        return YES;
    }
    return NO;
}

- (nonnull ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(nonnull ASWebAuthenticationSession *)session { 
    return UIApplication.sharedApplication.windows.firstObject;
}

@end
