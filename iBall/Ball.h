//
//  Ball.h
//  iBall
//
//  Created by iNghia on 12/13/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGLKVertexAttribArrayBuffer.h"
#import "Entity.h"

@interface Ball : Entity{
    float angle;
    GLKVector3 rotationAxis;
    int textureIndex;
    
    float minVelocity;
    Boolean resetVelocity;
}

@property Boolean resetVelocity;
@property float minVelocity;
@property int textureIndex;

+ (void)enableBuffer;
+ (void)destroyBuffer;

+ (void)addTexture:(NSString *)imagefile;

- (id)initWithPosVelRadiTex:(GLKVector3)pos andVel:(GLKVector3)vel andRadius:(float)radius andTex:(int)texIndex;
- (void)draw:(GLKBaseEffect *)effect;

- (void)redictX;
- (void)redictY;

- (void)checkResetVelocity;

@end

