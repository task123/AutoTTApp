//
//  StatusTableViewController.m
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 18.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "StatusTableViewController.h"
#import "PopUpMessageViewController.h"
#import "MainViewController.h"

@interface StatusTableViewController ()

@property (strong, nonatomic) NSArray* status;
@property (strong, nonatomic) IBOutlet UITableView *statusTable;

@end

@implementation StatusTableViewController

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"tcpReceivedMessage"]) {
        [self performSegueWithIdentifier:@"popUpMessage" sender:self];
    } else if ([[notification name] isEqualToString:@"tcpError"]){
        NSArray *viewControllers = self.navigationController.viewControllers;
        MainViewController *mainViewController = (MainViewController *)[viewControllers objectAtIndex:0];
        [mainViewController.gyroscopeData stopGyroscopteData];
        if (mainViewController.connectionTestTimer) {
            [mainViewController.connectionTestTimer invalidate];
            mainViewController.connectionTestTimer = nil;
        }
        [self performSegueWithIdentifier:@"unwindToCouldNotConnectFromStatusVC" sender:self];
    } else if ([[notification name] isEqualToString:@"tcpReceivedStatus"]){
        self.status = [self.tcpConnection.messageReceived componentsSeparatedByString:@";"];
        [self.statusTable reloadData];
    }
}

- (IBAction)refresh:(id)sender {
    [self.tcpConnection sendMessage:@"Status#$#"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"popUpMessage"]){
        PopUpMessageViewController* popUpMessageViewController = [segue destinationViewController];
        popUpMessageViewController.tcpConnection = self.tcpConnection;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tcpConnection sendMessage:@"Status#$#"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"tcpReceivedStatus"
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpReceivedStatus"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.status.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statusTableCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.status objectAtIndex:indexPath.row];
    return cell;
}

@end
