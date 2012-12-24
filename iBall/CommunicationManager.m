//
//  CommunicationManager.m
//  iBall
//
//  Created by iNghia on 12/12/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "CommunicationManager.h"

CommunicationManager *gCommunicationManager;

@implementation CommunicationManager
@synthesize delegate;
@synthesize availablePeerList;
@synthesize connectedPeerList;
@synthesize DEVICE_WIDTH, DEVICE_HEIGHT, DEVICE_RATIO, isMainDevice;

// Khoi tao gCommunication lan dau tien
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        gCommunicationManager = [[CommunicationManager alloc] init];
    }
}

// Tra ve instace
+ (CommunicationManager *)instance
{
	return gCommunicationManager;
}

// khoi tao cho communication manager
- (CommunicationManager *)init
{
    self = [super init];
    
    connectedPeersInfor = [[NSMutableArray alloc] init];
    availablePeerList = [[NSMutableArray alloc] init];
    connectedPeerList = [[NSMutableArray alloc] init];
    
    sessionID = @"iBall";
    searchOn = false;
    isMainDevice = false;
    
    return self;
}

// Search devices
- (void) initSession
{
    if(searchOn)
        return;
    
    if (!mySession)
        mySession = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModePeer];
    
    mySession.delegate = self;
    [mySession setDataReceiveHandler:self withContext:nil];
    mySession.available = YES;
    
    searchOn = true;
}


- (void) connectToDevice:(NSString *)peerId
{
    NSLog(@"Connect to Device");
    [mySession connectToPeer:peerId withTimeout:10];
}

// get name of device from peerid
- (NSString *) getNameOfDevice:(NSString *)peerId
{
    return [mySession displayNameForPeer:peerId];
}

// destroy session when application will terminate
- (void)destroyMySession
{
    mySession.delegate = nil;
	[mySession setDataReceiveHandler:nil withContext:nil];
	mySession = nil;
    
    [availablePeerList removeAllObjects];
    [connectedPeerList removeAllObjects];
}


#pragma mark - Send and receive data
- (void) sendCalibrationData
{
    
}

- (void) sendBallData:(GLKVector3)startPosition andVelocity:(GLKVector3)startVelocity andTexIndex:(int)texIndex
{
    NSLog(@"Send ball");
    NSString *message = [[NSString alloc] initWithFormat:@"%d %f %f %f %f %f %f %d", MESG_TYPE_SEND_BALL,startPosition.x, startPosition.y, startPosition.z, startVelocity.x,startVelocity.y,startVelocity.z, texIndex];
    
    NSData *sendData = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    [mySession sendData:sendData
                toPeers:connectedPeerList
           withDataMode:GKSendDataReliable
                  error:&error];
    
    if (error) {
        NSLog(@"Send error: %@", error);
    }
}

// receive data
- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    //check xem co phai la text hay la image
	if ([data length] < 1024) {
        
		NSString* msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *params = [msg componentsSeparatedByString:@" "];
        int mesgType = [[params objectAtIndex:0] intValue];
        
        if (mesgType == MESG_TYPE_CONNECT) {
            NSLog(@"Reveice Connect mesg");
        }
        else if (mesgType == MESG_TYPE_GAME_START)
        {
            NSLog(@"Reveice game start mesg");
            if (delegate) {
                [delegate receiveGameStart];
            }
        }
        else if (mesgType == MESG_TYPE_SEND_BALL)
        {
            NSLog(@"Reveice add new ball mesg");
            
            GLKVector3 p = GLKVector3Make([[params objectAtIndex:1] floatValue],
                                          [[params objectAtIndex:2] floatValue],
                                          [[params objectAtIndex:3] floatValue]);
            GLKVector3 v = GLKVector3Make([[params objectAtIndex:4] floatValue],
                                          [[params objectAtIndex:5] floatValue],
                                          [[params objectAtIndex:6] floatValue]);
            int texIndex = [[params objectAtIndex:7] intValue];
            
            if (delegate) {
                [delegate receiveNewBall:p andVelocity:v andTexIndex:texIndex];
            }
        }
    }
}

#pragma mark - GKSessionDelegate
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	switch (state) {
		case GKPeerStateAvailable:
            NSLog(@"Trang thai Avaiable: %@", peerID);
            
            if (![availablePeerList containsObject:peerID]) {
				[availablePeerList addObject:peerID];
			}
            
			break;
            
        case GKPeerStateUnavailable:
            [availablePeerList removeObject:peerID];
            break;
            
		case GKPeerStateConnected:
            NSLog(@"Trang thai connected: %@", peerID);
            
            if (![connectedPeerList containsObject:peerID]) {
				[connectedPeerList addObject:peerID];
			}
            [availablePeerList removeObject:peerID];
            
            break;
            
		case GKPeerStateDisconnected:
            NSLog(@"Trang thai disconnected");
            [connectedPeerList removeObject:peerID];

		default:
			break;
	}
    
    if (delegate) {
        [delegate connectionStatusChanged];
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	NSError* error = nil;
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:[session displayNameForPeer:peerID]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil
                              ];
    [alertView show];
    
	[session acceptConnectionFromPeer:peerID error:&error];
	if (error)
		NSLog(@"%@", error);
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	NSLog(@"%@|%@", peerID, error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	NSLog(@"%@", error);
}

@end
