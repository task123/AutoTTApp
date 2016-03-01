//
//  ViewController.m
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 15.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "ConnectionViewController.h"
#import "MainViewController.h"
#import "MenuTableViewController.h"
#import "CouldNotConnectViewController.h"

#define kOFFSET_FOR_KEYBOARD 85.0



@interface ConnectionViewController ()

@property (strong, nonatomic) IBOutlet UITextField *IPAddress;
@property (strong, nonatomic) IBOutlet UITextField *Port;
@property NSString* errorMessage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property BOOL disconnectedDueToError;

@end

@implementation ConnectionViewController

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"tcpConnected"]) {
        [self.activityIndicator stopAnimating];
        [self performSegueWithIdentifier:@"Connect" sender:self];
    } else if ([[notification name] isEqualToString:@"tcpError"]) {
        [self.activityIndicator stopAnimating];
        [self performSegueWithIdentifier:@"CouldNotConnect" sender:self];
    }
}

- (IBAction)Connect:(id)sender {
    [self.activityIndicator startAnimating];
    if (self.tcpConnection == nil){
        self.tcpConnection = [[TCPConnection alloc] init];
        [self.tcpConnection setMessageLogTypeRestriction:@"Message"];
    }
    if (![self.IPAddress.text  isEqual: @"255.255.255.255"]) {
        [self.tcpConnection connectToIPAddress:self.IPAddress.text andPort:self.Port.text];
    } else {
        self.tcpConnection.errorMessage = @"Not valid IP address";
    }
}


- (IBAction)unwindToConnectionAction:(UIStoryboardSegue*)unwindSegue{
    [self.tcpConnection sendMessage:@"Disconnect#$#"];
    [self.tcpConnection closeConnection];
}

- (IBAction)unwindToCouldNotConnect:(UIStoryboardSegue*) unwindSegue{
    [self.tcpConnection closeConnection];
    self.disconnectedDueToError = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Connect"])
    {
        UINavigationController* mainNavigationController = [segue destinationViewController];
        MainViewController *mainViewController = mainNavigationController.topViewController;
        mainViewController.tcpConnection = self.tcpConnection;
    }else if([[segue identifier] isEqualToString:@"CouldNotConnect"]){
        CouldNotConnectViewController* couldNotConnectViewController = [segue destinationViewController];
        couldNotConnectViewController.tcpConnection = self.tcpConnection;
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{

    [textField resignFirstResponder];

    return YES;
}


-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}


//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void)viewDidAppear:(BOOL)animated{
    if (self.disconnectedDueToError){
        [self performSegueWithIdentifier:@"CouldNotConnect" sender:self];
        self.disconnectedDueToError = NO;
    }
}


- (void)viewWillAppear:(BOOL)animated{
    self.IPAddress.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"IPAddress"];
    self.Port.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Port"];
    
    // register for tcpConnection notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"tcpConnected"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"tcpError"
                                               object:nil];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults] setObject:self.IPAddress.text forKey:@"IPAddress"];
    [[NSUserDefaults standardUserDefaults] setObject:self.Port.text forKey:@"Port"];
    
    // unregister for tcpConnection notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpConnected"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tcpError"
                                                  object:nil];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.IPAddress setDelegate:self];
    [self.Port setDelegate:self];
    [self.activityIndicator setHidesWhenStopped:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
