//
//  GSMainMenu.m
//  iBall
//
//  Created by iNghia on 12/7/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "GSMainMenu.h"

@implementation GSMainMenu

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction) playGameButton:(id)sender
{
    [m_pManager doStateChange:@"PlayGameStoryboardID"];
}

- (IBAction) settingsButton:(id)sender
{
    [m_pManager doStateChange:@"SettingsStoryboardID"];
}

- (IBAction) aboutButton:(id)sender
{
    [m_pManager doStateChange:@"AboutStoryboardID"];
}

@end
