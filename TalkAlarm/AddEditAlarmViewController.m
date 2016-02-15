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
#import "DateFormatter.h"

@interface AddEditAlarmViewController () 

@property NSManagedObjectContext *moc;
@property DateFormatter *dateFormatter;

@property (weak, nonatomic) IBOutlet UITextField *alarmNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *mathSnoozeSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *numberOProbSegCont;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property NSString *ringtoneFileName;
@property NSURL *voiceRecordingURL;

@end

@implementation AddEditAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    self.moc = delegate.managedObjectContext;

    self.dateFormatter = [DateFormatter new];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onSaveButtonPressed:(id)sender {

    NSManagedObject *alarm = [NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:self.moc];

    if (self.alarmNameTextField.text.length > 0) {
        [alarm setValue:self.alarmNameTextField.text forKey:@"name"];
    } else if (self.voiceRecordingURL != nil) {
        [alarm setValue:[self.voiceRecordingURL absoluteString] forKey:@"audioURL"];
    } else if(self.ringtoneFileName.length >0){
        [alarm setValue:self.ringtoneFileName forKey:@"ringtoneFileName"];
    }
    
    int num = (int)[self.numberOProbSegCont selectedSegmentIndex] +1;
    [alarm setValue:[NSNumber numberWithInt:num] forKey:@"numberOProblems"];
    [alarm setValue:[self.dateFormatter formatStringFromDate:self.datePicker.date] forKey:@"date"];
    [alarm setValue:[NSNumber numberWithBool:self.mathSnoozeSwitch.on]  forKey:@"mathSnooze"];

    [self.moc save:nil];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCancelButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}


@end
