//
//  GLESGameState3D.m
//  iBall
//
//  Created by iNghia on 12/7/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "GLESGameState3D.h"

@interface GLESGameState3D ()

@end

@implementation GLESGameState3D
@synthesize context = _context;
@synthesize effect = _effect;

#pragma mark - SetGameStateManager
- (void) setGameStateManager:(GameStateManager*)pManager
{
    m_pManager = pManager;
}

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.preferredFramesPerSecond  = 60; // thuc hien 60 frame tren 1 second
    
    [self setupGL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    NSLog(@"GLESGameState3D Dealloc");
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    self.effect = [[GLKBaseEffect alloc] init];
    
    //self.effect.useConstantColor = GL_TRUE;
    //self.effect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    
    //self.effect.light0.enabled = GL_TRUE;
    //self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
}

- (void)tearDownGL
{
    
}

- (void)viewDidUnload
{
    NSLog(@"VIEW DID UNLOAD");
    
    [super viewDidUnload];
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
