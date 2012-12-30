//
//  MyLine.m
//  iBall
//
//  Created by iNghia on 12/29/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "MyLine.h"


float lineVerts[] = {
    -0.5f, 0.0f, 0.0f,
    0.5f, 0.0f, 0.0f,
};

float lineNormals[] = {
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,
};

float lineColors[] = {
    1.0f, 1.0f, 0.0f, 1.0f,
    1.0f, 1.0f, 0.0f, 1.0f,
};

@implementation MyLine

@synthesize startPoint, endPoint;

static BOOL initialized = NO;
static AGLKVertexAttribArrayBuffer* vertexPositionBuffer;
static AGLKVertexAttribArrayBuffer* vertexNormalBuffer;
static AGLKVertexAttribArrayBuffer * vertexColorBuffer;

+ (void)initialize
{
    if (!initialized) {
        initialized = YES;
        
        NSLog(@"INITIALIZE LINE: YES");
        
        // Create vertex buffers containing vertices to draw
        vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                initWithAttribStride:(3 * sizeof(GLfloat))
                                numberOfVertices:sizeof(lineVerts) / (3 * sizeof(GLfloat))
                                bytes:lineVerts
                                usage:GL_STATIC_DRAW];
//                vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                      initWithAttribStride:(3 * sizeof(GLfloat))
//                                      numberOfVertices:sizeof(lineNormals) / (3 * sizeof(GLfloat))
//                                      bytes:lineNormals
//                                      usage:GL_STATIC_DRAW];
        vertexColorBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                    initWithAttribStride:(4 * sizeof(GLfloat))
                                    numberOfVertices:sizeof(lineColors) / (4 * sizeof(GLfloat))
                                    bytes:lineColors
                                    usage:GL_STATIC_DRAW];
    }
}

+ (void)enableBuffer
{
    [vertexPositionBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    
//    [vertexNormalBuffer
//         prepareToDrawWithAttrib:GLKVertexAttribNormal
//         numberOfCoordinates:3
//         attribOffset:0
//         shouldEnable:YES];
    
    [vertexColorBuffer
     prepareToDrawWithAttrib:GLKVertexAttribColor
     numberOfCoordinates:4
     attribOffset:0
     shouldEnable:YES];
}

+ (void)destroyBuffer
{
    initialized = NO;
    // Delete buffers that aren't needed when view is unloaded
    vertexPositionBuffer = nil;
    vertexNormalBuffer = nil;
    vertexColorBuffer = nil;
}

- (id)initWithStartEndPoint:(GLKVector3)pStartPoint andEndPoint:(GLKVector3)pEndPoint
{
    self = [super init];
    if (self) {
        startPoint = pStartPoint;
        endPoint = pEndPoint;
    }
    return self;
}

- (void)changeStartEndPoint:(GLKVector3)pStartPoint andEndPoint:(GLKVector3)pEndPoint
{
    startPoint = pStartPoint;
    endPoint = pEndPoint;
}

- (void)draw:(GLKBaseEffect *)effect
{
    GLKVector3 line = GLKVector3Subtract(startPoint, endPoint);
    GLKVector3 point = GLKVector3DivideScalar(GLKVector3Add(startPoint, endPoint), 2.0f);
    float length = GLKVector3Length(line);
    line = GLKVector3Normalize(line);
    float angle = acosf(GLKVector3DotProduct(line, GLKVector3Make(1.0f, 0.0f, 0.0f)));
   
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, point.x, point.y, point.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, angle, 0.0f, 0.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, length, 1, 1);

    effect.transform.modelviewMatrix = modelViewMatrix;
    effect.light0.enabled = GL_FALSE;
    
    [effect prepareToDraw];
    
    // Draw triangles using vertices in the prepared vertex
    // buffers
    
    glLineWidth(GLES_LINE_WIDTH);
    
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_LINES startVertexIndex:0 numberOfVertices:2];
    effect.light0.enabled = GL_TRUE;
}

@end
