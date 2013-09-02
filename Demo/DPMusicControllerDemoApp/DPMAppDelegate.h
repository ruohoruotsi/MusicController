//
//  DPMAppDelegate.h
//  DPMusicControllerDemoApp
//
//  Created by Dan Pourhadi on 2/9/13.
//  Copyright (c) 2013 Dan Pourhadi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeamMinimalExampleProvider.h"

@interface DPMAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BeamMinimalExampleProvider *provider;
@property (strong, nonatomic) UINavigationController *topNavViewController;


@end
