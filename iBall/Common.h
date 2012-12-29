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

#define DEVICE_TYPE_IPHONE3GS 1
#define DEVICE_TYPE_IPHONE4 2
#define DEVICE_TYPE_IPHONE4S 3
#define DEVICE_TYPE_IPHONE5 4
#define DEVICE_TYPE_IPOD 5
#define DEVICE_TYPE_IPAD2 6
#define DEVICE_TYPE_IPADMINI 7

#define DIRECTION_LEFT 1
#define DIRECTION_RIGHT 2
#define DIRECTION_UP 3
#define DIRECTION_DOWN 4

#define BALL_RADIUS 25.0
#define GLES_LINE_WIDTH 16.0

typedef struct _PeerInfor
{
    __unsafe_unretained NSString *peerID;
    GLKMatrix4  transformMatrix;
    CGPoint connectPoint1;
    CGPoint connectPoint2;
}PeerInfor;


#endif
