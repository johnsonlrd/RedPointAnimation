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
#define DURATION_BOMBANIMATION (0.4)

@implementation RedPointView{
    UILongPressGestureRecognizer *longPressGR;
    UIImageView *bombAnimationView;                 //爆炸动画
    RedPointState redPointState;
    NSTimer *springTimer;
    int springCount;
    
    struct Circle originalStartPointCircle;                 //原始起点处红点
    struct Circle startPointCircle;                             //当前起点处红点
    struct Circle moveToPointCircle;                       //手指当前点处红点
    struct Circle maxStretchCircle;                         //最大拉伸距离圈
}

#pragma mark init

-(id) initWithFrame:(CGRect)frame redPointColor:(UIColor *)redPointColor maxStretchRadius:(CGFloat)maxStretchRadius{
    self = [super initWithFrame:frame];
    if (self) {
        self.redPointColor = redPointColor;
        self.maxStretchRadius = maxStretchRadius;
        self.isShowControlLines = YES;
        redPointState = RedPointStateOrignal;
        springCount = SUM_SPRING_CYCLE;
        self.backgroundColor = [UIColor clearColor];
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
    [self addSubview:bombAnimationView];
}

-(void) addGesture{
    longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGR)];
    longPressGR.minimumPressDuration = 0.001;
    [self addGestureRecognizer:longPressGR];
}

#pragma mark handle gesture

-(void) handleLongPressGR{
    switch (longPressGR.state) {
        case UIGestureRecognizerStatePossible:{
            [self longPressGesturePossible];
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
    
    [self setNeedsDisplay];
}

-(void) longPressGesturePossible{
}

-(void) longPressGestureChanged{
    if (redPointState == RedPointStateOrignal) {
        redPointState = RedPointStateStretch;
        
        originalStartPointCircle = [RedPointViewCalculateCenter getCircleFromRect:self.frame];
        startPointCircle = originalStartPointCircle;
        moveToPointCircle = originalStartPointCircle;
        maxStretchCircle = originalStartPointCircle;
        maxStretchCircle.radius = self.maxStretchRadius;
        
        self.frame = BOUNDS_SCREEN;
    }else if(redPointState == RedPointStateStretch) {
        if ([RedPointViewCalculateCenter getLengthFromPoint:[longPressGR locationInView:self] toPoint:originalStartPointCircle.centerPoint] <= self.maxStretchRadius) {
            startPointCircle.radius = [RedPointViewCalculateCenter getStartPointCircleRadiusFromOriginalStartPointCircle:originalStartPointCircle toMoveToPointCircle:moveToPointCircle maxStretchRadius:self.maxStretchRadius];
        }else{
            redPointState =RedPointStateOutOfStretchRadius;
        }
    }
    
    moveToPointCircle.centerPoint = [longPressGR locationInView:self];
}

-(void) longPressGestureEnded{
    if (redPointState == RedPointStateOutOfStretchRadius) {
        redPointState = RedPointStateBombing;
        
        bombAnimationView.center = moveToPointCircle.centerPoint;
        [self removeGestureRecognizer:longPressGR];
        [bombAnimationView startAnimating];
        
        dispatch_time_t bomtDuration = dispatch_time(DISPATCH_TIME_NOW, bombAnimationView.animationDuration * NSEC_PER_SEC);
        dispatch_after(bomtDuration, dispatch_get_main_queue(), ^{
            self.frame = [RedPointViewCalculateCenter getRectFromCircle:originalStartPointCircle];
            [self addGestureRecognizer:longPressGR];
            redPointState = RedPointStateOrignal;
            [self setNeedsDisplay];
            
            //delegate
            [self.redPointViewDelegate bombed];
        });
    }else if (redPointState == RedPointStateStretch){
        redPointState = RedPointStateSpring;
        
        [self removeGestureRecognizer:longPressGR];
        NSDictionary *userInfo = @{@"maxMoveToPoint":[NSValue valueWithCGPoint:moveToPointCircle.centerPoint], @"startTime":[NSDate date]};
        springTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 100 target:self selector:@selector(onSpring:) userInfo:userInfo repeats:YES];
    }
}

-(void) onSpring:(NSTimer *)timer{
    CGPoint maxMoveToPoint = [[timer.userInfo objectForKey:@"maxMoveToPoint"] CGPointValue];
    NSDate *startDate = [timer.userInfo objectForKey:@"startTime"];
    double time = [[NSDate date]  timeIntervalSinceDate:startDate];
    
    CGPoint newMoveToPoint = [RedPointViewCalculateCenter getSpringPointFromOriginalPoint:originalStartPointCircle.centerPoint toMaxMoveToPoint:maxMoveToPoint onTime:time withCount:springCount];
    if ((moveToPointCircle.centerPoint.x - originalStartPointCircle.centerPoint.x) * (newMoveToPoint.x - originalStartPointCircle.centerPoint.x) < 0) {
        springCount --;
    }
    
    if (springCount > 0) {
        moveToPointCircle.centerPoint = newMoveToPoint;
    }else{
        redPointState = RedPointStateOrignal;
        
        self.frame = [RedPointViewCalculateCenter getRectFromCircle:originalStartPointCircle];
        springCount = SUM_SPRING_CYCLE;
        [self addGestureRecognizer:longPressGR];
        [springTimer invalidate];
    }
    
    startPointCircle.radius = [RedPointViewCalculateCenter getStartPointCircleRadiusFromOriginalStartPointCircle:originalStartPointCircle toMoveToPointCircle:moveToPointCircle maxStretchRadius:self.maxStretchRadius];
    
    [self setNeedsDisplay];
}

#pragma mark draw rect

-(void) drawRect:(CGRect)rect{
    switch (redPointState) {
        case RedPointStateOrignal:{
            [self drawOnRedPointStateOrignal];
            break;
        }
        case RedPointStateStretch:{
            [self drawOnRedPointStateStretch];
            break;
        }
        case RedPointStateOutOfStretchRadius:{
            [self drawOnRedPointStateOutOfStretch];
            break;
        }
        case RedPointStateSpring:{
            [self drawOnRedPointStateSpring];
            break;
        }
            
        default:
            break;
    }
}

-(void) drawOnRedPointStateOrignal{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.redPointColor.CGColor);
    
    CGContextFillEllipseInRect(ctx, self.bounds);
}

-(void) drawOnRedPointStateStretch{
    CGPoint *tangentPoints = NULL;
    CGPoint middlePointRight;
    CGPoint middlePointLeft;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.redPointColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, self.redPointColor.CGColor);
    
    //moveToPointCircle
    CGContextFillEllipseInRect(ctx, [RedPointViewCalculateCenter getRectFromCircle:moveToPointCircle]);
    
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
    
    //显示控制线
    if (self.isShowControlLines) {
        CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5] CGColor]);
        
        CGContextAddEllipseInRect(ctx, [RedPointViewCalculateCenter getRectFromCircle:maxStretchCircle]);
        
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
        
        CGContextStrokePath(ctx);
    }
    
    if (tangentPoints != NULL) {
        free(tangentPoints);
    }
}

-(void) drawOnRedPointStateOutOfStretch{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.redPointColor.CGColor);
    
    CGContextFillEllipseInRect(ctx, [RedPointViewCalculateCenter getRectFromCircle:moveToPointCircle]);
    
    //显示控制线
    if (self.isShowControlLines) {
        CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5] CGColor]);
        
        CGContextAddEllipseInRect(ctx, [RedPointViewCalculateCenter getRectFromCircle:maxStretchCircle]);
        
        CGContextStrokePath(ctx);
    }
}

-(void) drawOnRedPointStateSpring{
    [self drawOnRedPointStateStretch];
}


@end
