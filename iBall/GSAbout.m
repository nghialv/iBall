//
//  GSAbout.m
//  iBall
//
//  Created by iNghia on 12/7/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "GSAbout.h"

@implementation GSAbout

- (IBAction) backToMenu:(id)sender
{
    NSLog(@"Back to menu");
    [m_pManager doStateChange:@"MainMenuStoryboardID"];
}

@end
