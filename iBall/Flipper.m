//
//  Flipper.m
//  iBall
//
//  Created by iNghia on 12/31/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "Flipper.h"

@implementation Flipper

@synthesize angleVelocity, flipping, invert, modelMatrix;

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

- (void) changeAngleVelocityDirection
{
    if (angleVelocity == FLIPPER_ANGLE_VELOCITY_UP)
        angleVelocity = FLIPPER_ANGLE_VELOCITY_DOWN;
    else if (angleVelocity == -FLIPPER_ANGLE_VELOCITY_UP)
        angleVelocity = -FLIPPER_ANGLE_VELOCITY_DOWN;
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
    modelMatrix = GLKMatrix4Identity;
    
    modelMatrix = GLKMatrix4Translate(modelMatrix, position.x, position.y, position.z);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, angle, 0.0f, 0.0f, 1.0f);
    modelMatrix = GLKMatrix4Translate(modelMatrix, 0.0f, -FLIPPER_LENGTH/2.0f, 0.0f);
    
    modelMatrix = GLKMatrix4Scale(modelMatrix, scale.x, scale.y, scale.z);
    return modelMatrix;
}

- (GLKVector3) getEndPointOfFlipper
{
    return GLKMatrix4MultiplyVector3WithTranslation(modelMatrix, GLKVector3Make(0.0f, -0.5f, 0.0f));
}

- (GLKVector3) getStartPointOfFlipper
{
    return position;
}

-(GLKVector3) getNormalVector
{
    GLKVector3 d = GLKVector3Subtract([self getEndPointOfFlipper], [self getStartPointOfFlipper]);
    d = GLKVector3Normalize(d);
    float tmp = d.x;
    if (angleVelocity < 0.0f) {
        d.x = d.y;
        d.y = -tmp;
    }
    else{
        d.x = -d.y;
        d.y = tmp;
    }
    return d;
}

- (float) getSpeed
{
    if (flipping) {
        return 1.0f;
    }
    else
        return 0.0f;
}

@end
