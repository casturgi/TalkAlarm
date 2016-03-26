//
//  ViewController.m
//  EZAudioRecordVisualizer
//
//  Created by cory Sturgis on 2/19/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController () <UITextFieldDelegate>

@property NSManagedObjectContext *moc;
@property NSURL *fileURL;

@property UIImage *play;
@property UIImage *stop;
@property UIImage *rec;

@end

@implementation ViewController

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//------------------------------------------------------------------------------
#pragma mark - Status Bar Style
//------------------------------------------------------------------------------

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.play = [UIImage imageNamed:@"play-circle-fill"];
    self.stop = [UIImage imageNamed:@"CircledStop"];
    self.rec = [UIImage imageNamed:@"recordIcon"];

    [self.recordButton setImage:self.rec forState:UIControlStateNormal];
    [self.playButton setImage:self.play forState:UIControlStateNormal];

    //
    // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
    // if you don't do this!
    //
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }

    //
    // Get an instance of the app delegate and assign the managed object contexts delegate
    //
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    self.moc = delegate.managedObjectContext;

    //
    // Customizing the audio plot that'll show the current microphone input/recording
    //
    self.recordingAudioPlot.backgroundColor = [self darkerColorForColor:[UIColor greenColor]];
    self.recordingAudioPlot.color           = [UIColor whiteColor];
    self.recordingAudioPlot.plotType        = EZPlotTypeRolling;
    self.recordingAudioPlot.shouldFill      = YES;
    self.recordingAudioPlot.shouldMirror    = YES;
    self.recordingAudioPlot.gain            = 1.4f;

    //
    // Customizing the audio plot that'll show the playback
    //
    self.playingAudioPlot.color = [UIColor lightGrayColor];
    self.playingAudioPlot.plotType = EZPlotTypeRolling;
    self.playingAudioPlot.shouldFill = YES;
    self.playingAudioPlot.shouldMirror = YES;
    self.playingAudioPlot.gain = 1.5f;

    self.fileURL = [self testFilePathURL];

    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
    [self.recordingNameTextField setDelegate:self];
    //
    // Override the output to the speaker. Do this after creating the EZAudioPlayer
    // to make sure the EZAudioDevice does not reset this.
    //
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if (error)
    {
        NSLog(@"Error overriding output to the speaker: %@", error.localizedDescription);
    }

    //
    // Initialize UI components
    //
    self.playButton.enabled = NO;
    self.recordButton.enabled = YES;
    //
    // Setup notifications
    //
    [self setupNotifications];

    //
    // Log out where the file is being written to within the app's documents directory
    //
    NSLog(@"File written to application sandbox's documents directory: %@", self.fileURL);


}

- (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 1.0, 0.0)
                               green:MAX(g - 1.0, 0.0)
                                blue:MAX(b - 1.0, 0.0)
                               alpha:a];
    return nil;
}

//------------------------------------------------------------------------------

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidReachEndOfFile:)
                                                 name:EZAudioPlayerDidReachEndOfFileNotification
                                               object:self.player];
}

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

- (void)playerDidChangePlayState:(NSNotification *)notification
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        EZAudioPlayer *player = [notification object];
        BOOL isPlaying = [player isPlaying];
        if (isPlaying)
        {
            weakSelf.recorder.delegate = nil;
        }
        weakSelf.playingAudioPlot.hidden = !isPlaying;
    });
}

//------------------------------------------------------------------------------

- (void)playerDidReachEndOfFile:(NSNotification *)notification
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.playingAudioPlot clear];
    });
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)playFile:(id)sender
{
    //
    // Update microphone state
    //
    [self.microphone stopFetchingAudio];
    [self.recordingAudioPlot clear];
    //
    // Update recording state
    //
    self.isRecording = NO;
    //
    // Close the audio file
    //
    if (self.recorder)
    {
        [self.recorder closeAudioFile];
    }

    EZAudioFile *audioFile = [EZAudioFile audioFileWithURL:self.fileURL];
    [self.player playAudioFile:audioFile];
}

- (void)toggleRecording:(UIButton *)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    [self.player pause];
    if ([btn isSelected])
    {
        //
        // Create the recorder
        //
        [self.recordingAudioPlot clear];
        [self.microphone startFetchingAudio];
        self.recorder = [EZRecorder recorderWithURL:self.fileURL
                                       clientFormat:[self.microphone audioStreamBasicDescription]
                                           fileType:EZRecorderFileTypeM4A
                                           delegate:self];
        self.playButton.enabled = YES;
//        self.recordButton.imageView.image = [UIImage imageNamed:@"stopButtonIcon"];
    } else {
    }
    self.isRecording = (BOOL)[sender isSelected];
}

- (IBAction)onStopButtonPressed:(id)sender {

    [self.microphone stopFetchingAudio];
    self.isRecording = NO;

    if (self.recorder)
    {
        [self.recorder closeAudioFile];
    }

    [self.player pause]; 
    [self.player seekToFrame:0];
    [self.playingAudioPlot clear];
}

//------------------------------------------------------------------------------
#pragma mark - EZMicrophoneDelegate
//------------------------------------------------------------------------------

//- (void)microphone:(EZMicrophone *)microphone changedPlayingState:(BOOL)isPlaying
//{
//
//}

//------------------------------------------------------------------------------

//#warning Thread Safety
//
// Note that any callback that provides streamed audio data (like streaming
// microphone input) happens on a separate audio thread that should not be
// blocked. When we feed audio data into any of the UI components we need to
// explicity create a GCD block on the main thread to properly get the UI to
// work.
- (void)   microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as an array of float buffer arrays. What does that
    // mean? Because the audio is coming in as a stereo signal the data is split
    // into a left and right channel. So buffer[0] corresponds to the float* data
    // for the left channel while buffer[1] corresponds to the float* data for
    // the right channel.

    //
    // See the Thread Safety warning above, but in a nutshell these callbacks
    // happen on a separate audio thread. We wrap any UI updating in a GCD block
    // on the main thread to avoid blocking that audio flow.
    //
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        // All the audio plot needs is the buffer data (float*) and the size.
        // Internally the audio plot will handle all the drawing related code,
        // history management, and freeing its own resources. Hence, one badass
        // line of code gets you a pretty plot :)
        //
        [weakSelf.recordingAudioPlot updateBuffer:buffer[0]
                                   withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)   microphone:(EZMicrophone *)microphone
        hasBufferList:(AudioBufferList *)bufferList
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    //
    // Getting audio data as a buffer list that can be directly fed into the
    // EZRecorder. This is happening on the audio thread - any UI updating needs
    // a GCD main queue block. This will keep appending data to the tail of the
    // audio file.
    //
    if (self.isRecording)
    {
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
}

//------------------------------------------------------------------------------
#pragma mark - EZRecorderDelegate
//------------------------------------------------------------------------------

- (void)recorderDidClose:(EZRecorder *)recorder
{
    recorder.delegate = nil;
}

//------------------------------------------------------------------------------

- (void)recorderUpdatedCurrentTime:(EZRecorder *)recorder
{
    __weak typeof (self) weakSelf = self;
    NSString *formattedCurrentTime = [recorder formattedCurrentTime];
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.currentTimeLabel.text = formattedCurrentTime;
    });
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlayerDelegate
//------------------------------------------------------------------------------

- (void) audioPlayer:(EZAudioPlayer *)audioPlayer
         playedAudio:(float **)buffer
      withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
         inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.playingAudioPlot updateBuffer:buffer[0]
                                 withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.currentTimeLabel.text = [audioPlayer formattedCurrentTime];
    });
}

//------------------------------------------------------------------------------
#pragma mark - Utility
//------------------------------------------------------------------------------

- (NSArray *)applicationDocuments
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

//------------------------------------------------------------------------------

- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

//------------------------------------------------------------------------------

- (NSURL *)testFilePathURL {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"ddMMMYY_hhmmssa";
    NSString *dateString = [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".m4a"];
    NSLog(@"datestring:%@", dateString);

    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                   [self applicationDocumentsDirectory], dateString]];
}

// resign keyboard when return is tapped
-(BOOL) textFieldShouldReturn:(UITextField *)textField{

    [self.recordingNameTextField resignFirstResponder];
    return YES;
}

//save the recording for management in the previous view controller
- (IBAction)onSaveButtonTapped:(id)sender {

    if (self.recordingNameTextField.text.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please give this recording a name." message:nil preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];

        [self presentViewController:alertController animated:YES completion:nil];
    } else {

    NSManagedObject *recording = [NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:self.moc];

        [recording setValue:self.recordingNameTextField.text forKey:@"name"];
        [recording setValue:[NSString stringWithFormat: @"%@", self.fileURL] forKey:@"url"];


    NSError *error = nil;
    [self.moc save:&error];
    if ([self.moc save:&error] == NO) {
        NSAssert(NO, @"Save should not fail\n%@", [error localizedDescription]);
        abort();
    }

//        [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
    }
}

@end
