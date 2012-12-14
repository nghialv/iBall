//
//  GSConnectionSettings.h
//  iBall
//
//  Created by iNghia on 12/12/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"
#import "CommunicationManager.h"

@interface GSConnectionSettings : GameState <UITableViewDelegate, UITableViewDataSource, CommunicationManagerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *peerTableView;

- (IBAction) backToSettings:(id)sender;

@end
