//
//  LocalNotificationConfig.h
//  TalkAlarm
//
//  Created by cory Sturgis on 2/9/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalNotificationConfig : UILocalNotification

-(void)scheduleRepeatingLocalNotificationWithDate:(NSDate *)date andName:(NSString *)name;
@end
