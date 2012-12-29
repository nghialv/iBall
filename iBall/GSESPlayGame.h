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
#import "Cube.h"
#import "MyLine.h"

typedef struct _PeerInfor
{
    __unsafe_unretained NSString *peerID;
    GLKMatrix4  transformMatrix;
    __unsafe_unretained MyLine *line;
}PeerInfor;

@interface GSESPlayGame : GLESGameState3D <CommunicationManagerDelegate, UIGestureRecognizerDelegate>
{
    @private
    float SPACE_WIDTH;
    float SPACE_HEIGHT;
    
    NSMutableArray *ballArray;
    NSMutableArray *willRemoveBallArray;
    
    NSMutableArray *readyPeerArray;
    // for position, direction matrix
    CGPoint endPoint;
    
    Cube *cube;
    MyLine *line;
}

- (void)setupGL;
- (void)tearDownGL;

- (IBAction) backToMenu:(id)sender;


- (void)screenWasSwiped:(UISwipeGestureRecognizer*)swipe;
- (void)startRecognizationGestures;

@end
