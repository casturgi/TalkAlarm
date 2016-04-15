//
//  AddEditAlarmViewController.m
//  TalkAlarm
//
//  Created by cory Sturgis on 2/8/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "AddEditAlarmViewController.h"
#import "AlarmsViewController.h"
#import "AppDelegate.h"
//#import "DateFormatter.h"
#import "Recording.h"
#import "RecordingsViewController.h"
#import "Ringtone.h"
#import "ChooseRingtoneTableViewController.h"
#import "RingtoneHelper.h"
#import <iAd/iAd.h>

@interface AddEditAlarmViewController () <RecordingsViewControllerDelegate, ChooseRingtoneTableViewControllerDelegate, ADBannerViewDelegate>

@property NSManagedObjectContext *moc;
//@property DateFormatter *dateFormatter;
@property NSDateFormatter *dateForm;

@property (weak, nonatomic) IBOutlet UITextField *alarmNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *mathSnoozeSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *numberOProbSegCont;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *voiceRecordingLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedRingtoneLabel;

@property Ringtone *selectedRingtone;
@property Recording *selectedRecording;
@property RingtoneHelper *ringtoneHelper;

@property BOOL bannerIsVisible;
@property ADBannerView *adBanner;

@end

@implementation AddEditAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    self.moc = delegate.managedObjectContext;

    [self.alarmNameTextField setDelegate:self];

    self.dateForm = [NSDateFormatter new];
    self.dateForm.timeZone = [NSTimeZone defaultTimeZone];
    self.dateForm.timeStyle = NSDateFormatterShortStyle;
    self.dateForm.dateStyle = NSDateFormatterShortStyle;
    [self.dateForm setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 50)];
    [self.view addSubview:self.adBanner];

    if (self.passedAlarm != nil) {
        self.alarmNameTextField.text = self.passedAlarm.name;

        if (self.passedAlarm.mathSnooze){
            [self.mathSnoozeSwitch setEnabled:YES];
        }

        self.numberOProbSegCont.selectedSegmentIndex = self.passedAlarm.numberOProblems.integerValue;

        [self.datePicker setDate:[self.dateForm dateFromString:self.passedAlarm.date]];

        self.voiceRecordingLabel.text = self.passedAlarm.recording.name;
        self.selectedRingtoneLabel.text = self.passedAlarm.ringtone.name;
        self.selectedRingtone = self.passedAlarm.ringtone;
        self.selectedRecording = self.passedAlarm.recording;
    }

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSaveButtonPressed:(id)sender {

    NSManagedObject *alarm = [NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:self.moc];

    if (self.selectedRingtone == nil) {

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Make sure that you have selected an alarm tone to wake you up!" message:nil preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        }];
        [alertController addAction:ok];

        [self presentViewController:alertController animated:YES completion:nil];

    } else if ([self.datePicker.date compare:[NSDate date]] != NSOrderedDescending) {

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please select a date in the future. We're still working on the time machine that'll allow us to wake you up yesterday." message:nil preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:ok];

        [self presentViewController:alertController animated:YES completion:nil];

    } else {

        int num = (int)[self.numberOProbSegCont selectedSegmentIndex] +1;
        NSLog(@"%d", num);

        NSString *dateString = [self.dateForm stringFromDate:self.datePicker.date];
        NSLog(@"Picker Date: %@", self.datePicker.date);
        NSLog(@"Picker Date String : %@", dateString);

        [alarm setValue:self.selectedRingtone forKey:@"ringtone"];
        [alarm setValue:self.selectedRecording forKey:@"recording"];
        [alarm setValue:self.alarmNameTextField.text forKey:@"name"];

        [alarm setValue:[NSNumber numberWithInt:num] forKey:@"numberOProblems"];
        [alarm setValue:dateString forKey:@"date"];
        [alarm setValue:[NSNumber numberWithBool:self.mathSnoozeSwitch.on]  forKey:@"mathSnooze"];

        [self.moc save:nil];
        
        [self.navigationController popViewControllerAnimated:YES];

    }
}

- (IBAction)onCancelButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"VoiceRecordSegue"]) {
        RecordingsViewController *recVC = segue.destinationViewController;
        recVC.recDelegate = self;
    } else if ([segue.identifier isEqualToString:@"RingtoneSegue"]){
        ChooseRingtoneTableViewController *ringVC = segue.destinationViewController;
        ringVC.ringtoneDelegate = self;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.alarmNameTextField resignFirstResponder];
    return YES;
}

-(void)addRecording:(Recording *)recording{

    self.selectedRecording = recording;
    self.voiceRecordingLabel.text = self.selectedRecording.name;

}

-(void)addRingtone:(RingtoneHelper *)ringtone{

    self.selectedRingtone = [NSEntityDescription insertNewObjectForEntityForName:@"Ringtone" inManagedObjectContext:self.moc];
    [self.selectedRingtone setName:ringtone.name];
    [self.selectedRingtone setUrl:ringtone.fileName];

    self.selectedRingtoneLabel.text = self.selectedRingtone.name;
}


@end
