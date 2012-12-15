//
//  CommunicationManager.h
//  iBall
//
//  Created by iNghia on 12/12/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import <GLKit/GLKit.h>
#import "Common.h"

@class CommunicationManager;

@protocol CommunicationManagerDelegate <NSObject>
    - (void)connectionStatusChanged;

    - (void)receiveGameStart;
    - (void)receiveCalibrationData;
- (void)receiveNewBall:(GLKVector3)startPosition andVelocity:(GLKVector3)startVelocity andTexIndex:(int)texIndex;
@end


extern CommunicationManager *gCommunicationManager;

@interface CommunicationManager : NSObject <GKSessionDelegate>
{
    NSString *sessionID;
    GKSession *mySession;
    
    NSMutableArray *connectedPeersInfor;
    
    Boolean searchOn;
    Boolean isMainDevice;
    
    NSMutableArray *connectedPeerList;
    NSMutableArray *availablePeerList;
    
    int DEVICE_WIDTH;
    int DEVICE_HEIGHT;
    float DEVICE_RATIO;
}

@property (assign) id<CommunicationManagerDelegate> delegate;

@property (nonatomic, assign) Boolean isMainDevice;
@property (nonatomic, readonly) NSMutableArray *availablePeerList;
@property (nonatomic, readonly) NSMutableArray  *connectedPeerList;

@property (nonatomic, assign) int DEVICE_WIDTH;
@property (nonatomic, assign) int DEVICE_HEIGHT;
@property (nonatomic, assign) float DEVICE_RATIO;

+ (CommunicationManager *) instance;

- (void) initSession;
- (NSString *)getNameOfDevice:(NSString *)peerId;
- (void) connectToDevice:(NSString *)peerId;

- (void) sendCalibrationData;
- (void) sendBallData:(GLKVector3) startPosition andVelocity:(GLKVector3)startVelocity andTexIndex:(int)texIndex;

- (void) destroyMySession;

@end
