//
//  ModesInfoViewController.m
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 29.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "ModesInfoViewController.h"
#import "MainViewController.h"

@interface ModesInfoViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ModesInfoViewController

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"tcpError"]){
        NSArray *viewControllers = self.navigationController.viewControllers;
        MainViewController *mainViewController = (MainViewController *)[viewControllers objectAtIndex:0];
        [mainViewController stopGyroAndRemoveObservers];
        if (mainViewController.connectionTestTimer) {
            [mainViewController.connectionTestTimer invalidate];
            mainViewController.connectionTestTimer = nil;
        }
        [self performSegueWithIdentifier:@"unwindToCouldNotConnectFromModesInfoVC" sender:self];
    } else if ([[notification name] isEqualToString:@"tcpReceivedInfoModes"]){
        self.info.text = self.tcpConnection.messageReceived;
        [self.info setNeedsDisplay];
        [self.activityIndicator stopAnimating];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    // register for tcpConnection notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"tcpError"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"tcpReceivedInfoModes"
                                               object:nil];
    
    [self.tcpConnection sendMessage:[NSString stringWithFormat:@"InfoModes#$#%ld", self.chosenInfo]];
    [self.activityIndicator startAnimating];
}

- (void)viewWillDisappear:(BOOL)animated{
    // unregister for tcpConnection notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpError"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpReceivedInfoModes"
                                                  object:nil];
}


@end
