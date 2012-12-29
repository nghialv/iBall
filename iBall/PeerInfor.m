//
//  PeerInfor.m
//  iBall
//
//  Created by iNghia on 12/30/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "PeerInfor.h"

@implementation PeerInfor

@synthesize transformMatrix, line, peerId;

- (id)initWithAll:(NSString *)pPeerId andTransformMatrix:(GLKMatrix4)matrix andLineStartPoint:(GLKVector3)sPoint andLineEndPoint:(GLKVector3)ePoint
{
    self = [super init];
    if (self) {
        peerId = pPeerId;
        transformMatrix = matrix;
        line = [[MyLine alloc] initWithStartEndPoint:sPoint andEndPoint:ePoint];
    }
    return self;
}

@end
