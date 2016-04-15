//
//  AddEditAlarmViewController.h
//  TalkAlarm
//
//  Created by cory Sturgis on 2/8/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"

@interface AddEditAlarmViewController : UIViewController <UITextFieldDelegate>

@property Alarm *passedAlarm;

@end
