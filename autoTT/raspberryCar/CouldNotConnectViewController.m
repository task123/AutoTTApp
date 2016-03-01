//
//  CouldNotConnectViewController.m
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 22.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "CouldNotConnectViewController.h"

@interface CouldNotConnectViewController ()


@end

@implementation CouldNotConnectViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    self.errorMessage.text = [@"Error message: " stringByAppendingString:self.tcpConnection.errorMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
