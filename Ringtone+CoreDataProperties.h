//
//  Ringtone+CoreDataProperties.h
//  TalkAlarm
//
//  Created by cory Sturgis on 2/25/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Ringtone.h"

NS_ASSUME_NONNULL_BEGIN

@interface Ringtone (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSSet<Alarm *> *alarm;

@end

@interface Ringtone (CoreDataGeneratedAccessors)

- (void)addAlarmObject:(Alarm *)value;
- (void)removeAlarmObject:(Alarm *)value;
- (void)addAlarm:(NSSet<Alarm *> *)values;
- (void)removeAlarm:(NSSet<Alarm *> *)values;

@end

NS_ASSUME_NONNULL_END
