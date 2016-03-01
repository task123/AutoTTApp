//
//  ViewController.h
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 15.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPConnection.h"


@interface ConnectionViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) TCPConnection* tcpConnection;

@end

