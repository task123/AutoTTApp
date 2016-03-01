//
//  CouldNotConnectViewController.h
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 22.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPConnection.h"

@interface CouldNotConnectViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *errorMessage;

@property (weak, nonatomic) TCPConnection* tcpConnection;
@end
