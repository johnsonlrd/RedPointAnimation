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
    
    self.redPointView = [[RedPointView alloc] initWithFrame:CGRectMake(0.0, 0.0, SIZE_REDPOINTVIEW, SIZE_REDPOINTVIEW)];
    [self.view addSubview:self.redPointView];
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
}

@end
