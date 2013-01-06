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

- (void)viewDidAppear:(BOOL)animated{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"menu-bgm" ofType:@"aif"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.menuBgm = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.menuBgm.numberOfLoops = -1;
    [self.menuBgm play];
    
    path = [[NSBundle mainBundle] pathForResource:@"button-sound" ofType:@"aif"];
    url = [NSURL fileURLWithPath:path];
    self.buttonSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
}

- (IBAction) playGameButton:(id)sender
{
    [self.buttonSound play];
    [m_pManager doStateChange:@"PlayGameStoryboardID"];
}

- (IBAction) settingsButton:(id)sender
{
    [self.buttonSound play];
    [m_pManager doStateChange:@"SettingsStoryboardID"];
}

- (IBAction) aboutButton:(id)sender
{
    [self.buttonSound play];
    [m_pManager doStateChange:@"AboutStoryboardID"];
}

@end
