//
//  ModesTableViewController.m
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 17.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "ModesTableViewController.h"
#import "PopUpMessageViewController.h"
#import "ModesInfoViewController.h"

@interface ModesTableViewController ()

//@property (strong, nonatomic) NSArray* infoModes;
@property NSInteger chosenInfo;

@end

@implementation ModesTableViewController

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"tcpReceivedMessage"]) {
        [self performSegueWithIdentifier:@"popUpMessage" sender:self];
    } else if ([[notification name] isEqualToString:@"tcpError"]){
        [self.mainViewController stopGyroAndRemoveObservers];
        if (self.mainViewController.connectionTestTimer) {
            [self.mainViewController.connectionTestTimer invalidate];
            self.mainViewController.connectionTestTimer = nil;
        }
        [self performSegueWithIdentifier:@"unwindToCouldNotConnectFromModesVC" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"popUpMessage"]){
        PopUpMessageViewController* popUpMessageViewController = [segue destinationViewController];
        popUpMessageViewController.tcpConnection = self.tcpConnection;
    } else if ([[segue identifier] isEqualToString:@"infoModes"]){
        ModesInfoViewController* modesInfoViewController = [segue destinationViewController];
        modesInfoViewController.infoString = [self.mainViewController.modesInfoArray objectAtIndex:self.chosenInfo];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mainViewController.modesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mode" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.mainViewController.modesArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.mainViewController.modesArray.count){
        self.mainViewController.mode.title = [self.mainViewController.modesArray objectAtIndex:indexPath.row];
        [self.tcpConnection sendMessage:[NSString stringWithFormat:@"ChosenMode#$# %ld", (long)indexPath.row]];
            self.chosenInfo = indexPath.row;
        [self performSegueWithIdentifier:@"unwindToMenuFromModes" sender:self];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    self.chosenInfo = indexPath.row;
    [self performSegueWithIdentifier: @"infoModes" sender: [tableView cellForRowAtIndexPath: indexPath]];
}

- (IBAction)unwindToModesAction:(UIStoryboardSegue*)unwindSegue{
}

@end
