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
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.info.text = self.infoString;
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
}

- (void)viewWillDisappear:(BOOL)animated{
    // unregister for tcpConnection notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpError"
                                                  object:nil];
}


@end
