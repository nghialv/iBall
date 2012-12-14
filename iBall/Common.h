//
//  Common.h
//  iBall
//
//  Created by iNghia on 12/12/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <GLKit/GLKit.h>

#ifndef iBall_Common_h
#define iBall_Common_h


#define MESG_TYPE_CONNECT 1
#define MESG_TYPE_GAME_START 2
#define MESG_TYPE_SEND_BALL 3


#define BALL_RADIUS 40.0

typedef struct _PeerInfor
{
    __unsafe_unretained NSString *peerID;
    GLKMatrix4  transformMatrix;
    CGPoint connectPoint1;
    CGPoint connectPoint2;
}PeerInfor;


#endif
