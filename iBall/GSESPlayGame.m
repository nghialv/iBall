//
//  GSPlayGame.m
//  iBall
//
//  Created by iNghia on 12/7/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "GSESPlayGame.h"

@interface GSESPlayGame ()
@end

@implementation GSESPlayGame

#pragma mark - Mine
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [gCommunicationManager setDelegate:self];
    
    [self startRecognizationGestures];
    
    
    // for sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"collision-sound" ofType:@"mp3"];
    CFURLRef soundURL = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(soundURL, &soundId);
    
    if ([gCommunicationManager isMainDevice]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"menu-bgm" ofType:@"aif"];
        NSURL *url = [NSURL fileURLWithPath:path];
        self.menuBgm = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.menuBgm.numberOfLoops = -1;
        [self.menuBgm play];
    }
}

- (void) dealloc
{
    NSLog(@"Dealoc Playgame");
    [ballArray removeAllObjects];
    ballArray = nil;
   
    if (willRemoveBallArray) {
        [willRemoveBallArray removeAllObjects];
        willRemoveBallArray = nil;
    }
    
    if (readyPeerArray) {
        [readyPeerArray removeAllObjects];
        readyPeerArray = nil;
    }
    
    // delete flipper
    leftFlipper = nil;
    rightFlipper = nil;
    leftFlipperController = nil;
    rightFlipperController = nil;
    
    [Ball destroyBuffer];
    [Flipper destroyBuffer];
    [MyLine destroyBuffer];
    [gCommunicationManager setDelegate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) backToMenu:(id)sender
{
    NSLog(@"Back to menu");
    [m_pManager doStateChange:@"MainMenuStoryboardID"];
}


#pragma mark - CommunicationManagerDelegate
- (void) connectionStatusChanged
{
    
}

- (void) receiveGameStart
{
    
}

- (void) receiveCalibrationData
{
    
}

- (void) receiveNewBall:(NSString *)peerId andStartPosition:(GLKVector3)startPosition andVelocity:(GLKVector3)startVelocity andTexIndex:(int)texIndex
{
    NSLog(@"REVEIVE BALL");
    PeerInfor *fromPeer;
    for(PeerInfor *p in readyPeerArray)
    {
        if ([p.peerId isEqualToString:peerId]) {
            fromPeer = p;
            break;
        }
    }
    
    GLKVector3 pos = GLKMatrix4MultiplyVector3WithTranslation(fromPeer.transformMatrix, startPosition);
    GLKVector3 ori = GLKMatrix4MultiplyVector3WithTranslation(fromPeer.transformMatrix, GLKVector3Make(0.0f, 0.0f, 0.0f));
    GLKVector3 vel = GLKMatrix4MultiplyVector3WithTranslation(fromPeer.transformMatrix, startVelocity);
    vel = GLKVector3Subtract(vel, ori);
    
    Ball *ball2 = [[Ball alloc] initWithPosVelRadiTex:pos andVel:vel andRadius:BALL_RADIUS andTex:texIndex];
    [ballArray addObject:ball2];
}

- (void) drawConnectionLine:(NSString *)peerID andTransitionMatrix:(GLKMatrix4)matrix andDirection:(int)pDirection andStartPoint:(GLKVector3)sPoint andEndPoint:(GLKVector3)ePoint
{
    BOOL alreadyExit = false;
    for (PeerInfor *p in readyPeerArray)
    {
        if ([p.peerId isEqualToString:peerID]) {
            [p setDirection:pDirection];
            [p setTransformMatrix:matrix];
            [p.line changeStartEndPoint:sPoint andEndPoint:ePoint];
            alreadyExit = true;
        }
    }
    
    if (!alreadyExit) {
        NSLog(@"ADD NEW CONNECTION LINE");
        PeerInfor *newPeer = [[PeerInfor alloc] initWithAll:peerID andTransformMatrix:matrix andDirection:pDirection andLineStartPoint:sPoint andLineEndPoint:ePoint];
        [readyPeerArray addObject:newPeer];
    }
    
    //add Flipper
    if (![gCommunicationManager isMainDevice]) {
        GLKVector3 leftFlipperControllerPos, rightFlipperControllerPos, leftFlipperPos, rightFlipperPos,
                    leftFlipperDirection, rightFlipperDirection;
        
        if (pDirection == DIRECTION_LEFT) {
            leftFlipperControllerPos = GLKVector3Make(50.0f, -SPACE_HEIGHT/2, 0.0f);
            rightFlipperControllerPos = GLKVector3Make(50.0f, SPACE_HEIGHT/2, 0.0f);
            leftFlipperPos = GLKVector3Make(leftFlipperControllerPos.x, leftFlipperControllerPos.y + FLIPPER_CONTROLLER_RAIDUS - 10.0f, 0.0f);
            rightFlipperPos = GLKVector3Make(rightFlipperControllerPos.x, rightFlipperControllerPos.y - FLIPPER_CONTROLLER_RAIDUS + 10.0f, 0.0f);
            leftFlipperDirection = GLKVector3Make(0.0f, 1.0f, 0.0f);
            rightFlipperDirection = GLKVector3Make(0.0f, -1.0f, 0.0f);
        }else
        {
            leftFlipperControllerPos = GLKVector3Make(-50.0f, SPACE_HEIGHT/2, 0.0f);
            rightFlipperControllerPos = GLKVector3Make(-50.0f, -SPACE_HEIGHT/2, 0.0f);
            leftFlipperPos = GLKVector3Make(leftFlipperControllerPos.x, leftFlipperControllerPos.y - FLIPPER_CONTROLLER_RAIDUS + 10.0f, 0.0f);
            rightFlipperPos = GLKVector3Make(rightFlipperControllerPos.x, rightFlipperControllerPos.y + FLIPPER_CONTROLLER_RAIDUS - 10.0f, 0.0f);
            leftFlipperDirection = GLKVector3Make(0.0f, -1.0f, 0.0f);
            rightFlipperDirection = GLKVector3Make(0.0f, 1.0f, 0.0f);
        }
        
        if (leftFlipper) {
            leftFlipperController = [[Ball alloc] initWithPosVelRadiTex:leftFlipperControllerPos andVel:GLKVector3Make(0.0f, 0.0f, 0.0f) andRadius:FLIPPER_CONTROLLER_RAIDUS andTex:0];
            rightFlipperController = [[Ball alloc] initWithPosVelRadiTex:rightFlipperControllerPos andVel:GLKVector3Make(0.0f, 0.0f, 0.0f) andRadius:FLIPPER_CONTROLLER_RAIDUS andTex:0];
            leftFlipper = [[Flipper alloc] initWithAll:leftFlipperPos andDirection:leftFlipperDirection andOriginDirection:pDirection];
            rightFlipper = [[Flipper alloc] initWithAll:rightFlipperPos andDirection:rightFlipperDirection andOriginDirection:pDirection];
        }
        else{
            leftFlipperController = [[Ball alloc] initWithPosVelRadiTex:leftFlipperControllerPos andVel:GLKVector3Make(0.0f, 0.0f, 0.0f) andRadius:FLIPPER_CONTROLLER_RAIDUS andTex:0];
            rightFlipperController = [[Ball alloc] initWithPosVelRadiTex:rightFlipperControllerPos andVel:GLKVector3Make(0.0f, 0.0f, 0.0f) andRadius:FLIPPER_CONTROLLER_RAIDUS andTex:0];
            
            leftFlipper = [[Flipper alloc] initWithAll:leftFlipperPos andDirection:leftFlipperDirection andOriginDirection:pDirection];
            rightFlipper = [[Flipper alloc] initWithAll:rightFlipperPos andDirection:rightFlipperDirection andOriginDirection:pDirection];
        }
    }
    
    // edit score label and back button
    if (pDirection == DIRECTION_LEFT) {
        CGAffineTransform trans = CGAffineTransformMakeTranslation(gCommunicationManager.DEVICE_WIDTH/2.0f - 40.0f, gCommunicationManager.DEVICE_HEIGHT/2.0f);
        [clientScore setTransform:CGAffineTransformRotate(trans, -M_PI_2)];
        
        trans = CGAffineTransformMakeTranslation(0.0f, gCommunicationManager.DEVICE_HEIGHT - 70.0f);
        [backButton setTransform:CGAffineTransformRotate(trans, -M_PI_2)];
    }
    else
    {
        CGAffineTransform trans = CGAffineTransformMakeTranslation(-gCommunicationManager.DEVICE_WIDTH/2.0f + 40.0f, gCommunicationManager.DEVICE_HEIGHT/2.0f);
        [clientScore setTransform:CGAffineTransformRotate(trans, M_PI_2)];
        
        trans = CGAffineTransformMakeTranslation(gCommunicationManager.DEVICE_WIDTH - 70.0f, 0.0f);
        [backButton setTransform:CGAffineTransformRotate(trans, M_PI_2)];
    }
}

#pragma mark - GLESGameState3D
- (void)configureLight
{
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(
                                                     1.0f, // Red
                                                     1.0f, // Green
                                                     1.0f, // Blue
                                                     1.0f);// Alpha
    self.effect.light0.position = GLKVector4Make(
                                                 1.0f,
                                                 0.0f,
                                                 -0.8f,
                                                 0.0f);
    self.effect.light0.ambientColor = GLKVector4Make(
                                                     0.2f, // Red
                                                     0.2f, // Green
                                                     0.2f, // Blue
                                                     1.0f);// Alpha
}

- (void)setupGL
{
    [super setupGL];
    
    [self configureLight];
    
    //set up ProjectionMatrix
    
    SPACE_WIDTH = gCommunicationManager.DEVICE_WIDTH*gCommunicationManager.DEVICE_RATIO;
    SPACE_HEIGHT = gCommunicationManager.DEVICE_HEIGHT*gCommunicationManager.DEVICE_RATIO;
    
    NSLog(@"SPACE_WIDTH: %f", SPACE_WIDTH);
    NSLog(@"SPACE_HEIGHT: %f", SPACE_HEIGHT);
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-SPACE_WIDTH/2, SPACE_WIDTH/2, -SPACE_HEIGHT/2, SPACE_HEIGHT/2, 1000000, -1);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // Ball initilization
    [Ball initialize];
    
    // Add texture for ball
    [Ball addTexture:@"ball-sasuke-white.png"];
    [Ball addTexture:@"ball-kakashi-green.png"];
    [Ball addTexture:@"ball-kakashi-orange.png"];
    [Ball addTexture:@"ball-kakashi-red.png"];
    [Ball addTexture:@"ball-kakashi-yellow.png"];
    
    if (![gCommunicationManager isMainDevice]) {
        [Flipper initialize];
    }
    
    [MyLine initialize];
    
    
    ballArray = [[NSMutableArray alloc] init];
    willRemoveBallArray = [[NSMutableArray alloc] init];
    readyPeerArray = [[NSMutableArray alloc] init];
    
    if ([gCommunicationManager isMainDevice])
    {
        GLKVector3 pos = GLKVector3Make(0.0, 0.0, 0.0);
        GLKVector3 vel = GLKVector3Make(5.5, 6.5, 0.0);
    
        NSLog(@"SETUP GL");
    
        Ball *ball = [[Ball alloc] initWithPosVelRadiTex:pos andVel:vel andRadius:BALL_RADIUS andTex:0];
        [ballArray addObject:ball];
    
        
        pos.y = -100.0;
        vel.y = -6.5;
    
        Ball *ball2 = [[Ball alloc] initWithPosVelRadiTex:pos andVel:vel andRadius:BALL_RADIUS andTex:1];
        [ballArray addObject:ball2];
        
        
        pos.y = 200.0;
        vel.y = -4.0;
        
        Ball *ball3 = [[Ball alloc] initWithPosVelRadiTex:pos andVel:vel andRadius:BALL_RADIUS andTex:2];
        [ballArray addObject:ball3];
    }
    
    addBallTimer = 0.0f;
}

- (void)tearDownGL
{
}

- (void)update
{
    //update balls
    for (Ball *b in ballArray) {
        [b update];
      
        //handle passedball
        [self handlePassedBall:b];
        
        //check and handle collsion with flipper and flipperController
        [self handleCollisionWithFlippers:b];
                
        //check collision with wall
        [self handleCollisionWithWall:b];
                
        // check collision with other ball
        for (Ball *b2 in ballArray) {
            if (b != b2) {
                float distance = GLKVector3Distance(b.position, b2.position);
                if ((2.0f*BALL_RADIUS) > distance) {
                    GLKVector3 bVel = b.velocity;
                    GLKVector3 b2Vel = b2.velocity;
                    GLKVector3 directionBtoB2 = GLKVector3Subtract(b2.position,b.position);
                    
                    directionBtoB2 = GLKVector3Normalize(directionBtoB2);
                    GLKVector3 directionB2toB = GLKVector3Negate(directionBtoB2);
                    
                    GLKVector3 bVelx = GLKVector3MultiplyScalar(directionBtoB2, GLKVector3DotProduct(bVel, directionBtoB2));
                    
                    GLKVector3 b2Velx = GLKVector3MultiplyScalar(directionB2toB, GLKVector3DotProduct(b2Vel, directionB2toB));
                    
                    // Update own velocity
                        b.velocity = GLKVector3Subtract(bVel,bVelx);
                        b.velocity = GLKVector3Add(b.velocity, b2Velx);
                    
                    // Update other ball's velocity
                        b2.velocity = GLKVector3Subtract(b2Vel,b2Velx);
                        b2.velocity = GLKVector3Add(b2.velocity, bVelx);
                        
                    // update position
                    //b2.position = GLKVector3Add(b.position, GLKVector3MultiplyScalar(directionBtoB2, BALL_RADIUS));
                    b.position = GLKVector3Add(b.position,b.velocity);
                    b2.position = GLKVector3Add(b2.position,b2.velocity);
                }
            }
        }
    }
    
    [ballArray removeObjectsInArray:willRemoveBallArray];
    [willRemoveBallArray removeAllObjects];
    
    [leftFlipperController update];
    [rightFlipperController update];
    
    // update Flipper
    if (![gCommunicationManager isMainDevice]) {
        [leftFlipper update];
        [rightFlipper update];
    }
    
    
    // add newball
    if ([gCommunicationManager isMainDevice]) {
        addBallTimer += self.timeSinceLastUpdate;
        if (addBallTimer > 0.8f && [self canAddNewBall]) {
            if ([ballArray count] < BALL_MAX_NUM) {
                GLKVector3 pos = GLKVector3Make(0.0, 0.0, 0.0);
                GLKVector3 vel = GLKVector3Make(5.5, 6.5, 0.0);
                
                int tex = rand()%BALL_TEXTURE_NUM;
                Ball *ball = [[Ball alloc] initWithPosVelRadiTex:pos andVel:vel andRadius:BALL_RADIUS andTex:tex];
                [ballArray addObject:ball];
            }
            addBallTimer = 0.0f;
        }
    }
}

- (Boolean) canAddNewBall
{
    for (Ball *b in ballArray)
    {
        if (GLKVector3Distance(b.position, GLKVector3Make(0.0f, 0.0f, 0.0f)) < BALL_RADIUS*2.5f)
            return false;
    }
    return true;
}

- (void)handleCollisionWithFlippers:(Ball *)b
{
    if ([gCommunicationManager isMainDevice])
        return;
    
    if (leftFlipperController) {
        if (GLKVector3Distance(b.position, leftFlipperController.position) < BALL_RADIUS + FLIPPER_CONTROLLER_RAIDUS) {
            GLKVector3 bVel = b.velocity;
            
            GLKVector3 directionBtoB2 = GLKVector3Subtract(leftFlipperController.position,b.position);
            directionBtoB2 = GLKVector3Normalize(directionBtoB2);
            
            GLKVector3 bVelx = GLKVector3MultiplyScalar(directionBtoB2, GLKVector3DotProduct(bVel, directionBtoB2));
            bVelx = GLKVector3MultiplyScalar(bVelx, -2.0f);
            
            // Update own velocity
            b.velocity = GLKVector3Add(b.velocity, bVelx);
            
            // update
            b.position = GLKVector3Add(b.position,b.velocity);
        }
    }
    
    if (rightFlipperController) {
        if (GLKVector3Distance(b.position, rightFlipperController.position) < BALL_RADIUS + FLIPPER_CONTROLLER_RAIDUS) {
            GLKVector3 bVel = b.velocity;
            
            GLKVector3 directionBtoB2 = GLKVector3Subtract(rightFlipperController.position,b.position);
            directionBtoB2 = GLKVector3Normalize(directionBtoB2);
            
            GLKVector3 bVelx = GLKVector3MultiplyScalar(directionBtoB2, GLKVector3DotProduct(bVel, directionBtoB2));
            bVelx = GLKVector3MultiplyScalar(bVelx, -2.0f);
            
            // Update own velocity
            b.velocity = GLKVector3Add(b.velocity, bVelx);
            
            // update
            b.position = GLKVector3Add(b.position,b.velocity);
        }
    }
    
    // check collision with flipper
    [self handleCollisionWithFlipper:leftFlipper andBall:b];
    [self handleCollisionWithFlipper:rightFlipper andBall:b];
}

- (void) handleCollisionWithFlipper:(Flipper *)flipper andBall:(Ball *)b
{
    GLKVector3 flipperCenterPoint = [flipper getCenterPointOfFlipper];
    float d2 = GLKVector3Distance(flipperCenterPoint, b.position);
    float delta = BALL_RADIUS + FLIPPER_WIDTH/2 - [self distanceFromBallToFlipper:flipper andBall:b];
    
    if (delta >= 0.0f && d2 < (FLIPPER_LENGTH+BALL_RADIUS/2.0f)/2.0f) {
        
        //play sound
        AudioServicesPlaySystemSound(soundId);
        
        GLKVector3 bVel = b.velocity;
        
        GLKVector3 flipperVel = [flipper getNormalVector];
        GLKVector3 directionBtoB2 = GLKVector3MultiplyScalar(flipperVel, -1.0f);
        
        GLKVector3 bVelx = GLKVector3MultiplyScalar(directionBtoB2, GLKVector3DotProduct(bVel, directionBtoB2));
        bVelx = GLKVector3MultiplyScalar(bVelx, -2.0f);
    
        
        // Update own velocity
        b.velocity = GLKVector3Add(b.velocity, bVelx);
        NSLog(@"Flipper velocity: %f", [flipper getSpeed]);
        b.minVelocity = GLKVector3Length(b.velocity);
        b.acceleration = GLKVector3MultiplyScalar(flipperVel, -[flipper getSpeed]/10.0f);
        b.resetVelocity = true;
        b.velocity = GLKVector3Add(b.velocity, GLKVector3MultiplyScalar(flipperVel, [flipper getSpeed]));
        
        // update position
        b.position = GLKVector3Add(b.position, GLKVector3MultiplyScalar(flipperVel, delta));
        b.position = GLKVector3Add(b.position,b.velocity);
        //[flipper changeAngleVelocityDirection];
    }
}

- (float) distanceFromBallToFlipper:(Flipper *)f andBall:(Ball *)b
{
    GLKVector3 flipperStartPoint = [f getStartPointOfFlipper];
    GLKVector3 flipperEndPoint = [f getEndPointOfFlipper];
    float A = flipperEndPoint.y - flipperStartPoint.y;
    float B = flipperStartPoint.x - flipperEndPoint.x;
    float C = flipperEndPoint.x * flipperStartPoint.y - flipperStartPoint.x * flipperEndPoint.y;
    
    return abs(A*b.position.x + B*b.position.y + C)/sqrtf(powf(A, 2)+powf(B, 2));
}

- (void)handlePassedBall:(Ball *)b
{
    if ([gCommunicationManager isMainDevice])
        return;
    if ([[readyPeerArray objectAtIndex:0] direction] == DIRECTION_LEFT) {
        if ((b.position.x + BALL_RADIUS) > SPACE_WIDTH/2)
        {
            int num = [clientScore.text intValue] + 1;
            clientScore.text = [[NSString alloc] initWithFormat:@"%d",num];
            [willRemoveBallArray addObject:b];
        }
    }
    else
    {
        if ((b.position.x - BALL_RADIUS) < -SPACE_WIDTH/2)
        {
            int num = [clientScore.text intValue] + 1;
            clientScore.text = [[NSString alloc] initWithFormat:@"%d",num];
            [willRemoveBallArray addObject:b];
        }
    }
}

- (void)handleCollisionWithWall:(Ball *)b
{
    Boolean send = false;
    float cosXVel = GLKVector3DotProduct(b.velocity, GLKVector3Make(1.0f, 0.0f, 0.0f));
    float cosYVel = GLKVector3DotProduct(b.velocity, GLKVector3Make(0.0f, 1.0f, 0.0f));
    
    // up
    if ((b.position.y + BALL_RADIUS) > SPACE_HEIGHT/2 && cosYVel > 0)
    {
        NSLog(@"UP");
        for (PeerInfor *p in readyPeerArray)
        {
            if (p.direction == DIRECTION_UP && b.position.x < p.line.startPoint.x && b.position.x > p.line.endPoint.x) {
                NSLog(@"SEND ball");
                
                [b checkResetVelocity];
                
                [gCommunicationManager sendBallData:p.peerId andStartPosition:b.position andVelocity:b.velocity andTexIndex:b.textureIndex];
                [willRemoveBallArray addObject:b];
                
                send = true;
            }
        }
        
        if (!send) {
            [b redictY];
            b.position = GLKVector3Add(b.position,b.velocity);
        }
    }
    
    // down
    if ((b.position.y -BALL_RADIUS) < -SPACE_HEIGHT/2 && cosYVel < 0)
    {
        for (PeerInfor *p in readyPeerArray)
        {
            if (p.direction == DIRECTION_DOWN && b.position.x < p.line.startPoint.x && b.position.x > p.line.endPoint.x) {
                NSLog(@"SEND ball");
                
                [b checkResetVelocity];
                
                [gCommunicationManager sendBallData:p.peerId andStartPosition:b.position andVelocity:b.velocity andTexIndex:b.textureIndex];
                [willRemoveBallArray addObject:b];
                
                send = true;
            }
        }
        
        if (!send) {
            [b redictY];
            b.position = GLKVector3Add(b.position,b.velocity);
        }
    }
    
    //left
    if ((b.position.x - BALL_RADIUS) < -SPACE_WIDTH/2 && cosXVel < 0)
    {
        for (PeerInfor *p in readyPeerArray)
        {
            if (p.direction == DIRECTION_LEFT && b.position.y < p.line.startPoint.y && b.position.y > p.line.endPoint.y) {
                NSLog(@"SEND ball");
                
                [b checkResetVelocity];
                
                [gCommunicationManager sendBallData:p.peerId andStartPosition:b.position andVelocity:b.velocity andTexIndex:b.textureIndex];
                [willRemoveBallArray addObject:b];
                
                send = true;
            }
        }
        
        if (!send) {
            [b redictX];
            b.position = GLKVector3Add(b.position,b.velocity);
        }
    }
    
    //right
    if ((b.position.x + BALL_RADIUS) > SPACE_WIDTH/2 && cosXVel > 0)
    {
        for (PeerInfor *p in readyPeerArray)
        {
            if (p.direction == DIRECTION_RIGHT && b.position.y < p.line.startPoint.y && b.position.y > p.line.endPoint.y) {
                NSLog(@"SEND ball");
                
                [b checkResetVelocity];
                
                [gCommunicationManager sendBallData:p.peerId andStartPosition:b.position andVelocity:b.velocity andTexIndex:b.textureIndex];
                [willRemoveBallArray addObject:b];
                
                send = true;
            }
        }
        
        if (!send) {
            [b redictX];
            b.position = GLKVector3Add(b.position,b.velocity);
        }
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    // draw ball
    [Ball enableBuffer];
    
    for (Ball *b in ballArray) {
        [b draw:self.effect];
    }
    
    
    [leftFlipperController draw:self.effect];
    [rightFlipperController draw:self.effect];
    
    // draw barrier
    //[Cube enableBuffer];
    //[cube draw:self.effect];
    
    // draw flipper
    if (![gCommunicationManager isMainDevice] && leftFlipper) {
        [Flipper enableBuffer];
        [leftFlipper draw:self.effect];
        [rightFlipper draw:self.effect];
    }
    
    //draw connection line
    [MyLine enableBuffer];
    for (PeerInfor *p in readyPeerArray)
    {
        [p.line draw:self.effect];
    }
    
    glEnable(GL_DEPTH_TEST);
}

#pragma mark - Gesture
- (void)startRecognizationGestures
{
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenWasSwiped:)];
    swipeUp.numberOfTouchesRequired = 1;
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenWasSwiped:)];
    swipeDown.numberOfTouchesRequired = 1;
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenWasSwiped:)];
    swipeLeft.numberOfTouchesRequired = 1;
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenWasSwiped:)];
    swipeRight.numberOfTouchesRequired = 1;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}

- (void)screenWasSwiped:(UISwipeGestureRecognizer *)swipe
{
    switch (swipe.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            endPoint.x = 0;
            [gCommunicationManager sendCalibrationData:endPoint andDirection:DIRECTION_LEFT];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            endPoint.x = gCommunicationManager.DEVICE_WIDTH;
            [gCommunicationManager sendCalibrationData:endPoint andDirection:DIRECTION_RIGHT];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            endPoint.y = 0;
            [gCommunicationManager sendCalibrationData:endPoint andDirection:DIRECTION_UP];
            break;
        case UISwipeGestureRecognizerDirectionDown:
            endPoint.y = gCommunicationManager.DEVICE_HEIGHT;
            [gCommunicationManager sendCalibrationData:endPoint andDirection:DIRECTION_DOWN];
            break;
        default:
            break;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    endPoint = [touch locationInView:self.view];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //self.paused = !self.paused;
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self.view];
    GLKVector3 touchedPoint = [gCommunicationManager convertCoordinationTo3D:p];
    
    if (GLKVector3Distance(touchedPoint, leftFlipperController.position) < FLIPPER_CONTROLLER_RAIDUS) {
        [leftFlipper flip];
    }
    if (GLKVector3Distance(touchedPoint, rightFlipperController.position) < FLIPPER_CONTROLLER_RAIDUS) {
        [rightFlipper flip];
    }
}

@end
