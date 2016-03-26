//
//  ChooseRingtoneTableViewController.h
//  TalkAlarm
//
//  Created by cory Sturgis on 2/9/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RingtoneHelper.h"


@protocol ChooseRingtoneTableViewControllerDelegate <NSObject>

-(void)addRingtone:(RingtoneHelper *)ringtone;

@end

@interface ChooseRingtoneTableViewController : UITableViewController

@property (nonatomic, assign) id <ChooseRingtoneTableViewControllerDelegate> ringtoneDelegate;

@end
