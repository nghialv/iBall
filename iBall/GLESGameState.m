//
//  GLESGameState.m
//  Test_Framework
//
//  Created by Joe Hogue on 4/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLESGameState.h"
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>

@implementation GLESGameState

- (void) setGameStateManager:(GameStateManager*)pManager
{
    m_pManager = pManager;
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
