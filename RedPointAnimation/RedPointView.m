//
//  RedPointView.m
//  RedPointAnimation
//
//  Created by 余曦 on 8/2/15.
//  Copyright (c) 2015 余曦. All rights reserved.
//

#import "RedPointView.h"

#define COLOR_BACKGROUND [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]

@implementation RedPointView

-(id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

-(void) setupView{
    self.backgroundColor = COLOR_BACKGROUND;
    self.layer.cornerRadius = self.frame.size.width / 2.0;
}

@end
