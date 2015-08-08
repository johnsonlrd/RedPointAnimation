//
//  RedPointView.h
//  RedPointAnimation
//
//  Created by 余曦 on 8/2/15.
//  Copyright (c) 2015 余曦. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : int {
    RedPointStateOrignal = 0,
    RedPointStateStretch,
    RedPointStateOutOfStretchRadius,
    RedPointStateBombing,
    RedPointStateSpring
} RedPointState;


@protocol RedPointViewDelegate <NSObject>

-(void) bombed;

@end



@interface RedPointView : UIView

@property (nonatomic, strong) UIColor *redPointColor;
@property (nonatomic, assign) CGFloat maxStretchRadius;
@property (nonatomic, assign) BOOL isShowControlLines;
@property (nonatomic, strong) id<RedPointViewDelegate> redPointViewDelegate;

-(id) initWithFrame:(CGRect)frame redPointColor:(UIColor *)redPointColor maxStretchRadius:(CGFloat)maxStretchRadius;
    
@end
