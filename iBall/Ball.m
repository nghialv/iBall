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

static BOOL initialized = NO;

+ (void)initialize
{
    if (!initialized) {
        initialized = YES;
        
        NSLog(@"INITIALIZE BALL: YES");
        
        // Create vertex buffers containing vertices to draw
        vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                initWithAttribStride:(3 * sizeof(GLfloat))
                                numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat))
                                bytes:sphereVerts
                                usage:GL_STATIC_DRAW];
        vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                              initWithAttribStride:(3 * sizeof(GLfloat))
                              numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat))
                              bytes:sphereNormals
                              usage:GL_STATIC_DRAW];
        vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                    initWithAttribStride:(2 * sizeof(GLfloat))
                                    numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat))
                                    bytes:sphereTexCoords
                                    usage:GL_STATIC_DRAW];
        
        textureInforArray = [[NSMutableArray alloc] init];
    }
}

+ (void)enableBuffer
{
    [vertexPositionBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [vertexNormalBuffer
     prepareToDrawWithAttrib:GLKVertexAttribNormal
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [vertexTextureCoordBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:0
     shouldEnable:YES];
}

+ (void)destroyBuffer
{
    initialized = NO;
    // Delete buffers that aren't needed when view is unloaded
    vertexPositionBuffer = nil;
    vertexNormalBuffer = nil;
    vertexTextureCoordBuffer = nil;
    [textureInforArray removeAllObjects];
    textureInforArray = nil;
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
    [textureInforArray addObject:texInfo];
}

- (id)initWithPosVelRadiTex:(GLKVector3)pos andVel:(GLKVector3)vel andRadius:(float)radius andTex:(int)texIndex
{
    self = [super init];
    if (self) {
        position = pos;
        velocity = vel;
        scale = GLKVector3Make(radius*2, radius*2, radius*2);
        angle = 0;
        if (texIndex > 0)
            textureIndex = texIndex % [textureInforArray count];
        else
            textureIndex = 0;
    }
    return self;
}

- (void)update
{
    position = GLKVector3Add(position, velocity);
    rotationAxis.x = velocity.x;
    rotationAxis.y = velocity.y;
    if ((velocity.x * velocity.y) > 0.0)
        rotationAxis.y = -rotationAxis.y;
    else
        rotationAxis.x = -rotationAxis.x;
    
    rotationAxis.z = 0;
    angle += 2*sqrt(velocity.x*velocity.x+velocity.y*velocity.y)/scale.x;
    
    if (angle > 2*M_PI) {
        angle = 0.0;
    }
}

- (void)draw:(GLKBaseEffect *)effect
{
    GLKTextureInfo *tex = [textureInforArray objectAtIndex:textureIndex];
    effect.texture2d0.name = tex.name;
    effect.texture2d0.target = tex.target;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, position.x, position.y, position.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, angle, rotationAxis.x, rotationAxis.y, rotationAxis.z);
    
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

