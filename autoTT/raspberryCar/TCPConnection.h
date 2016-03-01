//
//  TCPConnection.h
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 18.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import <Foundation/Foundation.h>

// Class for making a tcp connection and sending and receiving messages
@interface TCPConnection : NSObject <NSStreamDelegate>
// TCPConnection sends out NSNotifications with the following names:
// @"tcpConnected", @"tcpError", @"tcpEnded" and @"tcpReceived'X'"
// where 'X' is the type of message specified in the received message as @"'X'#$#theActualMessage"
// if the received message does not contain '#$#' then 'X' is empty

@property (strong, nonatomic) NSString* errorMessage;
@property (strong, nonatomic) NSAttributedString* messageLog;
@property (strong, nonatomic) NSString* messageReceived;

-(void)connectToIPAddress:(NSString*)ipAddress andPort:(NSString*)
port;

- (void)sendMessage:(NSString*)message;

- (void)closeConnection;

// restrict the messages in messageLog to only be of type 'X' (@"'X'#$#theActualMessage")
- (void)setMessageLogTypeRestriction:(NSString*)X;

@end
