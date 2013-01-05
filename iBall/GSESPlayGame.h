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
#import "Barrier.h"
#import "Flipper.h"
#import "MyLine.h"
#import "PeerInfor.h"
#import <AudioToolbox/AudioServices.h>

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
    
    Flipper *leftFlipper;
    Flipper *rightFlipper;
    Ball *leftFlipperController;
    Ball *rightFlipperController;
    
    IBOutlet UILabel *clientScore;
    IBOutlet UIButton *backButton;
    
    float addBallTimer;
    
    // for sound
    SystemSoundID soundId;
}


- (void)setupGL;
- (void)tearDownGL;

- (IBAction) backToMenu:(id)sender;


- (void)screenWasSwiped:(UISwipeGestureRecognizer*)swipe;
- (void)startRecognizationGestures;

- (void)handleCollisionWithFlippers:(Ball*)b;
- (void)handleCollisionWithWall:(Ball*)b;
- (void)handleCollisionWithFlipper:(Flipper *)flipper andBall:(Ball *)b;
- (void)handlePassedBall:(Ball *)b;

- (float)distanceFromBallToFlipper:(Flipper*)f andBall:(Ball*)b;
- (Boolean) canAddNewBall;
@end
