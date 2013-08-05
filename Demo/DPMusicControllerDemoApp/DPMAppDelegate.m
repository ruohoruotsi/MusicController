//
//  DPMAppDelegate.m
//  DPMusicControllerDemoApp
//
//  Created by Dan Pourhadi on 2/9/13.
//  Copyright (c) 2013 Dan Pourhadi. All rights reserved.
//

#import "DPMAppDelegate.h"

@implementation DPMAppDelegate

@synthesize provider;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    BeamMusicPlayerViewController* beamAppVC = nil;

    UINavigationController *tabBar = (UINavigationController *)self.window.rootViewController;
    
    // Are there subviews
    if (tabBar.viewControllers) {
        
        // Iterate through sub viewControllers
        for (UINavigationController *vc in tabBar.viewControllers) {
            
            if ([vc isKindOfClass:[BeamMusicPlayerViewController class]])
                beamAppVC = (BeamMusicPlayerViewController *) vc;
        }
    }
    
    // if we found the VC, then setup the delegate & datasource
    if (beamAppVC) {
        
        provider = [BeamMinimalExampleProvider new];
        
        beamAppVC.delegate = provider;
        beamAppVC.dataSource= provider;
    }
    
    return YES;
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
}

@end
