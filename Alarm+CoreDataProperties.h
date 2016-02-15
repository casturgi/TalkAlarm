//
//  Alarm+CoreDataProperties.h
//  TalkAlarm
//
//  Created by cory Sturgis on 2/10/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Alarm.h"

NS_ASSUME_NONNULL_BEGIN

@interface Alarm (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *audioURL;
@property (nullable, nonatomic, retain) NSString *date;
@property (nullable, nonatomic, retain) NSNumber *mathSnooze;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *numberOProblems;
@property (nullable, nonatomic, retain) NSString *ringtoneFileName;

@end

NS_ASSUME_NONNULL_END
