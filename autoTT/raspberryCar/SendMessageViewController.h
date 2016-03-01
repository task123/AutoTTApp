//
//  SendMessageViewController.h
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 19.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPConnection.h"

@interface SendMessageViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) TCPConnection* tcpConnection;

@end