//
//  TCPConnection.m
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 18.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "TCPConnection.h" 
#import <UIKit/UIKit.h>

@interface TCPConnection ()

@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;

@property (strong, nonatomic) NSString* typeRestriction;

@end

@implementation TCPConnection
-(void)connectToIPAddress:(NSString*)IPAddress andPort:(NSString*)
Port{
    CFStringRef ip = (__bridge CFStringRef)IPAddress;
    UInt32 portUInt32 = [Port integerValue];

    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, ip, portUInt32, &readStream, &writeStream);
    
    self.inputStream = (__bridge_transfer NSInputStream *)readStream;
    self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    [self.outputStream open];
}

- (void)closeConnection{
    [self.inputStream close];
    [self.outputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream setDelegate:nil];
    [self.outputStream setDelegate:nil];
    self.inputStream = nil;
    self.outputStream = nil;
}

- (void)sendMessage:(NSString*)message{
    //NSLog(message);
    message = [message stringByAppendingString:@"%^%"];
    NSData *data = [[NSData alloc] initWithData:[[message stringByAppendingString:@"\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];
    if (self.outputStream.hasSpaceAvailable){
        [self.outputStream write:[data bytes] maxLength:[data length]];
    } else {
        NSLog(@"OutputStream did NOT have avaliable space to send message");
    }
    
    NSString* typeOfMessage = @"";
    NSRange rangeOfType = [message rangeOfString:@"#$#"];
    if (rangeOfType.location != NSNotFound) {
        typeOfMessage = [message substringToIndex:rangeOfType.location];
        message = [message substringFromIndex:rangeOfType.location + 3];
    }
    
    if ([typeOfMessage isEqualToString:self.typeRestriction] || [self.typeRestriction  isEqual: @""]) {
        NSDateFormatter *formatter;
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm:ss"];
        NSString *time = [formatter stringFromDate:[NSDate date]];
        NSString *senderPrefiks = [[@"Sendt    at    " stringByAppendingString:time] stringByAppendingString:@" >> "];
        NSString *messageWithPrefiks = [[senderPrefiks stringByAppendingString:message] stringByAppendingString:@"\n\n"];
    
    
        NSMutableAttributedString *logSendtMessage = [[NSMutableAttributedString alloc] initWithString:messageWithPrefiks];
        [logSendtMessage addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(0, senderPrefiks.length)];
        [logSendtMessage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(senderPrefiks.length, logSendtMessage.length - senderPrefiks.length - 2)];
        [logSendtMessage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:6] range:NSMakeRange(logSendtMessage.length - 2, 2)];
        [logSendtMessage appendAttributedString:self.messageLog];
        self.messageLog = logSendtMessage;
    }
}

- (void)receivedMessage:(NSString*)message{
    NSString* typeOfMessage = @"";
    NSRange rangeOfType = [message rangeOfString:@"#$#"];
    if (rangeOfType.location != NSNotFound) {
        typeOfMessage = [message substringToIndex:rangeOfType.location];
        message = [message substringFromIndex:rangeOfType.location + 3];
    } else {
        message = message;
    }
    NSRange rangeOfEnd = [message rangeOfString:@"%^%\r\n"];
    if (rangeOfEnd.location != NSNotFound) {
        self.messageReceived = [message substringToIndex:rangeOfEnd.location];
    } else {
        self.messageReceived = message;
    }
    
    
    if ([typeOfMessage isEqualToString:self.typeRestriction] || [self.typeRestriction  isEqual: @""]) {
        NSDateFormatter *formatter;
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm:ss"];
        NSString *time = [formatter stringFromDate:[NSDate date]];
        NSString *receivedPrefiks = [[@"Received at " stringByAppendingString:time] stringByAppendingString:@" >> "];
        NSString *messageWithPrefiks = [[receivedPrefiks stringByAppendingString:self.messageReceived] stringByAppendingString:@"\n\n"];
    
    
        NSMutableAttributedString *logReceivedMessage = [[NSMutableAttributedString alloc] initWithString:messageWithPrefiks];
        [logReceivedMessage addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(0, receivedPrefiks.length)];
        [logReceivedMessage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(receivedPrefiks.length, logReceivedMessage.length - receivedPrefiks.length - 2)];
        [logReceivedMessage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:6] range:NSMakeRange(logReceivedMessage.length - 2, 2)];
        [logReceivedMessage appendAttributedString:self.messageLog];
    
        self.messageLog = logReceivedMessage;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: [@"tcpReceived" stringByAppendingString:typeOfMessage] object:self];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"NSStreamEventOpenCompleted");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"tcpConnected" object:self];
            break;
            
        case NSStreamEventHasBytesAvailable:
            if (theStream == self.inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *message = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != message) {
                            NSLog(@"server said: %@", message);
                            [self receivedMessage:message];
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            //NSLog(@"NSStreamEventHasSpaceAvailable");
            break;
            
            
        case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"tcpEnded" object:self];
            break;
            
        case NSStreamEventNone:
            NSLog(@"NSStreamEventNone");
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"NSStreamEventErrorOccured");
            NSError* error = [theStream streamError];
            NSString *errorMessage = [NSString stringWithFormat:@"%@ (Code = %ld)", [error localizedDescription], (long)[error code]];
            self.errorMessage = errorMessage;
            NSLog(errorMessage);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"tcpError" object:self];
            break;
    }
    
}


- (void)setMessageLogTypeRestriction:(NSString *)typeRestriction{
    self.typeRestriction = typeRestriction;
}

- (NSAttributedString*)messageLog{
    if (!_messageLog) {
        _messageLog = [[NSAttributedString alloc] init];
    }
    return _messageLog;
}

- (NSString*)typeRestriction{
    if (!_typeRestriction){
        _typeRestriction = [[NSString alloc] init];
    }
    return _typeRestriction;
}


@end
