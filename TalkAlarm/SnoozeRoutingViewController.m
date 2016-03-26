//
//  SnoozeRoutingViewController.m
//  TalkAlarm
//
//  Created by cory Sturgis on 3/9/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "SnoozeRoutingViewController.h"
#import "SnoozeButton.h"
#import "MathSnooze.h"
#import "Recording.h"
#import <AVFoundation/AVFoundation.h>

@interface SnoozeRoutingViewController () <AVAudioPlayerDelegate>

@property AVAudioPlayer *audioPlayer;

@end

@implementation SnoozeRoutingViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    self.moc = delegate.managedObjectContext;

    //Initialize the audio session and handle any errors that occurr
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [audioSession setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }

    //load the saved alarms from core data and find the one that matches the triggered notification
    [self load];
    [self findNotificationAlarm];


    //determine the snooze method and display the appropriate xib file
    if ([self.alarmToPass.mathSnooze isEqualToNumber:[NSNumber numberWithInt:1]]) {
        MathSnooze *mathSnoozeXib = [[[NSBundle mainBundle]loadNibNamed:@"MathSnooze" owner:self options:nil]firstObject];
        NSLog(@"%@", self.alarmToPass.numberOProblems);

        mathSnoozeXib.numberOfProblems = [self.alarmToPass.numberOProblems intValue];
        CGRect viewRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [mathSnoozeXib setFrame:viewRect];

        [self.view addSubview:mathSnoozeXib];

    }
    else if ([self.alarmToPass.mathSnooze isEqualToNumber:[NSNumber numberWithInt:0]]){
        SnoozeButton *snoozeBtnXib = [[[NSBundle mainBundle] loadNibNamed:@"SnoozeButton" owner:self options:nil]firstObject];
        CGRect viewRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [snoozeBtnXib setFrame:viewRect];
        [self.view addSubview:snoozeBtnXib];
    }

    //play recording
    [self playVoicerecording];

}



-(void)load {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Alarm"];
    self.alarmsArray = [self.moc executeFetchRequest:request error:nil];
}

-(void)findNotificationAlarm{
    for (Alarm *triggered in self.alarmsArray) {
        NSString *dateString = [NSString stringWithFormat:@"%@", triggered.date];
        if ([dateString isEqualToString:self.triggerdAlarmDateString]) {
            self.alarmToPass = triggered;
        }
    }
}

-(void)playVoicerecording{
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:self.alarmToPass.recording.url] error:&error];
    self.audioPlayer.delegate = self;
    self.audioPlayer.numberOfLoops = -1;
    [self.audioPlayer play];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
