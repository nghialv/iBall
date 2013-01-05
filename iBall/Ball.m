//
//  Ball.m
//  iBall
//
//  Created by iNghia on 12/13/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "Ball.h"
#import "sphere.h"


@implementation Ball

@synthesize textureIndex, minVelocity, resetVelocity;

static BOOL initialized = NO;
static AGLKVertexAttribArrayBuffer* ballVertexPositionBuffer;
static AGLKVertexAttribArrayBuffer* ballVertexNormalBuffer;
static AGLKVertexAttribArrayBuffer* ballVertexTextureCoordBuffer;
static NSMutableArray* ballTextureInforArray;

+ (void)initialize
{
    if (!initialized) {
        initialized = YES;
        
        NSLog(@"INITIALIZE BALL: YES");
        
        // Create vertex buffers containing vertices to draw
        ballVertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                initWithAttribStride:(3 * sizeof(GLfloat))
                                numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat))
                                bytes:sphereVerts
                                usage:GL_STATIC_DRAW];
        ballVertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                              initWithAttribStride:(3 * sizeof(GLfloat))
                              numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat))
                              bytes:sphereNormals
                              usage:GL_STATIC_DRAW];
        ballVertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                    initWithAttribStride:(2 * sizeof(GLfloat))
                                    numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat))
                                    bytes:sphereTexCoords
                                    usage:GL_STATIC_DRAW];
        
        ballTextureInforArray = [[NSMutableArray alloc] init];
    }
}

+ (void)enableBuffer
{
    [ballVertexPositionBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [ballVertexNormalBuffer
     prepareToDrawWithAttrib:GLKVertexAttribNormal
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [ballVertexTextureCoordBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:0
     shouldEnable:YES];
}

+ (void)destroyBuffer
{
    initialized = NO;
    // Delete buffers that aren't needed when view is unloaded
    ballVertexPositionBuffer = nil;
    ballVertexNormalBuffer = nil;
    ballVertexTextureCoordBuffer = nil;
    [ballTextureInforArray removeAllObjects];
    ballTextureInforArray = nil;
}

+ (void)addTexture:(NSString *)imagefile
{
    CGImageRef imageRef = [[UIImage imageNamed:imagefile] CGImage];
    
    GLKTextureInfo *texInfo = [GLKTextureLoader
                   textureWithCGImage:imageRef
                   options:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],
                            GLKTextureLoaderOriginBottomLeft, nil]
                   error:NULL];
    [ballTextureInforArray addObject:texInfo];
}

- (id)initWithPosVelRadiTex:(GLKVector3)pos andVel:(GLKVector3)vel andRadius:(float)radius andTex:(int)texIndex
{
    self = [super init];
    if (self) {
        position = pos;
        velocity = vel;
        acceleration = GLKVector3Make(0.0f, 0.0f, 0.0f);
        scale = GLKVector3Make(radius*2, radius*2, radius*2);
        rotationAxis = GLKVector3Make(0.0f, 0.0f, 1.0f);
        angle = 0;
        resetVelocity = false;
    
        if (texIndex > 0)
            textureIndex = texIndex % [ballTextureInforArray count];
        else
            textureIndex = 0;
    }
    return self;
}

- (void)update
{
    if (GLKVector3Length(velocity) < minVelocity){
        acceleration.x = acceleration.y = acceleration.z = 0.0f;
    }
    
    velocity = GLKVector3Add(velocity, acceleration);
    position = GLKVector3Add(position, velocity);
    rotationAxis.x = velocity.x;
    rotationAxis.y = velocity.y;
    if ((velocity.x * velocity.y) > 0.0)
        rotationAxis.y = -rotationAxis.y;
    else
        rotationAxis.x = -rotationAxis.x;
    
    rotationAxis.z = 0.0f;
    
    angle += 2*sqrt(velocity.x*velocity.x+velocity.y*velocity.y)/scale.x;
    
    if (angle > 2*M_PI) {
        angle = 0.0;
    }
}

- (void) checkResetVelocity
{
    if (resetVelocity) {
        if (minVelocity > BALL_MAX_VELOCITY)
            minVelocity = BALL_MAX_VELOCITY;
        velocity = GLKVector3MultiplyScalar(GLKVector3Normalize(velocity), minVelocity);
        acceleration.x = acceleration.y = acceleration.z = 0.0f;
        resetVelocity = false;
    }
}

- (void)draw:(GLKBaseEffect *)effect
{
    GLKTextureInfo *tex = [ballTextureInforArray objectAtIndex:textureIndex];
    effect.texture2d0.name = tex.name;
    effect.texture2d0.target = tex.target;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, position.x, position.y, position.z);
    if (GLKVector3Length(velocity) != 0) {
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, angle, rotationAxis.x, rotationAxis.y, rotationAxis.z);
    }
    
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, scale.x, scale.y, scale.z);

    
    effect.transform.modelviewMatrix = modelViewMatrix;
    
    [effect prepareToDraw];
    
    // Draw triangles using vertices in the prepared vertex
    // buffers
    
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
}


- (void)redictX
{
    velocity.x = -velocity.x;
}

- (void)redictY
{
    velocity.y = -velocity.y;
}

@end

