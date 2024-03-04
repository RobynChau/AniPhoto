//
//  AppDelegate.h
//  AniPhoto
//
//  Created by PhatCH on 18/01/2024.
//

#import <UIKit/UIKit.h>
@import AuthenticationServices;
@import AppAuth;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ASWebAuthenticationPresentationContextProviding>

@property (strong, nonatomic) UIWindow * window;

@property(nonatomic, strong) id<OIDExternalUserAgentSession> currentAuthorizationFlow;

@end

