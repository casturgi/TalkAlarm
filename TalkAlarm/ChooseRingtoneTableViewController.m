//
//  ChooseRingtoneTableViewController.m
//  TalkAlarm
//
//  Created by cory Sturgis on 2/9/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "ChooseRingtoneTableViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ChooseRingtoneTableViewController () <AVAudioPlayerDelegate>

@property NSArray *ringtoneArray;
@property AVAudioPlayer *audioPlayer;
@property int playCount;
@property UIImage *play;



@end

@implementation ChooseRingtoneTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [audioSession setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }

    self.playCount = 0;

    self.ringtoneArray = @[[[RingtoneHelper alloc] initWithName:@"Drum alarm" andFileName:@"alarm_drum30.wav"],
                           [[RingtoneHelper alloc] initWithName:@"Analog alarm" andFileName:@"analog_alarm30.wav"],
                           [[RingtoneHelper alloc] initWithName:@"Gentle piano" andFileName:@"best_wake_up_tone30.wav"],
                           [[RingtoneHelper alloc] initWithName:@"Dubstep alarm" andFileName:@"Dubstep_alarm30.wav"],
                           [[RingtoneHelper alloc] initWithName:@"Elegant alarm" andFileName:@"elegant_ringtone30.wav"],
                           [[RingtoneHelper alloc] initWithName:@"Matrix alarm" andFileName:@"matrix_alarm30.wav"],
                           [[RingtoneHelper alloc] initWithName:@"Nuclear alarm" andFileName:@"nuclear_alarm30.wav"],
                           [[RingtoneHelper alloc] initWithName:@"Rooster alarm" andFileName:@"rooster_alarm30.1.wav"],
                           [[RingtoneHelper alloc] initWithName:@"Electro alarm" andFileName:@"russian_electro30.wav"],
                           [[RingtoneHelper alloc] initWithName:@"Soft alarm" andFileName:@"soft_alarm30.wav"],
                           [[RingtoneHelper alloc] initWithName:@"Diving Submarine alarm" andFileName:@"submarine_alarm30.wav"],
                           [[RingtoneHelper alloc] initWithName:@"Chirpy alarm" andFileName:@"wake_up30.wav"],
                           [[RingtoneHelper alloc] initWithName:@"Jungle alarm" andFileName:@"xperia_z_alarm30.wav"]];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ringtoneArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RingtoneCell" forIndexPath:indexPath];
    RingtoneHelper *ring = [self.ringtoneArray objectAtIndex:indexPath.row];
    UIButton *playPauseButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 60, 60)];
    playPauseButton.userInteractionEnabled =YES;
    [playPauseButton setTag:5];
    [playPauseButton setTintColor:[UIColor blueColor]];

    self.play = [UIImage imageNamed:@"play-circle-fill.png"];
    UIImage *stop = [UIImage imageNamed:@"stopButtonIcon.png"];

    [playPauseButton setImage:self.play forState:UIControlStateNormal];
    [playPauseButton setImage:stop forState:UIControlStateSelected];
    [playPauseButton addTarget:self action:@selector(playPauseBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:22.0]];
    cell.accessoryView = playPauseButton;
    cell.textLabel.text = ring.name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController popViewControllerAnimated:YES];
    [self.ringtoneDelegate addRingtone:[self.ringtoneArray objectAtIndex:indexPath.row]];
}

-(void)playPauseBtnPress:(UIButton *)sender{

    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    UITableViewCell *cell = (UITableViewCell *)button.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    RingtoneHelper *rec = [self.ringtoneArray objectAtIndex:indexPath.row];

    NSLog(@"ringtone file: %@", rec.fileName);
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:rec.fileName withExtension:@""] error:&error];

    //configure the audioplayer to play when a button is pressed
    self.audioPlayer.delegate = self;
    if (error){
        NSLog(@"could not play audio file. %@", error.localizedDescription);
    }

    if ([button isSelected]) {
        [self.audioPlayer play];
    } else if (![button isSelected]){
        [self.audioPlayer stop];
    }

    //iterate through all of the buttons and change their state to normal if they are not currently triggering an audio file
    for (UITableViewCell *playButtonResetCell in self.tableView.visibleCells){
        if ([self.tableView indexPathForCell:playButtonResetCell] != indexPath) {
            UIButton *playButton = [playButtonResetCell.accessoryView viewWithTag:5];
            [playButton setSelected:NO];
        }
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.tableView reloadData];
}

@end
