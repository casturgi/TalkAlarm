//
//  MathSnooze.h
//  TalkAlarm
//
//  Created by cory Sturgis on 3/10/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"
#import "SnoozeRoutingViewController.h"

@interface MathSnooze : UIView 
@property (weak, nonatomic) IBOutlet UILabel *numberOfCorrectProblemsLabel;

@property (weak, nonatomic) IBOutlet UILabel *randomMathProblemLabel;
@property (weak, nonatomic) IBOutlet UIButton *answerOneButton;
@property (weak, nonatomic) IBOutlet UIButton *answerTwoButton;
@property (weak, nonatomic) IBOutlet UIButton *answerThreeButton;

@property int num1;
@property int num2;
@property int num3;
@property int op1;
@property int op2;

@property int solution;

@property Alarm *alarm;

@property int answerAssigner;
@property int numberOfProblems;
@property int numberOfCorrectProblems;



@end
