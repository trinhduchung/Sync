//
//  ViewController.h
//  TouchTextView
//
//  Created by Hung Trinh on 10/23/13.
//  Copyright (c) 2013 Axon Active Vietnam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *audioPositon;
@property (weak, nonatomic) IBOutlet UIButton *btnStartSync;
@property (weak, nonatomic) IBOutlet UIButton *btnPauseSync;
@property (weak, nonatomic) IBOutlet UIButton *btnResumeSync;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
- (IBAction)didStartSyncPressed:(id)sender;
- (IBAction)didPauseSyncPressed:(id)sender;
- (IBAction)didResumeSyncPressed:(id)sender;
- (IBAction)didPlayPressed:(id)sender;
- (IBAction)valueChangeSliderTimer:(id)sender;

@end
