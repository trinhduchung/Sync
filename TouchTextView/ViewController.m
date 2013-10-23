//
//  ViewController.m
//  TouchTextView
//
//  Created by Hung Trinh on 10/23/13.
//  Copyright (c) 2013 Axon Active Vietnam. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "HView.h"
#import "HLabel.h"
#import "Subtitle.h"
#import "TFHpple.h"

@interface ViewController () {
    
}
@property (nonatomic, strong) HView *simpleView;
@property (nonatomic, strong) HLabel *simpleLabel;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) Subtitle *subtitle;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSError *error = nil;
    NSURL *textURL = [[NSBundle mainBundle] URLForResource:@"text" withExtension:@"txt"];
    NSString * text = [NSString stringWithContentsOfURL:textURL encoding:NSUTF8StringEncoding error:&error];
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(320, 480) lineBreakMode:NSLineBreakByCharWrapping];
    self.simpleView = [[HView alloc] initWithFrame:CGRectMake(0, 20, size.width + 10, size.height + 10)];
    [self.simpleView configureView];
    [self.simpleView setText:text];
    
    [self.view addSubview:self.simpleView];
    
    self.simpleLabel = [[HLabel alloc] initWithFrame:CGRectMake(0, 20, size.width + 10, size.height + 10)];
    [self.simpleLabel setText:text];
    [self.simpleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.simpleLabel setNumberOfLines:0];
    [self.simpleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.simpleLabel setBackgroundColor:[UIColor grayColor]];
    
//    [self.view addSubview:self.simpleLabel];
    //Declare the audio file location and settup the player
    NSURL *audioFileLocationURL = [[NSBundle mainBundle] URLForResource:@"She's Gone - Steelheart" withExtension:@"mp3"];
    
//    AVPlayerItem * item = [[AVPlayerItem alloc] initWithURL:audioFileLocationURL];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileLocationURL error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
//        [[self volumeControl] setEnabled:NO];
//        [[self playPauseButton] setEnabled:NO];
//        [[self alertLabel] setText:@"Unable to load file"];
//        [[self alertLabel] setHidden:NO];
    } else {
//        [[self alertLabel] setText:[NSString stringWithFormat:@"%@ has loaded", @"HeadspinLong.caf"]];
//        [[self alertLabel] setHidden:NO];
        //Make sure the system follows our playback status
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        //Load the audio into memory
        [self.audioPlayer prepareToPlay];
        
        self.audioPositon.minimumValue = 0.0;
        self.audioPositon.maximumValue = self.audioPlayer.duration;
        
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    }
    //
    /*
    CGFloat interval = 0.0;
    CMTime playerDuration = [self playerItemDuration]; // return player duration.
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([self.audioPositon bounds]);
        interval = 0.5f * duration / width;
    }
    
    // Update the scrubber during normal playback.
    id timeObserver = [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                         queue:NULL
                                                    usingBlock:
                     ^(CMTime time)
                     {
                         [self syncScrubber];
                     }];
    */
    //get link
    NSURL *subURL = [[NSBundle mainBundle] URLForResource:@"sub" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:subURL];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    Subtitle *sub = [Subtitle initWithDictionary:jsonDict];
    self.subtitle = sub;
    
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"search" withExtension:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfURL:htmlURL];
    TFHpple *htmlDoc = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSString *songsXpathQueryString = @"//a[@class='_trackLink']";
    NSArray * songNodes = [htmlDoc searchWithXPathQuery:songsXpathQueryString];
    for (TFHppleElement * element in songNodes) {
        NSLog(@"%@", [element objectForKey:@"title"]);
        NSLog(@"mp3.zing.vn%@", [element objectForKey:@"href"]);
    }
    
    NSURL *mp3URL = [[NSBundle mainBundle] URLForResource:@"mp3Detail" withExtension:@"html"];
    NSData *mp3Data = [NSData dataWithContentsOfURL:mp3URL];
    TFHpple *mp3Doc = [[TFHpple alloc] initWithHTMLData:mp3Data];
    NSString *mp3XpathQueryString = @"//p[@class='_lyricContent rows4']";
    NSArray * mp3Nodes = [mp3Doc searchWithXPathQuery:mp3XpathQueryString];
    for (TFHppleElement * element in mp3Nodes) {
        NSLog(@"%@", [element text]);
    }
}
/*
- (CMTime)playerItemDuration
{
    AVPlayerItem *thePlayerItem = [self.audioPlayer currentItem];
    if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        
        return([thePlayerItem duration]);
    }
    
    return(kCMTimeInvalid);
}

- (void)syncScrubber
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        self.audioPositon.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration) && (duration > 0))
    {
        float minValue = [ self.audioPositon minimumValue];
        float maxValue = [ self.audioPositon maximumValue];
        double time = CMTimeGetSeconds([self.audioPlayer currentTime]);
        [self.audioPositon setValue:(maxValue - minValue) * time / duration + minValue];
    }
}
 */
 
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSRange range = textView.selectedRange;
    if(range.location < textView.text.length)
    {
        NSString * firstHalfString = [textView.text substringToIndex:range.location];
        
        NSString *temp = @"s";
        CGSize s1 = [temp sizeWithFont:[UIFont systemFontOfSize:15]
                     constrainedToSize:CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT)  // - 40 For cell padding
                         lineBreakMode:NSLineBreakByWordWrapping]; // enter you textview font size
        
        CGSize s = [firstHalfString sizeWithFont:[UIFont systemFontOfSize:15]
                               constrainedToSize:CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT)  // - 40 For cell padding
                                   lineBreakMode:NSLineBreakByWordWrapping]; // enter you textview font size
        
        //Here is the frame of your word in text view.
//        NSLog(@"xcoordinate=%f, ycoordinate =%f, width=%f,height=%f",s.width,s.height,s1.width,s1.height);
        
        CGRect rectforword = CGRectMake(s.width, s.height, s1.width, s1.height);
        // rectforword is rect of yourword
        NSLog(@"%@", NSStringFromCGRect(rectforword));
        
    }
    else
    {
        // Do what ever you want to do
        
    }
}

- (void) updateSlider {
    if (self.audioPlayer.isPlaying) {
        self.audioPositon.value = self.audioPlayer.currentTime;
        //
        for (Timeline *timeline in self.subtitle.listTimes) {
            if (timeline.time == roundf(self.audioPlayer.currentTime)) {
                NSLog(@"sub ------ %@", timeline.text);
                [self.simpleView coloredWord:timeline.text];
            }
        }
    }
}

- (IBAction)didStartSyncPressed:(id)sender {
    [self playAudio];
}

- (IBAction)didPauseSyncPressed:(id)sender {
    [self pauseAudio];
}

- (IBAction)didResumeSyncPressed:(id)sender {
    [self togglePlayPause];
}

- (IBAction)didPlayPressed:(id)sender {
    [self playAudio];
}

- (IBAction)valueChangeSliderTimer:(id)sender {
//    [self.audioPlayer pause];
    self.audioPlayer.currentTime = self.audioPositon.value;
//    [self.audioPlayer play];
    /*
//    isPlaying = FALSE;
//    [btnPauseAndPlay setTitle:@"Play" forState:UIControlStateNormal];
    
    float timeInSecond = self.audioPositon.value;
    
    timeInSecond *= 1000;
    CMTime cmTime = CMTimeMake(timeInSecond, 1000);
    
//    [self.audioPlayer seekToTime:cmTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
     */
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //End recieving events
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)playAudio {
    //Play the audio and set the button to represent the audio is playing
    [self.audioPlayer play];
//    [playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
}
- (void)pauseAudio {
    //Pause the audio and set the button to represent the audio is paused
    [self.audioPlayer pause];
//    [playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
}
- (void)togglePlayPause {
    //Toggle if the music is playing or paused
    [self playAudio];
    /*
    if (!self.audioPlayer.playing) {
        [self playAudio];
    } else if (self.audioPlayer.playing) {
        [self pauseAudio];
    }
     */
}
//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self playAudio];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self pauseAudio];
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self togglePlayPause];
        }
    }
}


@end
