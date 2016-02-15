//
//  DateFormatter.h
//  TalkAlarm
//
//  Created by cory Sturgis on 2/8/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateFormatter : NSDateFormatter

-(NSString *)formatStringFromDate:(NSDate *)date;

-(NSDate *)formatDateFromString:(NSString *)string;

@end
