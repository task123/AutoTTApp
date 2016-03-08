//
//  GyroscopeData.m
//  raspberryCar
//
//  Created by Håkon Austlid Taskén on 26.02.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "GyroscopeData.h"

@interface GyroscopeData()

@property (nonatomic, strong) CMMotionManager * motionManager;
@property (strong, nonatomic) NSTimer* nsTimer;

@end

@implementation GyroscopeData

-(void)startGyroscopeDateWithIntervall:(double)seconds
{
    [self stopGyroscopteDate];
    self.nsTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(updateDeviceMotion) userInfo:nil repeats:YES];
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = seconds;
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
}

-(void)updateDeviceMotion
{
    CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;
    
    if(deviceMotion == nil)
    {
        return;
    }
    
    CMAttitude *attitude = deviceMotion.attitude;
    if (self.offset){
        [attitude multiplyByInverseOfAttitude:self.offsetAttitude];
    }
    [self.delegate updateOfGyroscopeDateWithRoll:self.sensitivity * attitude.roll
                                           Pitch:self.sensitivity * attitude.pitch
                                             Yaw:self.sensitivity * attitude.yaw];
}

- (void)stopGyroscopteDate{
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

@end
