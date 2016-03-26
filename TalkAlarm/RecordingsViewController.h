//
//  RecordingsViewController.h
//  EZAudioRecordVisualizer
//
//  Created by cory Sturgis on 2/19/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recording.h"

@protocol RecordingsViewControllerDelegate <NSObject>

-(void)addRecording:(Recording *)recording;

@end

@interface RecordingsViewController : UIViewController

@property (nonatomic, assign) id <RecordingsViewControllerDelegate>recDelegate;

@end
