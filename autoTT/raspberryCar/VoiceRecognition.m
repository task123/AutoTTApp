//
//  VoiceRecognition.m
//  AutoTT
//
//  Created by Håkon Austlid Taskén on 17.04.2016.
//  Copyright © 2016 Håkon Austlid Taskén. All rights reserved.
//

#import "VoiceRecognition.h"
#import </Users/hakonaustlidtasken/Documents/6. Semester/Instrumentering/tt/paulOpenEars/OpenEarsDistribution/OpenEars/Classes/include/OELanguageModelGenerator.h>
#import </Users/hakonaustlidtasken/Documents/6. Semester/Instrumentering/tt/paulOpenEars/OpenEarsDistribution/OpenEars/Classes/include/OEAcousticModel.h>
#import </Users/hakonaustlidtasken/Documents/6. Semester/Instrumentering/tt/paulOpenEars/OpenEarsDistribution/OpenEars/Classes/include/OEPocketsphinxController.h>

@interface VoiceRecognition ()

@property BOOL isLastWordCar;
@property double timeOfLastCarWord;

@end

@implementation VoiceRecognition

- (void) startVoiceRecognition:(TCPConnection*)tcpConnection{
    self.tcpConnection = tcpConnection;
    
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];

    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    NSArray *words = [NSArray arrayWithObjects:@"CAR", @"DRIVE", @"STOP", @"RIGHT", @"LEFT", @"HIGH", nil];
    NSString *name = @"VoiceControlLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    NSString *lmPath = nil;
    NSString *dicPath = nil;
    
    if(err == nil) {
        
        lmPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"VoiceControlLanguageModelFiles"];
        dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"VoiceControlLanguageModelFiles"];
        
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    
    [[OEPocketsphinxController sharedInstance] setSecondsOfSilenceToDetect:0.1];
    [[OEPocketsphinxController sharedInstance] setVadThreshold:3.5];
    
    [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
    
    NSLog(@"VoiceRecognition started");
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    if (self.isLastWordCar && ![hypothesis isEqualToString:@"CAR"] && ([[NSDate date] timeIntervalSince1970] - self.timeOfLastCarWord < 2.5)){
        [self.tcpConnection sendMessage:[@"VoiceRecogniction#$#" stringByAppendingString: hypothesis]];
        //NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    }
    if ([hypothesis isEqualToString:@"CAR"]){
        self.isLastWordCar = YES;
        self.timeOfLastCarWord = [[NSDate date] timeIntervalSince1970];
    } else {
        self.isLastWordCar = NO;
    }
}
@end