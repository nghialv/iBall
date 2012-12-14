//
//  GLESGameState.h
//  Test_Framework
//
//  Created by Joe Hogue on 4/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "GameState.h"

@interface GLESGameState : GLKViewController{
    GameStateManager* m_pManager;
}

- (void) setGameStateManager:(GameStateManager*)pManager;

@end
