//
//  AppDelegate.m
//  RSSchool_T8
//
//  Created by Kiryl Kaveryn on 15.07.21.
//

#import "AppDelegate.h"
#import "ArtistViewController.h"
#import "ColorViewController.h"
#import "RSSchool_T8-Swift.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [self rootViewController];
    [self.window makeKeyAndVisible];
    return YES;
}

- (UIViewController *)rootViewController {
    UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController: [ArtistViewController new]];
    return rootViewController;
}

@end
