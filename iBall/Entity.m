//
//  Entity.m
//  iBall
//
//  Created by iNghia on 12/13/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "Entity.h"

@implementation Entity
@synthesize position, velocity, acceleration, scale;

- (void)update
{
    velocity = GLKVector3Add(velocity, acceleration);
    position = GLKVector3Add(position, velocity);
}

@end
