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
    
}

+ (void)enableBuffer;
+ (void)destroyBuffer;

- (id)initWithPos:(GLKVector3)pos;

- (void)draw:(GLKBaseEffect *)effect;

@end
