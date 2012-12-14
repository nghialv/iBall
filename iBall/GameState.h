//
//  GameState.h
//  iBall
//
//  Created by iNghia on 12/7/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameStateManager.h"

@interface GameState : UIViewController {
    GameStateManager* m_pManager;
}

- (void) setGameStateManager:(GameStateManager*)pManager;

@end
