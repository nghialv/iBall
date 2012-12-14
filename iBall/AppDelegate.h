//
//  AppDelegate.h
//  iBall
//
//  Created by iNghia on 12/12/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameStateManager.h"

@interface AppDelegate : GameStateManager <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
