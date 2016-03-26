//
//  SnoozeButton.m
//  TalkAlarm
//
//  Created by cory Sturgis on 3/10/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "SnoozeButton.h"
#import "AlarmsViewController.h"


@implementation SnoozeButton

-(void)awakeFromNib{
    self.count = 5;
    [self.snoozeButton setEnabled:NO];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeButtonLabel) userInfo:nil repeats:YES];
    [self.countDownTimer fire];
}

-(void)changeButtonLabel{
    if (self.count == 0) {
        [self.snoozeButton setTitle:@"Snooze" forState:UIControlStateNormal];
        [self.snoozeButton setEnabled:YES];
        [self.countDownTimer invalidate];
    } else {
        [self.snoozeButton setTitle:[NSString stringWithFormat:@"%d",self.count] forState:UIControlStateNormal];
        self.count -= 1;
    }

}

//add a five second timer that enables the snooze button after it is done counting down

- (IBAction)onSnoozeButtonPressed:(UIButton *)sender {

    //navigate to the initial view controller when snooze is pressed
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"navController"];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}



@end
