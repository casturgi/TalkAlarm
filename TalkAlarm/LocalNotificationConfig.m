//
//  LocalNotificationConfig.m
//  TalkAlarm
//
//  Created by cory Sturgis on 2/9/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "LocalNotificationConfig.h"

@implementation LocalNotificationConfig

-(void)scheduleRepeatingLocalNotificationWithDate:(NSDate *)date andName:(NSString *)name{


    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.alertBody = @"TEST";
    notification.soundName = @"Alarm_tone.wav";
    notification.repeatInterval = NSCalendarUnitSecond;

    for (int i = 0; i <= 60; i++) {
        notification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
//[NSDate dateWithTimeInterval:i*6 sinceDate:date]
}

@end
