//
//  PopUpMessageViewController.m
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 24.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "PopUpMessageViewController.h"
#import "MainViewController.h"

@interface PopUpMessageViewController()
@property (strong, nonatomic) IBOutlet UILabel *message;

@end

@implementation PopUpMessageViewController

- (IBAction)exit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"tcpError"]){
        NSArray *viewControllers = self.navigationController.viewControllers;
        MainViewController *mainViewController = (MainViewController *)[viewControllers objectAtIndex:0];
        [mainViewController.gyroscopeData stopGyroscopteDate];
        [self performSegueWithIdentifier:@"unwindToCouldNotConnectFromPopUpMessageVC" sender:self];
    }
}

- (void)viewDidLoad{
    self.message.text = self.tcpConnection.messageReceived;
}

- (void)viewWillAppear:(BOOL)animated{
    // register for tcpConnection notifications
[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"tcpError"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    // unregister for tcpConnection notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpError"
                                                  object:nil];
    
}

@end
