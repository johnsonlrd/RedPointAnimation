//
//  ViewController.h
//  RedPointAnimation
//
//  Created by 余曦 on 8/2/15.
//  Copyright (c) 2015 余曦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedPointView.h"
#import "RedPointViewCalculateCenter.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) RedPointView *redPointView;
@property (nonatomic, strong) UISwitch *showControlLinesSwitch;

@end

