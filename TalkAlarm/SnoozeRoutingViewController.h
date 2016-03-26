//
//  SnoozeRoutingViewController.h
//  TalkAlarm
//
//  Created by cory Sturgis on 3/9/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Alarm.h"

@interface SnoozeRoutingViewController : UIViewController

@property NSString *triggerdAlarmDateString;
@property NSManagedObjectContext *moc;
@property NSArray *alarmsArray;
@property Alarm *alarmToPass;
@property (nonatomic, strong) NSNumber *numberOProblems;

@end
