//
//  RedPointView.h
//  RedPointAnimation
//
//  Created by 余曦 on 8/2/15.
//  Copyright (c) 2015 余曦. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RedPointViewDelegate <NSObject>

-(void) handleLongPressGR:(UILongPressGestureRecognizer *)longPressGR;

@end

@interface RedPointView : UIView

@property (nonatomic, strong) UIColor *redPointColor;
@property CGFloat maxStretchRadius;
@property (nonatomic, strong) id<RedPointViewDelegate> redPointViewDelegate;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGR;
@property  BOOL isShowControlLines;

-(id) initWithFrame:(CGRect)frame redPointColor:(UIColor *)redPointColor maxStretchRadius:(CGFloat)maxStretchRadius;
    
@end
