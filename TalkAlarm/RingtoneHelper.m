//
//  RingtoneHelper.m
//  TalkAlarm
//
//  Created by cory Sturgis on 2/26/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "RingtoneHelper.h"

@implementation RingtoneHelper

-(RingtoneHelper *) initWithName:(NSString *)name andFileName:(NSString *)fileName{
    RingtoneHelper *new = [[RingtoneHelper alloc]init];
    new.name = name;
    new.fileName = fileName;

    return new;

}

@end
