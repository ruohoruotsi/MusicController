//
//  DPMAppDelegate.m
//  DPMusicControllerDemoApp
//
//  Created by Dan Pourhadi on 2/9/13.
//  Copyright (c) 2013 Dan Pourhadi. All rights reserved.
//

#import "DPMAppDelegate.h"
#import "BeamMusicPlayerViewController.h"
#import "BeamMinimalExampleProvider.h"
#import "MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"


@implementation DPMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    _beamAppVC = nil;
    _topNavViewController = (UINavigationController *)self.window.rootViewController;
    _topNavViewController.navigationBar.topItem.title = @"Albums"; // Initial view
    
    // Are there subviews
    if (_topNavViewController.viewControllers) {                                    // top level navigation
        
        // tabbar should be the only element in this top array
        for (UITabBarController *tabBar in _topNavViewController.viewControllers) { // tabbar
            
            tabBar.delegate = self;                                                 // Assign DPMAppDelegate (self) to be the delegate
            
            // Iterate through tabbar sub viewControllers
            for (UINavigationController *vc in tabBar.viewControllers) {
                
                if ([vc isKindOfClass:[BeamMusicPlayerViewController class]])
                    _beamAppVC = (BeamMusicPlayerViewController*) vc;
            }
        }
    }
    
    // if we found the VC, then setup the delegate & datasource
    if (_beamAppVC) {
        
        _provider = [BeamMinimalExampleProvider new];
        
        _beamAppVC.delegate = _provider;
        _beamAppVC.dataSource= _provider;
    }
    
    
    
    //////////////////////////////////////////////////////////////////
    //
    // setup drawer controller center - left - right
    
    MMDrawerController* drawerController = [[MMDrawerController alloc]
                                            initWithCenterViewController:_topNavViewController //navigationController
                                            leftDrawerViewController:nil    // leftSideDrawerViewController
                                            rightDrawerViewController:nil]; //rightSideDrawerViewController];
    [drawerController setMaximumRightDrawerWidth:200.0];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:drawerController];
    
    
    // Setup Right Button
    MMDrawerBarButtonItem * rightDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(rightDrawerButtonPress:)];
    [_topNavViewController.navigationBar.topItem setRightBarButtonItem:rightDrawerButton animated:YES];

    
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


#pragma mark - UITabBarController delegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSArray *titleArray = @[@"Albums", @"Artists", @"Songs", @"Queue", @"Now Playing", @"Beam"];

    if (viewController == [tabBarController.viewControllers objectAtIndex:0] ) {
     
        // DLog(@"Selected 0 \n");
        _topNavViewController.navigationBar.topItem.title = [titleArray objectAtIndex:0];
    }
    else if (viewController == [tabBarController.viewControllers objectAtIndex:1] ) {
        
        // DLog(@"Selected 1 \n");
        _topNavViewController.navigationBar.topItem.title = [titleArray objectAtIndex:1];
    }
    else if (viewController == [tabBarController.viewControllers objectAtIndex:2] ) {
        
        // DLog(@"Selected 2 \n");
        _topNavViewController.navigationBar.topItem.title = [titleArray objectAtIndex:2];
    }
    else if (viewController == [tabBarController.viewControllers objectAtIndex:3] ) {
        
        // DLog(@"Selected 3 \n");
        _topNavViewController.navigationBar.topItem.title = [titleArray objectAtIndex:3];
    }
    else if (viewController == [tabBarController.viewControllers objectAtIndex:4] ) {
        
        // DLog(@"Selected 4 \n");
        _topNavViewController.navigationBar.topItem.title = [titleArray objectAtIndex:4];
    }
    else if (viewController == [tabBarController.viewControllers objectAtIndex:5] ) {
        
        // DLog(@"Selected 5 \n");
        _topNavViewController.navigationBar.topItem.title = [titleArray objectAtIndex:5];
    }
    
    return YES;
}


#pragma mark - MMDrawerController

-(void)rightDrawerButtonPress:(id)sender {
    [_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

@end
