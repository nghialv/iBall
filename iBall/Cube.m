//
//  Cube.m
//  iBall
//
//  Created by iNghia on 12/29/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "Cube.h"
#import "cubeData.h"


@implementation Cube

@synthesize angle;

static BOOL initialized = NO;
static AGLKVertexAttribArrayBuffer* cubeVertexPositionBuffer;
static AGLKVertexAttribArrayBuffer* cubeVertexNormalBuffer;
static AGLKVertexAttribArrayBuffer* cubeVertexTextureCoordBuffer;

+ (void)initialize
{
    if (!initialized) {
        initialized = YES;
        
        NSLog(@"INITIALIZE CUBE: YES");
        
        // Create vertex buffers containing vertices to draw
        cubeVertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                initWithAttribStride:(3 * sizeof(GLfloat))
                                numberOfVertices:sizeof(cubeVerts) / (3 * sizeof(GLfloat))
                                bytes:cubeVerts
                                usage:GL_STATIC_DRAW];
//        cubeVertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                              initWithAttribStride:(3 * sizeof(GLfloat))
//                              numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat))
//                              bytes:sphereNormals
//                              usage:GL_STATIC_DRAW];
//        cubeVertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                    initWithAttribStride:(2 * sizeof(GLfloat))
//                                    numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat))
//                                    bytes:sphereTexCoords
//                                    usage:GL_STATIC_DRAW];
    }
}

+ (void)enableBuffer
{
    [cubeVertexPositionBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
//    [cubeVertexNormalBuffer
//     prepareToDrawWithAttrib:GLKVertexAttribNormal
//     numberOfCoordinates:3
//     attribOffset:0
//     shouldEnable:YES];
//    [cubeVertexTextureCoordBuffer
//     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
//     numberOfCoordinates:2
//     attribOffset:0
//     shouldEnable:YES];
}

+ (void)destroyBuffer
{
    initialized = NO;
    // Delete buffers that aren't needed when view is unloaded
    cubeVertexPositionBuffer = nil;
    cubeVertexNormalBuffer = nil;
    cubeVertexTextureCoordBuffer = nil;
}


- (id)initWithPosAngLongWidth:(GLKVector3)pos andAngle:(float)ang andLong:(float)l andWidth:(float)w
{
    self = [super init];
    if (self) {
        angle = ang;
        position = pos;
        velocity = GLKVector3Make(0, 0, 0);
        scale = GLKVector3Make(w, l, 1.0f);
    }
    return self;
}

- (GLKMatrix4) calculateModelViewMatrix
{
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, position.x, position.y, position.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, angle, 0.0f, 0.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, scale.x, scale.y, scale.z);
    return modelViewMatrix;
}

- (void)draw:(GLKBaseEffect *)effect
{
    effect.transform.modelviewMatrix = [self calculateModelViewMatrix];
    
    [effect prepareToDraw];
    
    // Draw triangles using vertices in the prepared vertex
    // buffers
    
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLE_STRIP startVertexIndex:0 numberOfVertices:cubeNumVerts];
}

@end
