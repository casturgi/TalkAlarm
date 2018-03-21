//
//  RecordingsViewController.m
//  EZAudioRecordVisualizer
//
//  Created by cory Sturgis on 2/19/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "RecordingsViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "ViewController.h"
#import <iAd/iAd.h>

@interface RecordingsViewController () <UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate, ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *recordingsArray;
@property NSManagedObjectContext *moc;
@property (nonatomic, strong) EZAudioPlayer *player;
@property (nonatomic, strong) EZAudioFile *audioFile;
@property AVAudioPlayer *audioPlayer;

@property BOOL bannerIsVisible;
@property ADBannerView *adBanner;

@end

@implementation RecordingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Initialize an instance of the the app delegate
//    id delegate = [[UIApplication sharedApplication]delegate];
//    self.moc = delegate.managedObjectContext;
    self.moc = [self managedObjectContext];
    self.recordingsArray = [NSMutableArray new];

    //Initialize the audio session and handle any errors that occurr
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

    //load saved recordings into the recordings array
    [self load];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 50)];

    [self.tableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self load];
}

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
        NSLog(@"successfully retrieved delegate");
    }
    return context;
}

#pragma iAd delegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_bannerIsVisible)
    {
        if (_adBanner.superview == nil)
        {
        }

        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];

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

        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);

        [UIView commitAnimations];
        
        _bannerIsVisible = NO;
    }
}

#pragma mark - Set up notifications

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeAudioFile:)
                                                 name:EZAudioPlayerDidChangeAudioFileNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeOutputDevice:)
                                                 name:EZAudioPlayerDidChangeOutputDeviceNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:self.player];
}

- (void)audioPlayerDidChangeAudioFile:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player changed audio file: %@", [player audioFile]);
}

- (void)audioPlayerDidChangeOutputDevice:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player changed output device: %@", [player device]);
}

- (void)audioPlayerDidChangePlayState:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player change play state, isPlaying: %i", [player isPlaying]);
}

#pragma Core Data Methods

-(void)load {
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Recording"];
    NSArray *mocRecordingsArray = [self.moc executeFetchRequest:request error:&error];
    for (int i = 0; i < mocRecordingsArray.count; i++){
        NSLog(@"recording URL: %@", [mocRecordingsArray objectAtIndex:i]);
    }
    [self.recordingsArray removeAllObjects];
    [self.recordingsArray addObjectsFromArray:mocRecordingsArray];
    NSLog(@"number of recordings in array: %lu", (unsigned long)self.recordingsArray.count);
    NSLog(@"Number of recordings in MOC: %lu", (unsigned long)mocRecordingsArray.count);
    [self.tableView reloadData];
}

#pragma tableView Delegate Methods


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recordingsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecCell"];
    Recording *rec = [self.recordingsArray objectAtIndex:indexPath.row];
    UIButton *playPauseButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 60, 60)];
    playPauseButton.userInteractionEnabled = YES;
    playPauseButton.tag = 5;

    UIImage *play = [UIImage imageNamed:@"play-circle-fill.png"];
    UIImage *stop = [UIImage imageNamed:@"CircledStop"];

    [playPauseButton setImage:play forState:UIControlStateNormal];
    [playPauseButton setImage:stop forState:UIControlStateSelected];
    [playPauseButton addTarget:self action:@selector(playPauseBtnPress:) forControlEvents:UIControlEventTouchUpInside];

    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:40.0]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    cell.accessoryView = playPauseButton;
    cell.textLabel.text = rec.name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController popViewControllerAnimated:YES];
    [self.recDelegate addRecording:[self.recordingsArray objectAtIndex:indexPath.row]];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    [self.moc deleteObject:[self.recordingsArray objectAtIndex:indexPath.row]];
    [self load];
}

#pragma AVFoundation methods

-(void)playPauseBtnPress:(UIButton *)sender{

    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    UITableViewCell *cell = (UITableViewCell *)button.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Recording *rec = [self.recordingsArray objectAtIndex:indexPath.row];

    NSError *error;

    
    NSString *urlString = [NSString stringWithFormat:@"file://%@%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], rec.url];
    NSLog(@"REC.URL: %@", urlString);

    //initalize and set the audio player to play the file when the sender is tapped
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString: urlString] error:&error];
    self.audioPlayer.delegate = self;
    if (error){
        NSLog(@"could not play audio file. %@", error.localizedDescription);
    }

    if ([button isSelected]) {
        [self.audioPlayer play];
    } else if (![button isSelected]){
        [self.audioPlayer stop];
    } else if (self.audioPlayer.url != [NSURL URLWithString:rec.url]){
        button.selected = !button.selected;
    }

    //iterate through all of the buttons being and change their state to normal if they are not currently triggering an audio file
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

#pragma segue methods




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
