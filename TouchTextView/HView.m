//
//  HView.m
//  TouchTextView
//
//  Created by Hung Trinh on 10/23/13.
//  Copyright (c) 2013 Axon Active Vietnam. All rights reserved.
//

#import "HView.h"
#import "HLabel.h"

#define HPhoneticTextViewInset 5
#define HPhoneticTextViewDefaultColor [UIColor blackColor]
#define HPhoneticTextViewHighlightColor [UIColor yellowColor]

#define UILabelMagicTopMargin 5
#define UILabelMagicLeftMargin -5

@implementation HView {
    HLabel *label;
    NSMutableAttributedString *labelText;
    NSRange tappedRange;
}
// ... skipped init methods, very simple, just call through to configureView
- (void)configureView
{
    if(!label) {
        tappedRange.location = NSNotFound;
        tappedRange.length = 0;
        
        label = [[HLabel alloc] initWithFrame:[self bounds]];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setNumberOfLines:0];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTopInset:HPhoneticTextViewInset];
        [label setLeftInset:HPhoneticTextViewInset];
        [label setBottomInset:HPhoneticTextViewInset];
        [label setRightInset:HPhoneticTextViewInset];
        [label setBackgroundColor:[UIColor grayColor]];
        [label setFont:[UIFont systemFontOfSize:15]];
        
        [self addSubview:label];
    }
    
    
//    // Setup tap handling
//    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc]
//                                               initWithTarget:self action:@selector(handleSingleTap:)];
//    singleFingerTap.numberOfTapsRequired = 1;
//    [self addGestureRecognizer:singleFingerTap];
    self.userInteractionEnabled = YES;
}

- (void)setText:(NSString *)text
{
    labelText = [[NSMutableAttributedString alloc] initWithString:text];
    [label setAttributedText:labelText];
}

#pragma mark -
#pragma mark Touch Event Handler
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint tapPoint = [touch locationInView:self];
    [self detectTextAtPosition:tapPoint];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint tapPoint = [touch locationInView:self];
    [self detectTextAtPosition:tapPoint];
}

#pragma mark -
#pragma mark UITapGestureRecognizer
- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // Get the location of the tap, and normalise for the text view (no margins)
        CGPoint tapPoint = [sender locationInView:sender.view];
        [self detectTextAtPosition:tapPoint];
    }
}

#pragma mark -
#pragma mark Helper methods
- (void) detectTextAtPosition:(CGPoint) tapPoint {
    tapPoint.x = tapPoint.x - HPhoneticTextViewInset - UILabelMagicLeftMargin;
    tapPoint.y = tapPoint.y - HPhoneticTextViewInset - UILabelMagicTopMargin;
    
    // Iterate over each word, and check if the word contains the tap point in the correct line
    __block NSString *partialString = @"";
    __block NSString *lineString = @"";
    __block int currentLineHeight = label.font.pointSize;
    [label.text enumerateSubstringsInRange:NSMakeRange(0, [label.text length]) options:NSStringEnumerationByWords usingBlock:^(NSString* word, NSRange wordRange, NSRange enclosingRange, BOOL* stop){
        
        CGSize sizeForText = CGSizeMake(label.frame.size.width - 2 * HPhoneticTextViewInset, label.frame.size.height - 2 * HPhoneticTextViewInset);
        partialString = [NSString stringWithFormat:@"%@ %@", partialString, word];
        
        // Find the size of the partial string, and stop if we've hit the word
        CGSize partialStringSize  = [partialString sizeWithFont:label.font constrainedToSize:sizeForText lineBreakMode:label.lineBreakMode];
        
        if (partialStringSize.height > currentLineHeight) {
            // Text wrapped to new line
            currentLineHeight = partialStringSize.height;
            lineString = @"";
        }
        lineString = [NSString stringWithFormat:@"%@ %@", lineString, word];
        
        CGSize lineStringSize  = [lineString sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
        lineStringSize.width = lineStringSize.width + HPhoneticTextViewInset;
        
        if (tapPoint.x < lineStringSize.width && tapPoint.y > (partialStringSize.height-label.font.pointSize) && tapPoint.y < partialStringSize.height) {
            NSLog(@"Tapped word %@", word);
            if (tappedRange.location != NSNotFound) {
                [labelText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:tappedRange];
            }
            
            tappedRange = wordRange;
            [labelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:tappedRange];
            [label setAttributedText:labelText];
            *stop = YES;
        }
    }];
}

- (void)coloredWord:(NSString *)inputWord {
    [label.text enumerateSubstringsInRange:NSMakeRange(0, [label.text length]) options:NSStringEnumerationByWords usingBlock:^(NSString* word, NSRange wordRange, NSRange enclosingRange, BOOL* stop){

        if ([inputWord caseInsensitiveCompare:word] == NSOrderedSame) {
            [labelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:wordRange];
            [label setAttributedText:labelText];
            
            *stop = YES;
        } else {
            [labelText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:wordRange];
        }
    }];
}
@end
