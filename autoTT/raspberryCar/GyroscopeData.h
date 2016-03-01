//
//  GyroscopeData.h
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 26.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@protocol gyroscopeDataDelegate

- (void)updateOfGyroscopeDateWithRoll:(double)roll Pitch: (double)pitch Yaw: (double)yaw;

@optional



@end

@interface GyroscopeData : NSObject

@property id <gyroscopeDataDelegate> delegate;

@property double sensitivity;
@property double rollOffset;
@property double pitchOffset;
@property double yawOffset;

- (void)startGyroscopeDateWithIntervall:(double)seconds;

- (void)stopGyroscopteDate;

@end
