//
//  Entity.h
//  iBall
//
//  Created by iNghia on 12/13/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Common.h"

@interface Entity : NSObject{
    GLKVector3 position;
    GLKVector3 velocity;
    GLKVector3 acceleration;
    GLKVector3 scale;
}

@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) GLKVector3 velocity;
@property (nonatomic, assign) GLKVector3 acceleration;
@property (nonatomic, assign) GLKVector3 scale;

- (void)update;

@end
