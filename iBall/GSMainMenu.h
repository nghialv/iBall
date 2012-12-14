//
//  GSMainMenu.h
//  iBall
//
//  Created by iNghia on 12/7/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"


@interface GSMainMenu : GameState

- (IBAction) playGameButton:(id)sender;
- (IBAction) settingsButton:(id)sender;
- (IBAction) aboutButton:(id)sender;

@end
