//
//  PeerInfor.h
//  iBall
//
//  Created by iNghia on 12/30/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "MyLine.h"

@interface PeerInfor : NSObject{
    NSString *peerId;
    GLKMatrix4  transformMatrix;
    MyLine *line;
}

@property(nonatomic) NSString *peerId;
@property(nonatomic, assign) GLKMatrix4 transformMatrix;
@property(nonatomic) MyLine *line;

- (id)initWithAll:(NSString*)pPeerId andTransformMatrix:(GLKMatrix4)matrix andLineStartPoint:(GLKVector3)sPoint andLineEndPoint:(GLKVector3)ePoint;

@end
