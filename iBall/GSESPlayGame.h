//
//  GSPlayGame.h
//  iBall
//
//  Created by iNghia on 12/7/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "GLESGameState3D.h"
#import "CommunicationManager.h"
#import "Ball.h"

@interface GSESPlayGame : GLESGameState3D <CommunicationManagerDelegate>
{
    @private
    float SPACE_WIDTH;
    float SPACE_HEIGHT;
    
    NSMutableArray *ballArray;
}

- (void)setupGL;
- (void)tearDownGL;

- (IBAction) backToMenu:(id)sender;

@end
