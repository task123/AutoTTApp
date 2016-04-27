//
//  MenuTableViewController.m
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 17.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "MenuTableViewController.h"
#import "SendMessageViewController.h"
#import "ShutDownViewController.h"
#import "PopUpMessageViewController.h"
#import "ModesTableViewController.h"
#import "StatusTableViewController.h"
#import "SetStreamSourceViewController.h"
#import <CoreMotion/CoreMotion.h>
@import Foundation;

@interface MenuTableViewController ()

@property ShutDownViewController* shutDownViewController;

@property (strong, nonatomic) IBOutlet UISwitch *videoStreamSwitchOutlet;
@property (strong, nonatomic) IBOutlet UISegmentedControl *videoQualityOutlet;
@property CMMotionManager* motionManager;
@property NSTimer* nsTimer;
@property (strong, nonatomic) IBOutlet UISlider *sensitivitySliderOutlet;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MenuTableViewController

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"tcpReceivedMessage"]) {
        [self performSegueWithIdentifier:@"popUpMessage" sender:self];
    } else if ([[notification name] isEqualToString:@"tcpError"]){
        [self performSegueWithIdentifier:@"unwindToCouldNotConnectFromMenuVC" sender:self];
    } else if ([[notification name] isEqualToString:@"tcpReceivedVideoStreamRefresh"]){
        if (self.mainViewController.videoStreamOn){
            [self.mainViewController stopVideoStream];
            [self.mainViewController startVideoStream];
        }
    } else if ([[notification name] isEqualToString:@"tcpReceivedVideoStreamStarted"]){
        [self.activityIndicator stopAnimating];
    }
}

- (IBAction)videoStreamSwitch:(id)sender {
    if ([self.videoStreamSwitchOutlet isOn]){
        self.mainViewController.videoStreamOn = YES;
        [self.mainViewController startVideoStream];
        [self sendVideoQuality];
        [self.tcpConnection sendMessage:@"VideoStream#$#On"];
        [self.activityIndicator startAnimating];
    } else {
        self.mainViewController.videoStreamOn = NO;
        [self.mainViewController stopVideoStream];
        [self.tcpConnection sendMessage:@"VideoStream#$#Off"];
        [self.activityIndicator stopAnimating];
    }
}

- (IBAction)videoQuality:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:self.videoQualityOutlet.selectedSegmentIndex forKey:@"VideoQuality"];
}

- (void)sendVideoQuality{
    NSString *videoQuality;
    switch (self.videoQualityOutlet.selectedSegmentIndex) {
        case 0:
            videoQuality = @"Low";
            break;
            
        case 1:
            videoQuality = @"Medium";
            break;
            
        case 3:
            videoQuality = @"High";
            break;
            
        default:
            videoQuality = @"High";
            break;
    }
    [self.tcpConnection sendMessage:[@"VideoQuality#$#" stringByAppendingString:videoQuality]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 6)
    {
        self.motionManager = [[CMMotionManager alloc] init];
        self.nsTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getGyroData) userInfo:nil repeats:NO];
        self.motionManager.deviceMotionUpdateInterval = 0.0001;
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
    } else if (indexPath.row == 7){
        self.mainViewController.gyroscopeData.offset = NO;
    }
}

- (void)getGyroData{
    CMAttitude* attitude = self.motionManager.deviceMotion.attitude;
    if ((attitude.roll == 0.0 && attitude.pitch == 0.0) && attitude.yaw == 0.0){
        self.motionManager = [[CMMotionManager alloc] init];
        self.nsTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getGyroData) userInfo:nil repeats:NO];
        self.motionManager.deviceMotionUpdateInterval = 0.0001;
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
    } else {
        self.mainViewController.gyroscopeData.offsetAttitude = attitude;
        self.mainViewController.gyroscopeData.offset = YES;
        if(self.motionManager != nil){
            [self.motionManager stopDeviceMotionUpdates];
            [self.motionManager stopGyroUpdates];
            if (self.nsTimer) {
                [self.nsTimer invalidate];
                self.nsTimer = nil;
            }
            self.motionManager = nil;
        }
    }

}

- (IBAction)sensitivitySliter:(id)sender {
    self.mainViewController.gyroscopeData.sensitivity = self.sensitivitySliderOutlet.value;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"SendMessage"]){
        SendMessageViewController *sendMessageViewController = [segue destinationViewController];
        sendMessageViewController.tcpConnection = self.tcpConnection;
    } else  if ([[segue identifier] isEqualToString:@"popUpMessage"]){
        PopUpMessageViewController* popUpMessageViewController = [segue destinationViewController];
        popUpMessageViewController.tcpConnection = self.tcpConnection;
    } else if ([[segue identifier] isEqualToString:@"modes"]){
        ModesTableViewController *modesTableViewController = [segue destinationViewController];
        modesTableViewController.tcpConnection = self.tcpConnection;
        modesTableViewController.mainViewController = self.mainViewController;
    } else if ([[segue identifier] isEqualToString:@"status"]){
        StatusTableViewController* statusTableViewController = [segue destinationViewController];
        statusTableViewController.tcpConnection = self.tcpConnection;
    } else if ([[segue identifier] isEqualToString:@"ShutDown"]){
        ShutDownViewController* shutDownViewController = [segue destinationViewController];
        shutDownViewController.tcpConnection = self.tcpConnection;
    } else if ([[segue identifier] isEqualToString:@"SetStreamSource"]){
        SetStreamSourceViewController* setStreamSourceViewController = [segue destinationViewController];
        setStreamSourceViewController.mainViewController = self.mainViewController;
    } else if ([[segue identifier] isEqualToString:@"unwindToCouldNotConnectFromMenuVC"]){
        [self.mainViewController stopGyroAndRemoveObservers];
        if (self.mainViewController.connectionTestTimer) {
            [self.mainViewController.connectionTestTimer invalidate];
            self.mainViewController.connectionTestTimer = nil;
        }
    } else if ([[segue identifier] isEqualToString:@"unwindToConnectionFromMenuVC"]){
        [self.mainViewController stopGyroAndRemoveObservers];
        if (self.mainViewController.connectionTestTimer) {
            [self.mainViewController.connectionTestTimer invalidate];
            self.mainViewController.connectionTestTimer = nil;
        }
    }
}

- (IBAction)unwindToMenu:(UIStoryboardSegue*)unwindSegue{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.mainViewController.videoStreamOn) {
        [self.videoStreamSwitchOutlet setOn:YES animated:NO];
    } else {
        [self.videoStreamSwitchOutlet setOn:NO animated:NO];
    }
    self.videoQualityOutlet.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"VideoQuality"];
    self.sensitivitySliderOutlet.minimumValue = 0.67;
    self.sensitivitySliderOutlet.maximumValue = 1.33;
    self.sensitivitySliderOutlet.value = self.mainViewController.gyroscopeData.sensitivity;
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
                                                 name:@"tcpReceivedVideoStreamRefresh"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"tcpReceivedVideoStreamStarted"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.sensitivitySliderOutlet.value] forKey:@"sensitivityValue"];
    
    // unregister for tcpConnection notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpReceivedMessage"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpError"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpReceivedVideoStreamRefresh"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpReceivedVideoStreamStarted"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
