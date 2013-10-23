//
//  HLabel.m
//  TouchTextView
//
//  Created by Hung Trinh on 10/23/13.
//  Copyright (c) 2013 Axon Active Vietnam. All rights reserved.
//

#import "HLabel.h"

#define HLabelDefaultInset 5

@implementation HLabel {
    NSMutableAttributedString *labelText;
    NSRange tappedRange;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        tappedRange.location = NSNotFound;
        tappedRange.length = 0;
        
        self.topInset = HLabelDefaultInset;
        self.bottomInset = HLabelDefaultInset;
        self.rightInset = HLabelDefaultInset;
        self.leftInset = HLabelDefaultInset;
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

//- (void)setText:(NSString *)text {
//    labelText = [[NSMutableAttributedString alloc] initWithString:text];
//    [self setAttributedText:labelText];
//}

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {self.topInset, self.leftInset,
        self.bottomInset, self.rightInset};
    
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
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
    __block int currentLineHeight = self.font.pointSize;
    [self.text enumerateSubstringsInRange:NSMakeRange(0, [self.text length]) options:NSStringEnumerationByWords usingBlock:^(NSString* word, NSRange wordRange, NSRange enclosingRange, BOOL* stop){
        
        CGSize sizeForText = CGSizeMake(self.frame.size.width - 2 * HPhoneticTextViewInset, self.frame.size.height - 2 * HPhoneticTextViewInset);
        partialString = [NSString stringWithFormat:@"%@ %@", partialString, word];
        
        // Find the size of the partial string, and stop if we've hit the word
        CGSize partialStringSize  = [partialString sizeWithFont:self.font constrainedToSize:sizeForText lineBreakMode:self.lineBreakMode];
        
        if (partialStringSize.height > currentLineHeight) {
            // Text wrapped to new line
            currentLineHeight = partialStringSize.height;
            lineString = @"";
        }
        lineString = [NSString stringWithFormat:@"%@ %@", lineString, word];
        
        CGSize lineStringSize  = [lineString sizeWithFont:self.font constrainedToSize:self.frame.size lineBreakMode:self.lineBreakMode];
        lineStringSize.width = lineStringSize.width + HPhoneticTextViewInset;
        
        if (tapPoint.x < lineStringSize.width && tapPoint.y > (partialStringSize.height-self.font.pointSize) && tapPoint.y < partialStringSize.height) {
            NSLog(@"Tapped word %@", word);
            if (tappedRange.location != NSNotFound) {
                [labelText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:tappedRange];
            }
            
            tappedRange = wordRange;
            [labelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:tappedRange];
            [self setAttributedText:labelText];
            *stop = YES;
        }
    }];
}

@end
