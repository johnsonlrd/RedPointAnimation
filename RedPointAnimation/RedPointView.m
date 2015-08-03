//
//  RedPointView.m
//  RedPointAnimation
//
//  Created by 余曦 on 8/2/15.
//  Copyright (c) 2015 余曦. All rights reserved.
//

#import "RedPointView.h"
#import "RedPointViewCalculateCenter.h"

#define SIZE_BOMBANIMATIONVIEW (68.0 / 2.0)
#define DURATION_BOMBANIMATION (0.2)

@implementation RedPointView{
    struct Circle originalStartPointCircle;                 //原始起点处红点
    struct Circle startPointCircle;                             //当前起点处红点
    struct Circle moveToPointCircle;                       //手指当前点处红点
    struct Circle maxStretchCircle;                         //最大拉伸距离圈
    
    BOOL isOutMaxStretchRadius;                         //当前是否超出最大拉伸距离
    BOOL hasOutMaxStretchRadius;                        //曾经是否超出最大拉伸距离
    
    UIImageView *bombAnimationView;                 //爆炸动画
}

-(id) initWithFrame:(CGRect)frame redPointColor:(UIColor *)redPointColor maxStretchRadius:(CGFloat)maxStretchRadius{
    self = [super initWithFrame:frame];
    if (self) {
        self.redPointColor = redPointColor;
        self.maxStretchRadius = maxStretchRadius;
        self.backgroundColor = [UIColor clearColor];
        self.isShowControlLines = YES;
        [self initBombAnimationView];
        [self addGesture];
    }
    return self;
}

-(void) initBombAnimationView{
    bombAnimationView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, SIZE_BOMBANIMATIONVIEW, SIZE_BOMBANIMATIONVIEW)];
    NSMutableArray *bombAnimationImages = [NSMutableArray array];
    for (int i = 0; i < 5; i ++) {
        [bombAnimationImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"RedPointBomb_%d", i]]];
    }
    bombAnimationView.animationImages = bombAnimationImages;
    bombAnimationView.animationDuration = DURATION_BOMBANIMATION;
    bombAnimationView.animationRepeatCount = 1;
    bombAnimationView.backgroundColor = [UIColor redColor];
    [self addSubview:bombAnimationView];
}

-(void) addGesture{
    self.longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGR)];
    self.longPressGR.minimumPressDuration = 0.001;
    [self addGestureRecognizer:self.longPressGR];
}

-(void) handleLongPressGR{
    //这里是一个小问题，本来是ended了,但是调用drawRect的时候就成了possible
    if (self.longPressGR.state == UIGestureRecognizerStateEnded) {
        struct Circle tmpCircle = {moveToPointCircle.centerPoint, SIZE_BOMBANIMATIONVIEW / 2.0};
        bombAnimationView.frame = [RedPointViewCalculateCenter getRectFromCircle:tmpCircle];
        [bombAnimationView startAnimating];
        
        self.frame = [RedPointViewCalculateCenter getRectFromCircle:originalStartPointCircle];
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
    hasOutMaxStretchRadius = NO;
   
    if (!isOutMaxStretchRadius) {
        originalStartPointCircle = [RedPointViewCalculateCenter getCircleFromRect:self.frame];
        startPointCircle = [RedPointViewCalculateCenter getCircleFromRect:self.frame];
        maxStretchCircle.centerPoint = originalStartPointCircle.centerPoint;
        maxStretchCircle.radius = self.maxStretchRadius;
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, self.redPointColor.CGColor);
        CGContextFillEllipseInRect(ctx, self.bounds);
    }else{
    }
}

-(void) longPressGestureBegan{
//    NSLog(@"%s", __func__);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.redPointColor.CGColor);
    CGContextFillEllipseInRect(ctx, self.bounds);
}

-(void) longPressGestureChanged{
//    NSLog(@"%s", __func__);
    
    moveToPointCircle = originalStartPointCircle;
    moveToPointCircle.centerPoint = [self.longPressGR locationInView:self];
    startPointCircle.radius = [RedPointViewCalculateCenter getStartPointCircleRadiusFromOriginalStartPointCircle:originalStartPointCircle toMoveToPointCircle:moveToPointCircle maxStretchRadius:self.maxStretchRadius];
   
    CGPoint *tangentPoints = NULL;
    CGPoint middlePointRight;
    CGPoint middlePointLeft;
    
     isOutMaxStretchRadius = self.maxStretchRadius < [RedPointViewCalculateCenter getLengthFromPoint:moveToPointCircle.centerPoint toPoint:originalStartPointCircle.centerPoint];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.redPointColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, self.redPointColor.CGColor);
    
    //moveToPointCircle
    CGContextFillEllipseInRect(ctx, [RedPointViewCalculateCenter getRectFromCircle:moveToPointCircle]);
    
    if (!isOutMaxStretchRadius) {
        if (!hasOutMaxStretchRadius) {
            //startPointCircle
            CGContextFillEllipseInRect(ctx, [RedPointViewCalculateCenter getRectFromCircle:startPointCircle]);
            
            tangentPoints = [RedPointViewCalculateCenter get4TangentPointsFromCircle:startPointCircle toCircle:moveToPointCircle];
            middlePointRight = [RedPointViewCalculateCenter getMiddlePointFromPoint:tangentPoints[0] toPoint:tangentPoints[3]];
            middlePointLeft = [RedPointViewCalculateCenter getMiddlePointFromPoint:tangentPoints[2] toPoint:tangentPoints[1]];
            
            //2条贝塞尔曲线
            CGContextMoveToPoint(ctx, tangentPoints[0].x, tangentPoints[0].y);
            CGContextAddQuadCurveToPoint(ctx, middlePointRight.x, middlePointRight.y, tangentPoints[1].x, tangentPoints[1].y);
            CGContextAddLineToPoint(ctx, tangentPoints[3].x, tangentPoints[3].y);
            CGContextAddQuadCurveToPoint(ctx, middlePointLeft.x, middlePointLeft.y, tangentPoints[2].x, tangentPoints[2].y);
            CGContextFillPath(ctx);
        }
    }else{
        hasOutMaxStretchRadius = YES;
    }
   
    
    //显示控制线
    if (self.isShowControlLines) {
        CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5] CGColor]);
        
        CGContextAddEllipseInRect(ctx, [RedPointViewCalculateCenter getRectFromCircle:maxStretchCircle]);
        
        if (!isOutMaxStretchRadius && !hasOutMaxStretchRadius) {
            CGContextMoveToPoint(ctx, tangentPoints[0].x, tangentPoints[0].y);
            CGContextAddQuadCurveToPoint(ctx, middlePointRight.x, middlePointRight.y, tangentPoints[1].x, tangentPoints[1].y);
            CGContextMoveToPoint(ctx, tangentPoints[2].x, tangentPoints[2].y);
            CGContextAddQuadCurveToPoint(ctx, middlePointLeft.x, middlePointLeft.y, tangentPoints[3].x, tangentPoints[3].y);
            
            CGContextMoveToPoint(ctx, tangentPoints[0].x, tangentPoints[0].y);
            CGContextAddLineToPoint(ctx, startPointCircle.centerPoint.x, startPointCircle.centerPoint.y);
            CGContextAddLineToPoint(ctx, tangentPoints[2].x, tangentPoints[2].y);
            CGContextMoveToPoint(ctx, tangentPoints[1].x, tangentPoints[1].y);
            CGContextAddLineToPoint(ctx, moveToPointCircle.centerPoint.x, moveToPointCircle.centerPoint.y);
            CGContextAddLineToPoint(ctx, tangentPoints[3].x, tangentPoints[3].y);
            
            CGContextMoveToPoint(ctx, tangentPoints[0].x, tangentPoints[0].y);
            CGContextAddLineToPoint(ctx, tangentPoints[1].x, tangentPoints[1].y);
            CGContextAddLineToPoint(ctx, middlePointRight.x, middlePointRight.y);
            CGContextAddLineToPoint(ctx, tangentPoints[0].x, tangentPoints[0].y);
            CGContextMoveToPoint(ctx, tangentPoints[2].x, tangentPoints[2].y);
            CGContextAddLineToPoint(ctx, tangentPoints[3].x, tangentPoints[3].y);
            CGContextAddLineToPoint(ctx, middlePointLeft.x, middlePointLeft.y);
            CGContextAddLineToPoint(ctx, tangentPoints[2].x, tangentPoints[2].y);
        }
        CGContextStrokePath(ctx);
    }
    
    if (tangentPoints != NULL) {
        free(tangentPoints);
    }
}

-(void) longPressGestureEnded{
}

@end
