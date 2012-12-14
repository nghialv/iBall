//
//  GLESGameState3D.h
//  iBall
//
//  Created by iNghia on 12/7/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "GameStateManager.h"

@interface GLESGameState3D : GLKViewController{
    GameStateManager* m_pManager;
}

@property (strong, nonatomic) EAGLContext   *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void) setGameStateManager:(GameStateManager*)pManager;

- (void)setupGL;
- (void)tearDownGL;

@end
