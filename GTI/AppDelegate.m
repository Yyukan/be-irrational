//
//  AppDelegate.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 01/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"
#import "AppDelegate.h"

#import "ScopeViewController.h"
#import "SomedayViewController.h"
#import "CompletedViewController.h"
#import "TrashViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    ScopeViewController *scopeController = [[[ScopeViewController alloc] init] autorelease];
    UINavigationController *scopeNavigationController=[[[UINavigationController alloc]initWithRootViewController:scopeController] autorelease];

    SomedayViewController *somedayController = [[[SomedayViewController alloc] init] autorelease];
    UINavigationController *somedayNavigationController = [[[UINavigationController alloc] initWithRootViewController:somedayController] autorelease];

    CompletedViewController *completedController = [[[CompletedViewController alloc] init] autorelease];
    UINavigationController *completedNavigationController = [[[UINavigationController alloc] initWithRootViewController:completedController] autorelease];

    
    TrashViewController *trashController = [[[TrashViewController alloc] init] autorelease];
    UINavigationController *trashNavigationController = [[[UINavigationController alloc] initWithRootViewController:trashController] autorelease];

    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:
                                             scopeNavigationController,
                                             somedayNavigationController,
                                             completedNavigationController,
                                             trashNavigationController,
                                             nil];

    [UIUtils setTabBarImage:self.tabBarController.tabBar];
    
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    TRC_ENTRY
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    TRC_ENTRY
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    TRC_ENTRY
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    TRC_ENTRY
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    TRC_ENTRY
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    TRC_ENTRY
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
    TRC_ENTRY
}

@end
