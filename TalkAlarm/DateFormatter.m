//
//  DateFormatter.m
//  TalkAlarm
//
//  Created by cory Sturgis on 2/8/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "DateFormatter.h"

@implementation DateFormatter

-(NSDate *)formatDateFromString:(NSString *)string{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    [dateFormatter setDateFormat:@"h:mm a"];

    return [dateFormatter dateFromString:string];
}

-(NSString *)formatStringFromDate:(NSDate *)date{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    [dateFormatter setDateFormat:@"h:mm a"];

    return [dateFormatter stringFromDate:date];
}


@end
