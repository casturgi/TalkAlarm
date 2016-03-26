//
//  RingtoneHelper.h
//  TalkAlarm
//
//  Created by cory Sturgis on 2/26/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RingtoneHelper : NSObject

@property NSString *name;
@property NSString *fileName;

-(RingtoneHelper *) initWithName:(NSString *)name andFileName:(NSString *)fileName;

@end
