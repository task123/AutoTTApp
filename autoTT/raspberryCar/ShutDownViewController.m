//
//  ShutDownViewController.m
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 20.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "ShutDownViewController.h"
#import "MainViewController.h"

@implementation ShutDownViewController
- (IBAction)ShutDown:(id)sender {
    [self.tcpConnection sendMessage:@"ShutDown#$#"];
}


- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"tcpError"]) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        MainViewController *mainViewController = (MainViewController *)[viewControllers objectAtIndex:0];
        [mainViewController.gyroscopeData stopGyroscopteDate];
        [self performSegueWithIdentifier:@"unwindToCouldNotConnectFromShutDownVC" sender:self];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    // register for tcpConnection notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:@"tcpError" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    // unregister for tcpConnection notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpError"
                                                  object:nil];
}
@end
