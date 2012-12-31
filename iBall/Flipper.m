//
//  Flipper.m
//  iBall
//
//  Created by iNghia on 12/31/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "Flipper.h"

@implementation Flipper

@synthesize angleVelocity, flipping, invert;

- (id)initWithAll:(GLKVector3)originPos andDirection:(GLKVector3)direction
{
    self = [super init];
    if (self) {
        flipping = false;
        position = originPos;
                
        if (GLKVector3DotProduct(direction, GLKVector3Make(0.0f, 1.0f, 0.0f)) > 0.0f) {
            invert = true;
            angle = M_PI - FLIPPER_MAX_ANGLE;
            angleVelocity = -FLIPPER_ANGLE_VELOCITY_UP;
        }
        else{
            invert = false;
            angle = FLIPPER_MAX_ANGLE;
            angleVelocity = FLIPPER_ANGLE_VELOCITY_UP;
        }
        
        velocity = GLKVector3Make(0, 0, 0);
        scale = GLKVector3Make(FLIPPER_WIDTH, FLIPPER_LENGTH, 1.0f);
    }
    return self;
}

- (void) flip
{
    if (invert) {
        angle = M_PI - FLIPPER_MAX_ANGLE;
        angleVelocity = -FLIPPER_ANGLE_VELOCITY_UP;
    }
    else
    {
        angle = FLIPPER_MAX_ANGLE;
        angleVelocity = FLIPPER_ANGLE_VELOCITY_UP;
    }
    flipping = true;
}

- (void) update
{
    if (!flipping)
        return;
    
    angle += angleVelocity;
    if (invert) {
        if (angle > M_PI+FLIPPER_MAX_ANGLE)
            angleVelocity = -FLIPPER_ANGLE_VELOCITY_DOWN;
        if (angle < M_PI-FLIPPER_MAX_ANGLE)
        {
            angleVelocity = -FLIPPER_ANGLE_VELOCITY_UP;
            angle = M_PI-FLIPPER_MAX_ANGLE;
            flipping = false;
        }
    }else
    {
        if (angle < -FLIPPER_MAX_ANGLE)
            angleVelocity = FLIPPER_ANGLE_VELOCITY_DOWN;
        if (angle > FLIPPER_MAX_ANGLE)
        {
            angleVelocity = FLIPPER_ANGLE_VELOCITY_UP;
            angle = FLIPPER_MAX_ANGLE;
            flipping = false;
        }
    }
}

- (GLKMatrix4) calculateModelViewMatrix
{
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, position.x, position.y, position.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, angle, 0.0f, 0.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, -FLIPPER_LENGTH/2.0f, 0.0f);
    
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, scale.x, scale.y, scale.z);
    return modelViewMatrix;
}

@end
