//
//  MenuTableViewController.h
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 17.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPConnection.h"
#import "MainViewController.h"

@interface MenuTableViewController : UITableViewController

@property (weak, nonatomic) TCPConnection* tcpConnection;

@property (weak, nonatomic) MainViewController* mainViewController;

@end
