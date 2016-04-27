//
//  MainViewController.h
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 17.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPConnection.h"
#import "GyroscopeData.h"

@interface MainViewController : UIViewController <gyroscopeDataDelegate>

@property (weak, nonatomic) TCPConnection* tcpConnection;

@property (strong, nonatomic) GyroscopeData* gyroscopeData;

@property (strong, nonatomic) NSTimer* connectionTestTimer;

@property (strong, nonatomic) NSString* streamSourceURL;
@property BOOL videoStreamOn;
@property (strong, nonatomic) IBOutlet UINavigationItem *mode;
@property (strong, nonatomic) NSArray* modesArray;
@property (strong, nonatomic) NSArray* modesInfoArray;

- (void)startVideoStream;

- (void)stopVideoStream;

- (void)stopGyroAndRemoveObservers;

@end
