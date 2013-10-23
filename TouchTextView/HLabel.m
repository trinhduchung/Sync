//
//  HLabel.m
//  TouchTextView
//
//  Created by Hung Trinh on 10/23/13.
//  Copyright (c) 2013 Axon Active Vietnam. All rights reserved.
//

#import "HLabel.h"

#define HLabelDefaultInset 5

@implementation HLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.topInset = HLabelDefaultInset;
        self.bottomInset = HLabelDefaultInset;
        self.rightInset = HLabelDefaultInset;
        self.leftInset = HLabelDefaultInset;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {self.topInset, self.leftInset,
        self.bottomInset, self.rightInset};
    
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
