//
//  AppDelegate.m
//  iBall
//
//  Created by iNghia on 12/12/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "AppDelegate.h"
#import "GameState.h"
#import "GLESGameState.h"
#import "CommunicationManager.h"

@implementation AppDelegate
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [CommunicationManager initialize];
    [gCommunicationManager setDEVICE_WIDTH:window.frame.size.width];
    [gCommunicationManager setDEVICE_HEIGHT:window.frame.size.height];
    
    NSLog(@"DEVICE_WIDTH: %d", gCommunicationManager.DEVICE_WIDTH);
    NSLog(@"DEVICE_HEIGHT: %d", gCommunicationManager.DEVICE_HEIGHT);
    
    if (gCommunicationManager.DEVICE_HEIGHT > 1000)
        [gCommunicationManager setDEVICE_RATIO:200.0/163.0];
    else
        [gCommunicationManager setDEVICE_RATIO:200.0/163.0];
    
    
    [self doStateChange:@"MainMenuStoryboardID"];
    
    return YES;
}

- (void) doStateChange:(NSString*)storyboardId
{
    GameState *newViewController = [window.rootViewController.storyboard instantiateViewControllerWithIdentifier:storyboardId];
    
    [newViewController setGameStateManager:self];
    
    [UIView transitionFromView:self.window.rootViewController.view
                        toView:newViewController.view
                      duration:0.5f
                       options:UIViewAnimationOptionCurveEaseInOut
                    completion:^(BOOL finished){
                        [window.rootViewController removeFromParentViewController];
                        self.window.rootViewController = nil;
                        self.window.rootViewController = newViewController;
                    }];
    
    
    //[window.rootViewController removeFromParentViewController];
    //window.rootViewController = nil;
    
    //window.rootViewController = newViewController;
    //[window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"application did enter backgroud");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"application Will Terminate");
    [gCommunicationManager destroyMySession];
}

@end
