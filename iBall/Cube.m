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


- (id)initWithPos:(GLKVector3)pos
{
    self = [super init];
    if (self) {
        position = pos;
        velocity = GLKVector3Make(0, 0, 0);
        scale = GLKVector3Make(100.0, 100.0, 10);
    }
    return self;
}

- (void)update
{
    //position = GLKVector3Add(position, velocity);
}

- (void)draw:(GLKBaseEffect *)effect
{
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, position.x, position.y, position.z);
    
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, scale.x, scale.y, scale.z);
    
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    
    [effect prepareToDraw];
    
    // Draw triangles using vertices in the prepared vertex
    // buffers
    
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLE_STRIP startVertexIndex:0 numberOfVertices:cubeNumVerts];
}

@end
