//
//  MainViewController.m
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 17.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "MainViewController.h"
#import "MenuTableViewController.h"
#import "PopUpMessageViewController.h"

@interface MainViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIWebView *videoStreamWebView;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stopButtonOutlet;

@end

@implementation MainViewController

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"tcpReceivedMessage"]) {
        [self performSegueWithIdentifier:@"popUpMessage" sender:self];
    } else if ([[notification name] isEqualToString:@"tcpError"]){
        [self performSegueWithIdentifier:@"unwindToCouldNotConnectFromMainVC" sender:self];
    } else if ([[notification name] isEqualToString:@"tcpReceivedGyro"]){
        [self.gyroscopeData stopGyroscopteDate];
        [self.gyroscopeData startGyroscopeDateWithIntervall:[self.tcpConnection.messageReceived doubleValue]];
    } else if ([[notification name] isEqualToString:@"tcpReceivedButtonsOn"]){
        [self.leftButton setHidden:NO];
    } else if ([[notification name] isEqualToString:@"tcpReceivedButtonsOff"]){
        [self.leftButton setHidden:YES];
    } else if ([[notification name] isEqualToString:@"tcpReceivedModes"]){
        self.modesArray = [self.tcpConnection.messageReceived componentsSeparatedByString:@";"];
    } else if ([[notification name] isEqualToString:@"tcpReceivedInfoModes"]){
        self.modesInfoArray = [self.tcpConnection.messageReceived componentsSeparatedByString:@";"];
    }
}

- (void)updateOfGyroscopeDateWithRoll:(double)roll Pitch:(double)pitch Yaw:(double)yaw{
    [self.tcpConnection sendMessage:[NSString stringWithFormat: @"Gyro#$# %f; %f; %f", roll, pitch, yaw]];
}

- (IBAction)leftButtonTouchDown:(id)sender {
    [self.tcpConnection sendMessage:@"LeftButtonTouchDown#$#"];
}
- (IBAction)rightButtonTouchDown:(id)sender {
    [self.tcpConnection sendMessage:@"RightButtonTouchDown#$#"];
}
- (IBAction)leftButtonTouchUp:(id)sender {
    [self.tcpConnection sendMessage:@"LeftButtonTouchUp#$#"];
}
- (IBAction)rightButtonTouchUp:(id)sender {
    [self.tcpConnection sendMessage:@"RightButtonTouchUp#$#"];
}

- (IBAction)StopButton:(id)sender {
    if ([self.stopButtonOutlet.title isEqualToString:@"Stop"]){
        self.stopButtonOutlet.title = @"Continue";
        [self.tcpConnection sendMessage:@"Stop#$#"];
    } else {
        self.stopButtonOutlet.title = @"Stop";
        [self.tcpConnection sendMessage:@"Continue#$#"];
    }
}

- (void)startVideoStream{
    [self.videoStreamWebView setHidden:NO];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.streamSourceURL]];
    [self.videoStreamWebView loadRequest:request];
}

- (void)stopVideoStream{
    [self.videoStreamWebView stopLoading];
    [self.videoStreamWebView setHidden:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"Menu/Settings"])
    {
        MenuTableViewController* menuTableViewControllerController = [segue destinationViewController];
        menuTableViewControllerController.tcpConnection = self.tcpConnection;
        menuTableViewControllerController.mainViewController = self;
    } else if ([[segue identifier] isEqualToString:@"popUpMessage"]){
        PopUpMessageViewController* popUpMessageViewController = [segue destinationViewController];
        popUpMessageViewController.tcpConnection = self.tcpConnection;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage* raspberyyPiImage = [UIImage imageNamed:@"raspberryPiLogo.png"];
    self.backgroundImage.image = raspberyyPiImage;
    [self.videoStreamWebView setHidden:YES];
    NSString *VideoPort = [NSString stringWithFormat:@"%ld",[[[NSUserDefaults standardUserDefaults] stringForKey:@"Port"] integerValue] + 1];
    self.streamSourceURL = [NSString stringWithFormat:@"https://%@:%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"IPAddress"],VideoPort];
    self.videoStreamOn = NO;
    self.videoQuality = 2;
    
    [self.leftButton setHidden:YES];
    [self.rightButton setHidden:YES];

    GyroscopeData* gyroscopeData = [[GyroscopeData alloc] init];
    self.gyroscopeData = gyroscopeData;
    self.gyroscopeData.delegate = self;
    NSNumber *sensitivity = [[NSUserDefaults standardUserDefaults] objectForKey:@"sensitivityValue"];
    self.gyroscopeData.sensitivity = [sensitivity floatValue];
    if (self.gyroscopeData.sensitivity < 0.6) {
        self.gyroscopeData.sensitivity = 1.0;
    }
    [self.gyroscopeData startGyroscopeDateWithIntervall:180.0/60.0];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:) name:@"tcpReceivedGyro" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:) name:@"tcpReceivedButtonsOn" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:) name:@"tcpReceivedButtonsOff" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"tcpReceivedModes"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"tcpReceivedInfoModes"
                                               object:nil];
    
    [self.tcpConnection sendMessage:@"Modes#$#"];
    [self.tcpConnection sendMessage:@"InfoModes#$#"];
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
    //[self.gyroscopeData stopGyroscopteDate];
    
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
    [self.gyroscopeData stopGyroscopteDate];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpReceivedButtonsOn"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpReceivedButtonsOff"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpReceivedGyro"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpReceivedModes"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpReceivedInfoModes"
                                                  object:nil];
}

@end
