//
//  Cube.h
//  iBall
//
//  Created by iNghia on 12/29/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGLKVertexAttribArrayBuffer.h"
#import "Entity.h"

@interface Cube : Entity{
    float angle;
}

@property(nonatomic, assign) float angle;

+ (void)enableBuffer;
+ (void)destroyBuffer;

- (id)initWithPosAngLongWidth:(GLKVector3)pos andAngle:(float)ang andLong:(float)l andWidth:(float)w;

- (void)draw:(GLKBaseEffect *)effect;

- (GLKMatrix4) calculateModelViewMatrix;

@end
