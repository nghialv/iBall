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

#define DEVICE_TYPE_IPHONE3GS 0
#define DEVICE_TYPE_IPADMINI 1
#define DEVICE_TYPE_IPHONE4 2
#define DEVICE_TYPE_IPHONE4S 3
#define DEVICE_TYPE_IPHONE5 4
#define DEVICE_TYPE_IPAD2 5
#define DEVICE_TYPE_IPAD4 6

#define DIRECTION_LEFT -1
#define DIRECTION_RIGHT 1
#define DIRECTION_UP 2
#define DIRECTION_DOWN -2

#define BALL_RADIUS 25.0
#define GLES_LINE_WIDTH 5.0

#define RATIO_K 200.0
static float DEVICES_WIDTH[] = {320, 768, 640, 640, 640, 768, 1536};
static float DEVICES_HEIGHT[] = {480, 1024, 960, 960, 1136, 1024, 2048};
static float DEVICES_RATIO[] = {RATIO_K/163.0, RATIO_K/163.0, RATIO_K/326.0, RATIO_K/326.0, RATIO_K/326.0, RATIO_K/132.0, RATIO_K/264.0};

#endif
