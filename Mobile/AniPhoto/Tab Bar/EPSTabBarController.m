//
//  EPSTabBarController.m
//  AniPhoto
//
//  Created by PhatCH on 22/5/24.
//

#import "EPSTabBarController.h"
#import "EPSHomeViewController.h"
#import "EPSProfileViewController.h"

@interface EPSTabBarController ()

@end

@implementation EPSTabBarController

- (instancetype)init {
    self = [super init];
    if (self) {
        EPSHomeViewController *firstVC = [[EPSHomeViewController alloc] init];
        UINavigationController *firstNavVC = [[UINavigationController alloc] initWithRootViewController:firstVC];
        firstNavVC.tabBarItem = [[UITabBarItem alloc]
                                 initWithTitle:@"Home"
                                 image:[UIImage systemImageNamed:@"house"]
                                 tag:0];

        EPSProfileViewController *secondVC = [[EPSProfileViewController alloc] init];
        UINavigationController *secondNavVC = [[UINavigationController alloc] initWithRootViewController:secondVC];
        secondNavVC.tabBarItem = [[UITabBarItem alloc] 
                                  initWithTitle:@"Profile"
                                  image:[UIImage systemImageNamed:@"person"]
                                  tag:1];

        self.viewControllers = @[firstNavVC, secondNavVC];
        self.tabBar.backgroundColor = [UIColor.darkGrayColor colorWithAlphaComponent:0.7];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
