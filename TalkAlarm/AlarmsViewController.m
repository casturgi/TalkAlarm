//
//  AlarmsViewController.m
//  TalkAlarm
//
//  Created by cory Sturgis on 2/8/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "AppDelegate.h"
#import "AlarmsViewController.h"
#import "Alarm.h"
#import "Ringtone.h"
#import "Recording.h"
#import <iAd/iAd.h>

@interface AlarmsViewController () <UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate>{
    NSUserDefaults *defaults;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *masterClockLabel;

@property NSManagedObjectContext *moc;
@property (nonatomic) NSArray *alarmsArray;

@property NSDateFormatter *displayDateFormatter;
@property NSDateFormatter *scheduleDateFormatter;

@property BOOL bannerIsVisible;
@property ADBannerView *adBanner;
//@property DateFormatter *dateFormatter;
//@property LocalNotificationConfig *configLocNotif;

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

    self.displayDateFormatter = [NSDateFormatter new];
    [self.displayDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [self.displayDateFormatter setLocale:[NSLocale currentLocale]];
    [self.displayDateFormatter setDateFormat:@"h:mm a"];
    [self.displayDateFormatter setFormatterBehavior:NSDateFormatterBehaviorDefault];

    self.scheduleDateFormatter = [NSDateFormatter new];
    [self.scheduleDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [self.scheduleDateFormatter setLocale:[NSLocale currentLocale]];
    [self.scheduleDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [self.scheduleDateFormatter setFormatterBehavior:NSDateFormatterBehaviorDefault];

    self.bannerIsVisible = NO;

//    self.dateFormatter = [DateFormatter new];

    NSTimer *appUpdater = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateApp) userInfo:nil repeats:YES];
    [appUpdater fire];

    [self load];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [self load];
    self.adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 50)];
    [self.view addSubview:self.adBanner];

}

#pragma iAd delegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_bannerIsVisible)
    {
        // If banner isn't part of view hierarchy, add it
        if (_adBanner.superview == nil)
        {
            [self.view addSubview:_adBanner];
        }

        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];

        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);

        [UIView commitAnimations];

        _bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");

    if (_bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];

        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);

        [UIView commitAnimations];

        _bannerIsVisible = NO;
    }
}

#pragma Update Methods

-(void)updateApp{
    [self updateMasterClock];
}

-(void)updateMasterClock{
    self.masterClockLabel.text = [self.displayDateFormatter stringFromDate:[NSDate date]];
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
    NSDate *alarmDate = [self.scheduleDateFormatter dateFromString:alarm.date];
    NSString *alarmString = [self.displayDateFormatter stringFromDate:alarmDate];
    NSLog(@"alarmString: %@", alarmString);


    UISwitch *onOffAlarm = [[UISwitch alloc] init];
    [onOffAlarm addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

    cell.textLabel.text = alarmString;
    cell.detailTextLabel.text = alarm.name;
    cell.accessoryView = onOffAlarm;

    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    [self.moc deleteObject:[self.alarmsArray objectAtIndex:indexPath.row]];
    [self load];
}

#pragma mark - schedule local notification

-(void)switchChanged:(id)sender{

    UISwitch *aSwitch = (UISwitch *)sender;
    UITableViewCell *cell = (UITableViewCell *)aSwitch.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Alarm *tempAlarm = [self.alarmsArray objectAtIndex:indexPath.row];
    NSDate *tempDate = [self.scheduleDateFormatter dateFromString:tempAlarm.date];
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", tempAlarm.date] forKey:@"alarmDateString"];
    NSTimeInterval subsequentNotif = 10;


    UILocalNotification *notificaiton = [[UILocalNotification alloc]init];
    notificaiton.timeZone = [[NSCalendar currentCalendar] timeZone];
    notificaiton.fireDate = tempDate;
    notificaiton.alertBody = @"Self-Talk Alarm1";
    notificaiton.soundName = tempAlarm.ringtone.url;
    notificaiton.repeatInterval = NSCalendarUnitSecond;
    notificaiton.userInfo = infoDict;

    UILocalNotification *notificaiton1 = [[UILocalNotification alloc]init];
    NSDate *date1 = [NSDate dateWithTimeInterval:subsequentNotif sinceDate:tempDate];
    notificaiton.timeZone = [[NSCalendar currentCalendar] timeZone];
    notificaiton1.fireDate = date1;
    notificaiton1.alertBody = @"Self-Talk Alarm2";
    notificaiton1.soundName = tempAlarm.ringtone.url;
    notificaiton1.repeatInterval = NSCalendarUnitSecond;
    notificaiton1.userInfo = infoDict;

    UILocalNotification *notificaiton2 = [[UILocalNotification alloc]init];
        NSDate *date2 = [NSDate dateWithTimeInterval:subsequentNotif sinceDate:date1];
    notificaiton2.timeZone = [[NSCalendar currentCalendar] timeZone];
    notificaiton2.fireDate = date2;
    notificaiton2.alertBody = @"Self-Talk Alarm3";
    notificaiton2.soundName = tempAlarm.ringtone.url;
    notificaiton2.repeatInterval = NSCalendarUnitSecond;
    notificaiton2.userInfo = infoDict;

    UILocalNotification *notificaiton3 = [[UILocalNotification alloc]init];
    NSDate *date3 = [NSDate dateWithTimeInterval:subsequentNotif sinceDate:date2];
    notificaiton3.timeZone = [[NSCalendar currentCalendar] timeZone];
    notificaiton3.fireDate = date3;
    notificaiton3.alertBody = @"Self-Talk Alarm4";
    notificaiton3.soundName = tempAlarm.ringtone.url;
    notificaiton3.repeatInterval = NSCalendarUnitSecond;
    notificaiton3.userInfo = infoDict;

    UILocalNotification *notificaiton4 = [[UILocalNotification alloc]init];
    NSDate *date4 = [NSDate dateWithTimeInterval:subsequentNotif sinceDate:date3];
    notificaiton4.timeZone = [[NSCalendar currentCalendar] timeZone];
    notificaiton4.fireDate = date4;
    notificaiton4.alertBody = @"Self-Talk Alarm5";
    notificaiton4.soundName = tempAlarm.ringtone.url;
    notificaiton4.repeatInterval = NSCalendarUnitSecond;
    notificaiton4.userInfo = infoDict;

    UILocalNotification *notificaiton5 = [[UILocalNotification alloc]init];
    NSDate *date5 = [NSDate dateWithTimeInterval:subsequentNotif sinceDate:date4];
    notificaiton5.timeZone = [[NSCalendar currentCalendar] timeZone];
    notificaiton5.fireDate = date5;
    notificaiton5.alertBody = @"Self-Talk Alarm6";
    notificaiton5.soundName = tempAlarm.ringtone.url;
    notificaiton5.repeatInterval = NSCalendarUnitSecond;
    notificaiton5.userInfo = infoDict;

    if ([sender isOn]){

        if ([tempDate  compare:[NSDate date]] == NSOrderedDescending) {
            [[UIApplication sharedApplication] scheduleLocalNotification:notificaiton];
            [[UIApplication sharedApplication] scheduleLocalNotification:notificaiton1];
            [[UIApplication sharedApplication] scheduleLocalNotification:notificaiton2];
            [[UIApplication sharedApplication] scheduleLocalNotification:notificaiton3];
            [[UIApplication sharedApplication] scheduleLocalNotification:notificaiton4];
            [[UIApplication sharedApplication] scheduleLocalNotification:notificaiton5];
        } else{

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please select a date in the future. We're still working on the time machine that'll allow us to wake you up yesterday." message:nil preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [aSwitch setOn:NO];
            }];
            [alertController addAction:ok];

            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        for (UILocalNotification *notificationToCancel in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            NSString *notificationString = [NSString stringWithFormat:@"%@", notificaiton.userInfo];
            NSString *notificationToCancelString = [NSString stringWithFormat:@"%@", notificationToCancel.userInfo];
            if ([notificationString isEqualToString:notificationToCancelString]) {
                        [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
                    }
        }
    }


     NSLog(@"number of notifications: %lu", [[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
}

@end
