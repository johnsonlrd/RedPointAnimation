//
//  ViewController.m
//  self.redPointAnimation
//
//  Created by 余曦 on 8/2/15.
//  Copyright (c) 2015 余曦. All rights reserved.
//

#import "ViewController.h"

#define SIZE_ICONIMAGEVIEW 72.0
#define SIZE_REDPOINTVIEW 28.0
#define COLOR_REDPOINT_BACKGROUND [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
#define RADIUS_MAX_STRETCH 100.0

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self layoutViews];
}

-(void) setupViews{
    self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, SIZE_ICONIMAGEVIEW, SIZE_ICONIMAGEVIEW)];
    self.iconImageView.image = [UIImage imageNamed:@"Message"];
    [self.view addSubview:self.iconImageView];
    
    self.redPointView = [[RedPointView alloc] initWithFrame:CGRectMake(0.0, 0.0, SIZE_REDPOINTVIEW, SIZE_REDPOINTVIEW) redPointColor:COLOR_REDPOINT_BACKGROUND maxStretchRadius:RADIUS_MAX_STRETCH];
    [self.view addSubview:self.redPointView];
    
    self.showControlLinesSwitch = [[UISwitch alloc] init];
    [self.showControlLinesSwitch addTarget:self action:@selector(showControlLinesSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.showControlLinesSwitch.on = YES;
    [self.view addSubview:self.showControlLinesSwitch];
    
    self.originalStartPointCircleRadiusSlider = [[UISlider alloc] init];
    self.originalStartPointCircleRadiusSlider.minimumValue = 1.0;
    self.originalStartPointCircleRadiusSlider.maximumValue = 4.0;
    self.originalStartPointCircleRadiusSlider.value = 1.0;
    [self.originalStartPointCircleRadiusSlider addTarget:self action:@selector(originalStartPointCircleRadiusSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.originalStartPointCircleRadiusSlider];
}

-(void) layoutViews{
    if (self.iconImageView) {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.iconImageView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.iconImageView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:SIZE_ICONIMAGEVIEW]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:SIZE_ICONIMAGEVIEW]];
    }
    if (self.redPointView) {
        self.redPointView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.redPointView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.redPointView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.redPointView addConstraint:[NSLayoutConstraint constraintWithItem:self.redPointView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:SIZE_REDPOINTVIEW]];
        [self.redPointView addConstraint:[NSLayoutConstraint constraintWithItem:self.redPointView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:SIZE_REDPOINTVIEW]];
    }
    if (self.showControlLinesSwitch) {
        self.showControlLinesSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.showControlLinesSwitch attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.showControlLinesSwitch attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:40.0]];
        [self.showControlLinesSwitch addConstraint:[NSLayoutConstraint constraintWithItem:self.showControlLinesSwitch attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.showControlLinesSwitch.frame.size.width]];
        [self.showControlLinesSwitch addConstraint:[NSLayoutConstraint constraintWithItem:self.showControlLinesSwitch attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.showControlLinesSwitch.frame.size.height]];
    }
    if (self.originalStartPointCircleRadiusSlider) {
        self.originalStartPointCircleRadiusSlider.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.originalStartPointCircleRadiusSlider attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.showControlLinesSwitch attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.originalStartPointCircleRadiusSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.showControlLinesSwitch attribute:NSLayoutAttributeBottom multiplier:1.0 constant:40.0]];
        [self.originalStartPointCircleRadiusSlider addConstraint:[NSLayoutConstraint constraintWithItem:self.originalStartPointCircleRadiusSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.originalStartPointCircleRadiusSlider.frame.size.width]];
        [self.originalStartPointCircleRadiusSlider addConstraint:[NSLayoutConstraint constraintWithItem:self.originalStartPointCircleRadiusSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.originalStartPointCircleRadiusSlider.frame.size.height]];
    }
}

-(void) showControlLinesSwitchValueChanged:(UISwitch *)sender{
    self.redPointView.isShowControlLines = sender.on;
}

-(void) originalStartPointCircleRadiusSliderValueChanged:(UISlider *)sender{
    struct Circle tmpCircle = [RedPointViewCalculateCenter getCircleFromRect:self.redPointView.frame];
    tmpCircle.radius = SIZE_REDPOINTVIEW / 2.0 * sender.value;
    self.redPointView.frame = [RedPointViewCalculateCenter getRectFromCircle:tmpCircle];
    self.redPointView.maxStretchRadius = RADIUS_MAX_STRETCH * sender.value;
    [self.redPointView setNeedsDisplay];
}

@end
