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
    
    leftFlipper = nil;
    rightFlipper = nil;
    
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
        PeerInfor *newPeer = [[PeerInfor alloc] initWithAll:peerID andTransformMatrix:matrix andDirection:pDirection andLineStartPoint:sPoint andLineEndPoint:ePoint];
        [readyPeerArray addObject:newPeer];
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
    [Ball addTexture:@"bia.jpeg"];
    [Ball addTexture:@"bia2.jpeg"];
    
    
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
        
        
        //
        //    pos.y = 200.0;
        //    vel.y = -4.0;
        //
        //    Ball *ball3 = [[Ball alloc] initWithPosVelRadiTex:pos andVel:vel andRadius:BALL_RADIUS andTex:1];
        //    [ballArray addObject:ball3];
    }
    
    [Flipper initialize];
    rightFlipper = [[Flipper alloc] initWithAll:GLKVector3Make(0.0f, 200.0f, 0.0f) andDirection:GLKVector3Make(0.0f, -1.0f, 0.0f)];
    
    leftFlipper = [[Flipper alloc] initWithAll:GLKVector3Make(0.0f, -200.0f, 0.0f) andDirection:GLKVector3Make(0.0f, 1.0f, 0.0f)];
    
    [MyLine initialize];
}

- (void)tearDownGL
{
}

- (void)update
{
    //update balls
    for (Ball *b in ballArray) {
        [b update];
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
                    
                    //bool invert;
                    //GLKMatrix4 tmp = GLKMatrix4Invert(p.transformMatrix, &invert);
                    //GLKVector3 newPosition = GLKMatrix4MultiplyVector3WithTranslation(tmp, b.position);
                    //GLKVector3 newVelocity = GLKMatrix4MultiplyVector3WithTranslation(tmp, b.velocity);
                    
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
                    
                    {  // Update own velocity
                        b.velocity = GLKVector3Subtract(bVel,bVelx);
                        b.velocity = GLKVector3Add(b.velocity, b2Velx);
                        
                        // update
                        b.position = GLKVector3Add(b.position,b.velocity);
                    }
                    
                    {  // Update other ball's velocity
                        b2.velocity = GLKVector3Subtract(b2Vel,b2Velx);
                        b2.velocity = GLKVector3Add(b2.velocity, bVelx);
                        
                        // update
                        b2.position = GLKVector3Add(b2.position,b2.velocity);
                    }
                }
            }
        }
    }
    
    [ballArray removeObjectsInArray:willRemoveBallArray];
    [willRemoveBallArray removeAllObjects];
    
    // update Flipper
    [leftFlipper update];
    [rightFlipper update];
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
    
    // draw barrier
    //[Cube enableBuffer];
    //[cube draw:self.effect];
    
    // draw flipper
    if (leftFlipper) {
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
    NSLog(@"TOUCHESBEGAN");
    [leftFlipper flip];
    [rightFlipper flip];
}

@end
