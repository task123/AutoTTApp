//
//  SendMessageViewController.m
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 18.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "SendMessageViewController.h"
#import <CoreText/CoreText.h>
#import "MainViewController.h"

@interface SendMessageViewController()
@property (strong, nonatomic) IBOutlet UITextField *message;
@property (strong, nonatomic) IBOutlet UITextView *messageLogTextView;

@end
@implementation SendMessageViewController

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"tcpReceivedMessage"]) {
        self.messageLogTextView.attributedText = self.tcpConnection.messageLog;
    } else if ([[notification name] isEqualToString:@"tcpError"]){
        NSArray *viewControllers = self.navigationController.viewControllers;
        MainViewController *mainViewController = (MainViewController *)[viewControllers objectAtIndex:0];
        [mainViewController.gyroscopeData stopGyroscopteData];
        if (mainViewController.connectionTestTimer) {
            [mainViewController.connectionTestTimer invalidate];
            mainViewController.connectionTestTimer = nil;
        }
        [self performSegueWithIdentifier:@"unwindToCouldNotConnectFromSendMessageVC" sender:self];
    }
}

- (IBAction)send:(id)sender {
    [self.tcpConnection sendMessage:[@"Message#%#" stringByAppendingString:self.message.text]];
    self.message.text = @"";
    self.messageLogTextView.attributedText = self.tcpConnection.messageLog;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.message setDelegate:self];
    self.messageLogTextView.editable = NO;
    self.messageLogTextView.attributedText = self.tcpConnection.messageLog;
}

- (void)viewWillAppear:(BOOL)animated{
    // register for tcpConnection notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"tcpReceivedMessage"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"tcpError"
                                               object:nil];

}

- (void)viewWillDisappear:(BOOL)animated{    
    // unregister for tcpConnection notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpReceivedMessage"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpError"
                                                  object:nil];
}


@end
