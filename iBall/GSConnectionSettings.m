//
//  GSConnectionSettings.m
//  iBall
//
//  Created by iNghia on 12/12/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "GSConnectionSettings.h"

@implementation GSConnectionSettings
{
    NSMutableArray *availablePeers;
    NSMutableArray *connectedPeers;
}

#pragma mark - Mine
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [gCommunicationManager setDelegate:self];
    [gCommunicationManager initSession];
    
    availablePeers = gCommunicationManager.availablePeerList;
    connectedPeers = gCommunicationManager.connectedPeerList;
}

- (void) dealloc
{
    [gCommunicationManager setDelegate:nil];
}

- (IBAction) backToSettings:(id)sender
{
    NSLog(@"Back to Settings");
    [m_pManager doStateChange:@"SettingsStoryboardID"];
}

#pragma mark - ConnectionManagerDelegate
- (void) connectionStatusChanged
{
    NSLog(@"TRANG THAI KET NOI THAY DOI");
    for (NSString* p in availablePeers) {
        NSLog(@"A: %@", p);
    }
    [self.peerTableView reloadData];
}

- (void) receiveGameStart
{
    
}

- (void) receiveCalibrationData
{
    
}

- (void) receiveNewBall:(GLKVector3)startPosition andVelocity:(GLKVector3)startVelocity andTexIndex:(int)texIndex
{
    
}

#pragma mark - Table Section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// is used to inform the table view how many rows are in the section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [availablePeers count];
    return [connectedPeers count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Available Devices";
    return @"Connected Devices";
}

#pragma mark - Table Cell
// is used to fill the cell data
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"PeerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if (indexPath.section == 0)
        cell.textLabel.text = [gCommunicationManager getNameOfDevice:[availablePeers objectAtIndex:indexPath.row]];
    else
        cell.textLabel.text = [gCommunicationManager getNameOfDevice:[connectedPeers objectAtIndex:indexPath.row]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 1)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![gCommunicationManager isMainDevice])
        return;
    
    if (indexPath.section == 0) {
        [self.peerTableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [gCommunicationManager connectToDevice:[availablePeers objectAtIndex:indexPath.row]];
        
//        [connectedPeers addObject:[availablePeers objectAtIndex:indexPath.row]];
//        [availablePeers removeObjectAtIndex:indexPath.row];
//        [self.peerTableView reloadData];
    }
}


@end
