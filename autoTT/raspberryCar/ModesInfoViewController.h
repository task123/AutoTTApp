//
//  ModesInfoViewController.h
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 29.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPConnection.h"

@interface ModesInfoViewController : UIViewController
@property TCPConnection* tcpConnection;
@property (strong, nonatomic) IBOutlet UITextView *info;
@property NSInteger chosenInfo;

@end
