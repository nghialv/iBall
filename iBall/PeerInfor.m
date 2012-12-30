//
//  PeerInfor.m
//  iBall
//
//  Created by iNghia on 12/30/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "PeerInfor.h"

@implementation PeerInfor

@synthesize transformMatrix, line, peerId, direction;

- (id)initWithAll:(NSString *)pPeerId andTransformMatrix:(GLKMatrix4)matrix andDirection:(int)pDirection andLineStartPoint:(GLKVector3)sPoint andLineEndPoint:(GLKVector3)ePoint
{
    self = [super init];
    if (self) {
        peerId = pPeerId;
        transformMatrix = matrix;
        direction = pDirection;
        line = [[MyLine alloc] initWithStartEndPoint:sPoint andEndPoint:ePoint];
    }
    return self;
}

@end
