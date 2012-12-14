//
//  GSSettings.h
//  iBall
//
//  Created by iNghia on 12/7/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"
#import "CommunicationManager.h"

@interface GSSettings : GameState
{
    IBOutlet UISegmentedControl *mainDeviceSeg;
}

- (IBAction) backToMenu:(id)sender;
- (IBAction) connectionSettingsButton:(id)sender;
- (IBAction) changeMainDeviceSeg:(id)sender;

@end
