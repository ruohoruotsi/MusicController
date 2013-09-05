//
//  DPMAppDelegate.h
//  DPMusicControllerDemoApp
//
//  Created by Dan Pourhadi on 2/9/13.
//  Copyright (c) 2013 Dan Pourhadi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BeamMusicPlayerViewController;
@class BeamMinimalExampleProvider;
@class MMDrawerController;

@interface DPMAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BeamMinimalExampleProvider *provider;
@property (strong, nonatomic) UINavigationController *topNavViewController;

@property (strong, nonatomic) BeamMusicPlayerViewController* beamAppVC;
@property (strong, nonatomic) MMDrawerController* drawerController;

@end
