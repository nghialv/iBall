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
@synthesize DEVICE_TYPE, DEVICE_WIDTH, DEVICE_HEIGHT, DEVICE_RATIO, isMainDevice;

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
    
    
    // for position, direction
    startGesture = [NSDate date];
    
    
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
    mySession.disconnectTimeout = 10;
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
    mySession.available = NO;
    mySession.delegate = nil;
    [mySession disconnectFromAllPeers];
	[mySession setDataReceiveHandler:nil withContext:nil];
	mySession = nil;
    
    [availablePeerList removeAllObjects];
    [connectedPeerList removeAllObjects];
}

#pragma mark - Send and receive data
- (void) sendCalibrationData:(CGPoint)pEndPoint andDirection:(int)pDirection
{
    startGesture = [NSDate date];
    direction = pDirection;
    endPoint = [self convertCoordinationTo3D:pEndPoint];
    
    NSString *message = [[NSString alloc] initWithFormat:@"%d %d %d %f %f", MESG_TYPE_CONNECT,DEVICE_TYPE, pDirection, endPoint.x, endPoint.y];
    NSLog(@"%@", message);
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    [mySession sendData:data
                toPeers:connectedPeerList
           withDataMode:GKSendDataReliable
                  error:&error];
    
    if (error) {
        NSLog(@"Send error: %@", error);
    }
}

- (void) sendBallData:(NSString *)peerId andStartPosition:(GLKVector3)startPosition andVelocity:(GLKVector3)startVelocity andTexIndex:(int)texIndex
{
    if (![connectedPeerList containsObject:peerId])
        return;
    
    NSLog(@"Send ball");
    NSString *message = [[NSString alloc] initWithFormat:@"%d %f %f %f %f %f %f %d", MESG_TYPE_SEND_BALL,startPosition.x, startPosition.y, startPosition.z, startVelocity.x,startVelocity.y,startVelocity.z, texIndex];
    
    NSData *sendData = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    [mySession sendData:sendData
                toPeers:[NSArray arrayWithObject:peerId]
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
            double elapsed_ms = [startGesture timeIntervalSinceNow] * -1000.0;
            
            NSLog(@"elapsed: %f", elapsed_ms);
            if (elapsed_ms > 300.0)
                return;
            
            int peerDeviceType = [[params objectAtIndex:1] intValue];
            int peerDeviceDirection = [[params objectAtIndex:2] intValue];
            GLKVector3 peerEndPoint= GLKVector3Make(0.0f, 0.0f, 0.0f);
            peerEndPoint.x = [[params objectAtIndex:3] floatValue];
            peerEndPoint.y = [[params objectAtIndex:4] floatValue];
            
            [self calculateTransitionMatrix:peer andPeerDeviceType:peerDeviceType andDeviceDirection:peerDeviceDirection andPeerEndpoint:peerEndPoint];
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
                [delegate receiveNewBall:peer andStartPosition:p andVelocity:v andTexIndex:texIndex];
            }
        }
    }
}

#pragma mark - Calculate Transition Matrix
-(void) calculateTransitionMatrix:(NSString *)peerId andPeerDeviceType:(int)peerDeviceType andDeviceDirection:(int)peerDeviceDirection andPeerEndpoint:(GLKVector3)peerEndPoint
{
    float angle = -M_PI_2;
        
    int sum = direction + peerDeviceDirection;
    int minus = direction - peerDeviceDirection;
    
    if (minus == 0) {
        angle = M_PI;
    }
    else{
        if (sum == 0) {
            angle = 0.0f;
        }
        else
        {
            if ((sum == 3 && minus == -1) || (sum == -3 && minus == 1) || (sum == 1 && minus == 3) || (sum == -1 && minus == -3))
                angle = M_PI_2;
        }
    }
    
    float x = endPoint.x - peerEndPoint.x*cos(angle) + peerEndPoint.y*sin(angle);
    float y = endPoint.y - peerEndPoint.y*cos(angle) - peerEndPoint.x*sin(angle);
        
    NSLog(@"angle: %f   translate: %f %f", angle, x, y);
    
    GLKMatrix4 convertMatrix = GLKMatrix4Identity;
    convertMatrix = GLKMatrix4Translate(convertMatrix, x, y, 0.0f);
    convertMatrix = GLKMatrix4Rotate(convertMatrix, angle, 0.0f, 0.0f, 1.0f);
    
    NSLog(@"ConvertMatrix:");
    NSLog(@"    %f %f %f %f",convertMatrix.m00,convertMatrix.m01,convertMatrix.m02,convertMatrix.m03);
    NSLog(@"    %f %f %f %f",convertMatrix.m10,convertMatrix.m11,convertMatrix.m12,convertMatrix.m13);
    NSLog(@"    %f %f %f %f",convertMatrix.m20,convertMatrix.m21,convertMatrix.m22,convertMatrix.m23);
    NSLog(@"    %f %f %f %f",convertMatrix.m30,convertMatrix.m31,convertMatrix.m32,convertMatrix.m33);   
    
    GLKVector3 sP = peerEndPoint;
    GLKVector3 eP = peerEndPoint;
    
    switch (peerDeviceDirection) {
        case DIRECTION_LEFT:
            sP.x = eP.x = peerEndPoint.x - GLES_LINE_WIDTH/2.0f;
            sP.y = DEVICES_HEIGHT[peerDeviceType]*DEVICES_RATIO[peerDeviceType]/2.0;
            eP.y = -sP.y;
            break;
        case DIRECTION_RIGHT:
            sP.x = eP.x = peerEndPoint.x + GLES_LINE_WIDTH/2.0f;
            sP.y = DEVICES_HEIGHT[peerDeviceType]*DEVICES_RATIO[peerDeviceType]/2.0;
            eP.y = -sP.y;
            break;
        case DIRECTION_UP:
            sP.y = eP.y = peerEndPoint.y + GLES_LINE_WIDTH/2.0f;
            sP.x = DEVICES_WIDTH[peerDeviceType]*DEVICES_RATIO[peerDeviceType]/2.0;
            eP.x = -sP.x;
            break;
        case DIRECTION_DOWN:
            sP.y = eP.y = peerEndPoint.y - GLES_LINE_WIDTH/2.0f;
            sP.x = DEVICES_WIDTH[peerDeviceType]*DEVICES_RATIO[peerDeviceType]/2.0;
            eP.x = -sP.x;
            break;
        default:
            break;
    }
    
    NSLog(@"sP: %f %f %f", sP.x, sP.y, sP.z);
    
    GLKVector3 sPoint = GLKMatrix4MultiplyVector3WithTranslation(convertMatrix, sP);
    GLKVector3 ePoint = GLKMatrix4MultiplyVector3WithTranslation(convertMatrix, eP);
    
    if (direction == DIRECTION_LEFT || direction == DIRECTION_RIGHT) {
        if (sPoint.y < -DEVICE_HEIGHT*DEVICE_RATIO/2)
            sPoint.y = -DEVICE_HEIGHT*DEVICE_RATIO/2;
        if (ePoint.y < -DEVICE_HEIGHT*DEVICE_RATIO/2)
            ePoint.y = -DEVICE_HEIGHT*DEVICE_RATIO/2;
        if (sPoint.y > DEVICE_HEIGHT*DEVICE_RATIO/2)
            sPoint.y = DEVICE_HEIGHT*DEVICE_RATIO/2;
        if (ePoint.y > DEVICE_HEIGHT*DEVICE_RATIO/2)
            ePoint.y = DEVICE_HEIGHT*DEVICE_RATIO/2;
    }
    else
    {
        if (sPoint.x < -DEVICE_WIDTH*DEVICE_RATIO/2)
            sPoint.x = -DEVICE_WIDTH*DEVICE_RATIO/2;
        if (ePoint.x < -DEVICE_WIDTH*DEVICE_RATIO/2)
            ePoint.x = -DEVICE_WIDTH*DEVICE_RATIO/2;
        if (sPoint.x > DEVICE_WIDTH*DEVICE_RATIO/2)
            sPoint.x = DEVICE_WIDTH*DEVICE_RATIO/2;
        if (ePoint.x > DEVICE_WIDTH*DEVICE_RATIO/2)
            ePoint.x = DEVICE_WIDTH*DEVICE_RATIO/2;
    }
    
    NSLog(@"sP: %f %f %f", sP.x, sP.y, sP.z);
    
    if (delegate) {
        [delegate drawConnectionLine:peerId andTransitionMatrix:convertMatrix andDirection:direction andStartPoint:sPoint andEndPoint:ePoint];
    }
}

- (GLKVector3) convertCoordinationTo3D:(CGPoint)point
{
    float x = (point.x - DEVICE_WIDTH/2)*DEVICE_RATIO;
    float y = -(point.y - DEVICE_HEIGHT/2)*DEVICE_RATIO;
    GLKVector3 coord = GLKVector3Make(x, y, 0.0f);
    return coord;
}


#pragma mark - GKSessionDelegate
// didChangeState
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	switch (state) {
		case GKPeerStateAvailable:
            NSLog(@"Trang thai Avaiable: %@", peerID);
            
            if (![availablePeerList containsObject:peerID]) {
				[availablePeerList addObject:peerID];
			}
            
            // what for?
            [NSThread sleepForTimeInterval:0.5];
            
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

// didReceiveConnectionRequestFromPeer
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
    
    //new
    if (delegate) {
        [delegate connectionStatusChanged];
    }
}

// connectionWithPeerFailed
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	NSLog(@"%@|%@", peerID, error);
    
    //new
    if (delegate) {
        [delegate connectionStatusChanged];
    }
}

// didFailWithError
- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	NSLog(@"%@", error);
    
    //new
    if (delegate) {
        [delegate connectionStatusChanged];
    }
}


@end
