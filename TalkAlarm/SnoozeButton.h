//
//  SnoozeButton.h
//  TalkAlarm
//
//  Created by cory Sturgis on 3/10/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnoozeButton : UIView

@property NSTimer *countDownTimer;
@property int count;
@property (weak, nonatomic) IBOutlet UIButton *snoozeButton;

@end
