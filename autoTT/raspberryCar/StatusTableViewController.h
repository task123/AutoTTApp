//
//  StatusTableViewController.h
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 18.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPConnection.h"

@interface StatusTableViewController : UITableViewController
@property TCPConnection* tcpConnection;
@end
