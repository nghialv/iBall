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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) dealloc
{
    NSLog(@"Dealoc Playgame");
    [ballArray removeAllObjects];
    ballArray = nil;
   
    
    [Ball destroyBuffer];
    [gCommunicationManager setDelegate:nil];
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
    
    GLKVector3 pos = GLKVector3Make(0.0, 0.0, 0.0);
    GLKVector3 vel = GLKVector3Make(2.5, 4.0, 0.0);

    NSLog(@"SETUP GL");
    
    Ball *ball = [[Ball alloc] initWithPosVelRadiTex:pos andVel:vel andRadius:BALL_RADIUS andTex:0];
    [ballArray addObject:ball];
    
    pos.y = -100.0;
    vel.y = -3.0;
    
    Ball *ball2 = [[Ball alloc] initWithPosVelRadiTex:pos andVel:vel andRadius:BALL_RADIUS andTex:1];
    [ballArray addObject:ball2];
    
    pos.y = 200.0;
    vel.y = -4.0;
    
    Ball *ball3 = [[Ball alloc] initWithPosVelRadiTex:pos andVel:vel andRadius:BALL_RADIUS andTex:1];
    [ballArray addObject:ball3];
}

- (void)tearDownGL
{
}

#pragma mark - GLKView and GLKViewController delegate methods
- (void)update
{
    for (Ball *b in ballArray) {
        [b update];
    
        if ((b.position.y + BALL_RADIUS) > SPACE_HEIGHT/2 || (b.position.y -BALL_RADIUS) < -SPACE_HEIGHT/2) {
            [b redictY];
            b.position = GLKVector3Add(b.position,b.velocity);
        }

        if ((b.position.x + BALL_RADIUS) > SPACE_WIDTH/2 || (b.position.x - BALL_RADIUS) < -SPACE_WIDTH/2) {
            [b redictX];
            b.position = GLKVector3Add(b.position,b.velocity);
       
        //[gCommunicationManager sendBallData:position andVelocity:velocity];
        }
    
        
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
                    
                    {  // Update other car's velocity
                        b2.velocity = GLKVector3Subtract(b2Vel,b2Velx);
                        b2.velocity = GLKVector3Add(b2.velocity, bVelx);
                        
                        // update
                        b2.position = GLKVector3Add(b2.position,b2.velocity);
                    }

                    
                }
            }
        }
    }
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0); 
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    
    [Ball enableBuffer];
    
    for (Ball *b in ballArray) {
        [b draw:self.effect];
    }
    
     glEnable(GL_DEPTH_TEST);
}


// CommunicationManagerDelegate
- (void) connectionStatusChanged
{
    
}

- (void) receiveGameStart
{
    
}

- (void) receiveCalibrationData
{
    
}

- (void) receiveNewBall:(GLKVector3)startPosition andVelocity:(GLKVector3)startVelocity
{
    //position.x = position.y = position.z = 0.0;
    //position = startPosition;
    //velocity = startVelocity;
}

// =============================

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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.paused = !self.paused;
}

@end
