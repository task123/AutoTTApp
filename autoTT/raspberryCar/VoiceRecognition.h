//
//  VoiceRecognition.h
//  AutoTT
//
//  Created by Håkon Austlid Taskén on 17.04.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPConnection.h"
#import </Users/hakonaustlidtasken/Documents/6. Semester/Instrumentering/tt/paulOpenEars/OpenEarsDistribution/OpenEars/Classes/include/OEEventsObserver.h>

@interface VoiceRecognition : NSObject <OEEventsObserverDelegate>

@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;

@property TCPConnection* tcpConnection;

- (void) startVoiceRecognition:(TCPConnection*)tcpConnection;

@end
