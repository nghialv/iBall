//
//  MyLine.h
//  iBall
//
//  Created by iNghia on 12/29/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGLKVertexAttribArrayBuffer.h"
#import "Common.h"

@interface MyLine : NSObject{
    GLKVector3 startPoint;
    GLKVector3 endPoint;
}


+ (void)enableBuffer;
+ (void)destroyBuffer;

- (id)initWithStartEndPoint:(GLKVector3)pStartPoint andEndPoint:(GLKVector3)pEndPoint;
- (void)changeStartEndPoint:(GLKVector3)pStartPoint andEndPoint:(GLKVector3)pEndPoint;
- (void)draw:(GLKBaseEffect *)effect;

@end
