//
//  AlarmsViewController.m
//  TalkAlarm
//
//  Created by cory Sturgis on 2/8/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "AppDelegate.h"
#import "AlarmsViewController.h"
#import "DateFormatter.h"
#import "LocalNotificationConfig.h"
#import "Alarm.h"

@interface AlarmsViewController () <UITableViewDataSource, UITableViewDelegate>{
    NSUserDefaults *defaults;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *masterClockLabel;

@property NSManagedObjectContext *moc;
@property (nonatomic) NSArray *alarmsArray;

@property DateFormatter *dateFormatter;
@property LocalNotificationConfig *configLocNotif;

@end

@implementation AlarmsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    defaults = [NSUserDefaults standardUserDefaults];
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];

    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    self.moc = delegate.managedObjectContext;

    self.dateFormatter = [DateFormatter new];

    NSTimer *appUpdater = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateApp) userInfo:nil repeats:YES];
    [appUpdater fire];

    [self load];

}

-(void)viewDidAppear:(BOOL)animated{
    [self load];
}



#pragma Update Methods

-(void)updateApp{
    [self updateMasterClock];
    NSLog(@"%lu", [[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
}

-(void)updateMasterClock{
    self.masterClockLabel.text = [self.dateFormatter formatStringFromDate:[NSDate date]];
}

-(void)load {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Alarm"];
    self.alarmsArray = [self.moc executeFetchRequest:request error:nil];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.alarmsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmCell"];
    Alarm *alarm = [self.alarmsArray objectAtIndex:indexPath.row];

    UISwitch *onOffAlarm = [[UISwitch alloc] init];
    [onOffAlarm addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

    cell.textLabel.text = alarm.date;
    cell.detailTextLabel.text = alarm.name;
    cell.accessoryView = onOffAlarm;



    return cell;
}

#pragma mark - schedule local notification

-(void)switchChanged:(id)sender{

    UISwitch *aSwitch = (UISwitch *)sender;
    UITableViewCell *cell = (UITableViewCell *)aSwitch.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Alarm *tempAlarm = [self.alarmsArray objectAtIndex:indexPath.row];
    NSDate *tempDate = [self.dateFormatter formatDateFromString:tempAlarm.date];
    NSString *tempName = tempAlarm.name;

    NSLog(@"tempDate: %@ tempString: %@", tempDate, tempName);

//    [self.dateFormatter formatDateFromString:tempAlarm.date]
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
//    notification.alertBody = @"test";
//    notification.timeZone = [NSTimeZone defaultTimeZone];
//    notification.soundName = @"Alarm_tone.wav";
//    notification.repeatInterval = NSCalendarUnitMinute;

//    UILocalNotification *notification = [[UILocalNotification alloc]init];
//    notification.alertBody = @"TEST";
//    notification.soundName = @"Alarm_tone.wav";
//    notification.repeatInterval = 1;
    UILocalNotification *notificaiton = [[UILocalNotification alloc]init];
    notificaiton.alertBody = @"Duplicate";
    notificaiton.soundName = @"Alarm_tone.wav";
    notificaiton.repeatInterval = NSCalendarUnitSecond;

    if ([sender isOn]) {
        for (int i = 0; i <= 4; i++) {
            notificaiton.fireDate = [NSDate dateWithTimeInterval:i*30 sinceDate:tempDate];

            [[UIApplication sharedApplication] scheduleLocalNotification:notificaiton];

        }
        NSArray *LN = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *loc in LN) {
            NSLog(@"firedate:%@", loc.fireDate);
        }
    } else {
        for (UILocalNotification *notificationToCancel in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            [[UIApplication sharedApplication]cancelAllLocalNotifications];
//            NSString *notificationString = [NSString stringWithFormat:@"%@", notification.userInfo];
//            NSString *notificationToCancelString = [NSString stringWithFormat:@"%@", notificationToCancel.userInfo];
//            if ([notificationString isEqualToString:notificationToCancelString]) {
//                [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
//            }
        }
    }
     NSLog(@"number of notifications: %lu", [[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
}

@end
