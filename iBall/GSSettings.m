//
//  GSSettings.m
//  iBall
//
//  Created by iNghia on 12/7/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "GSSettings.h"

@implementation GSSettings

+ (void)initialize
{
    NSLog(@"initialize GSSettings");
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    if ([gCommunicationManager isMainDevice])
        [mainDeviceSeg setSelectedSegmentIndex:1];
    else
        [mainDeviceSeg setSelectedSegmentIndex:0];
}

- (IBAction) backToMenu:(id)sender
{
    NSLog(@"Back to menu");
    [m_pManager doStateChange:@"MainMenuStoryboardID"];
}

- (IBAction) connectionSettingsButton:(id)sender
{
    [m_pManager doStateChange:@"ConnectionSettingsStoryboardID"];
}

- (IBAction) changeMainDeviceSeg:(id)sender
{
    if (mainDeviceSeg.selectedSegmentIndex == 0) {
        NSLog(@"IS NOT MAIN DEVICE");
        [gCommunicationManager setIsMainDevice:NO];
    }
    else
    {
        NSLog(@"IS MAIN DEVICE");
        [gCommunicationManager setIsMainDevice:YES];
    }
}

@end
