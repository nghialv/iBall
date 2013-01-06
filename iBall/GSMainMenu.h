//
//  GSMainMenu.h
//  iBall
//
//  Created by iNghia on 12/7/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"
#import <AVFoundation/AVFoundation.h>

@interface GSMainMenu : GameState

@property(nonatomic, retain)AVAudioPlayer *menuBgm;
@property(nonatomic, retain)AVAudioPlayer *buttonSound;

- (IBAction) playGameButton:(id)sender;
- (IBAction) settingsButton:(id)sender;
- (IBAction) aboutButton:(id)sender;

@end
