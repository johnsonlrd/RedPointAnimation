//
//  RedPointView.m
//  RedPointAnimation
//
//  Created by 余曦 on 8/2/15.
//  Copyright (c) 2015 余曦. All rights reserved.
//

#import "RedPointView.h"
#import "RedPointViewDelegate.h"
#import "RedPointViewCalculateCenter.h"


@implementation RedPointView{
    struct Circle startPointCircle;
    struct Circle moveToPointCircle;
    CGRect originFrame;
}

-(id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addGesture];
        [self initDelegate];
    }
    return self;
}

-(void) initDelegate{
    RedPointViewDelegate *redPointViewDelegate = [[RedPointViewDelegate alloc] init];
    self.redPointViewDelegate = redPointViewDelegate;
}

-(void) addGesture{
    self.longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGR)];
    self.longPressGR.minimumPressDuration = 0.001;
    [self addGestureRecognizer:self.longPressGR];
}

-(void) handleLongPressGR{
    //这里是一个小问题，本来是ended了,但是调用drawRect的时候就成了possible
    if (self.longPressGR.state == UIGestureRecognizerStateEnded) {
        self.frame = originFrame;
    }
    //这里也是一个小问题，只能把frame的修改放在drawRect外面，不然会有很短时间的一个闪烁。
    if (self.longPressGR.state == UIGestureRecognizerStateChanged) {
        self.frame = BOUNDS_SCREEN;
    }
    
    [self setNeedsDisplay];
    [self.redPointViewDelegate handleLongPressGR:self.longPressGR];
}

-(void) drawRect:(CGRect)rect{
    switch (self.longPressGR.state) {
        case UIGestureRecognizerStatePossible:{
            [self longPressGesturePossible];
            break;
        }
        case UIGestureRecognizerStateBegan:{
            [self longPressGestureBegan];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [self longPressGestureChanged];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [self longPressGestureEnded];
            break;
        }
        default:
            break;
    }
}

-(void) longPressGesturePossible{
//    NSLog(@"%s", __func__);
    originFrame = self.frame;
    startPointCircle = [RedPointViewCalculateCenter getCircleFromRect:self.frame];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.redPointColor.CGColor);
    CGContextFillEllipseInRect(ctx, self.bounds);
}

-(void) longPressGestureBegan{
//    NSLog(@"%s", __func__);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.redPointColor.CGColor);
    CGContextFillEllipseInRect(ctx, self.bounds);
}

-(void) longPressGestureChanged{
//    NSLog(@"%s", __func__);
    moveToPointCircle.centerPoint = [self.longPressGR locationInView:self];
    moveToPointCircle.radius = 40.0;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.redPointColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, self.redPointColor.CGColor);
    
    //两个圆
    CGContextFillEllipseInRect(ctx, originFrame);
    CGContextFillEllipseInRect(ctx, [RedPointViewCalculateCenter getRectFromCircle:moveToPointCircle]);
    
    //条贝塞尔曲线
    CGPoint *tangentPoints = [RedPointViewCalculateCenter get4TangentPointsFromCircle:startPointCircle toCircle:moveToPointCircle];
    CGPoint middlePointRight = [RedPointViewCalculateCenter getMiddlePointFromPoint:tangentPoints[0] toPoint:tangentPoints[3]];
    CGPoint middlePointLeft = [RedPointViewCalculateCenter getMiddlePointFromPoint:tangentPoints[2] toPoint:tangentPoints[1]];
    
    CGContextMoveToPoint(ctx, tangentPoints[0].x, tangentPoints[0].y);
    CGContextAddQuadCurveToPoint(ctx, middlePointRight.x, middlePointRight.y, tangentPoints[1].x, tangentPoints[1].y);
    CGContextAddLineToPoint(ctx, tangentPoints[3].x, tangentPoints[3].y);
    CGContextAddQuadCurveToPoint(ctx, middlePointLeft.x, middlePointLeft.y, tangentPoints[2].x, tangentPoints[2].y);
    CGContextFillPath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5] CGColor]);
    CGContextMoveToPoint(ctx, tangentPoints[0].x, tangentPoints[0].y);
    CGContextAddQuadCurveToPoint(ctx, middlePointRight.x, middlePointRight.y, tangentPoints[1].x, tangentPoints[1].y);
    CGContextAddLineToPoint(ctx, tangentPoints[3].x, tangentPoints[3].y);
    CGContextAddQuadCurveToPoint(ctx, middlePointLeft.x, middlePointLeft.y, tangentPoints[2].x, tangentPoints[2].y);
    CGContextMoveToPoint(ctx, tangentPoints[0].x, tangentPoints[0].y);
    CGContextAddLineToPoint(ctx, tangentPoints[1].x, tangentPoints[1].y);
    CGContextMoveToPoint(ctx, tangentPoints[2].x, tangentPoints[2].y);
    CGContextAddLineToPoint(ctx, tangentPoints[3].x, tangentPoints[3].y);
    CGContextStrokePath(ctx);
    
    free(tangentPoints);
}

-(void) longPressGestureEnded{
}

@end
