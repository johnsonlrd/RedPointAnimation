//
//  RedPointViewCalculateCenter.m
//  RedPointAnimation
//
//  Created by 余曦 on 8/2/15.
//  Copyright (c) 2015 余曦. All rights reserved.
//

#import "RedPointViewCalculateCenter.h"

//#define recordData

@implementation RedPointViewCalculateCenter

+(CGRect) getRectFromCircle:(struct Circle)circle{
    return CGRectMake(circle.centerPoint.x - circle.radius, circle.centerPoint.y - circle.radius, circle.radius * 2, circle.radius * 2);
}

+(struct Circle) getCircleFromRect:(CGRect)rect{
    struct Circle circle;
    circle.radius = rect.size.width / 2.0;
    circle.centerPoint = CGPointMake(rect.origin.x + circle.radius, rect.origin.y + circle.radius);
    return circle;
}

+(CGFloat) getLengthFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2{
    CGFloat deltaX = point1.x - point2.x;
    CGFloat deltaY = point1.y - point2.y;
    return pow(pow(deltaX, 2) + pow(deltaY, 2), 0.5);
}

+(CGPoint) getMiddlePointFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2{
    return CGPointMake((point1.x + point2.x) / 2.0, (point1.y + point2.y) / 2.0);
}

+(CGPoint) getConvertPointFromCGPoint:(CGPoint)point{
    return CGPointMake(point.x, BOUNDS_SCREEN.size.height - point.y);
}

//两条切线的4个切点
+(CGPoint *) get4TangentPointsFromCircle:(struct Circle)circle0 toCircle:(struct Circle)circle1{
    circle0.centerPoint = [RedPointViewCalculateCenter getConvertPointFromCGPoint:circle0.centerPoint];
    circle1.centerPoint = [RedPointViewCalculateCenter getConvertPointFromCGPoint:circle1.centerPoint];
    
    CGPoint *tangentPoints = malloc(4 * sizeof(CGPoint));
    
    CGFloat deltX = circle1.centerPoint.x - circle0.centerPoint.x;
    deltX = fabs(deltX - 0.0) < 1e-6 ? 0.001 : deltX;          //避免分母为零,little lie.
    
    CGFloat k0 = (circle1.centerPoint.y - circle0.centerPoint.y) / (deltX);
    
    CGFloat d = [RedPointViewCalculateCenter getLengthFromPoint:circle1.centerPoint toPoint:circle0.centerPoint];
    d = fabs(d - 0.0) < 1e-6 ? 0.001 : d;
    
    CGFloat deltRadius = circle1.radius - circle0.radius;
    deltRadius = deltRadius / d > 1.0 ? d : deltRadius;
    
    CGFloat aRight = atan(k0) + asin(deltRadius / d);
    CGFloat aLeft = atan(k0) - asin(deltRadius / d);
    aRight = fabs(fabs(aRight) - M_PI_2) < 1e-6 ? aRight + 0.001 : aRight;
    aLeft = fabs(fabs(aLeft) - M_PI_2) < 1e-6 ? aLeft + 0.001 : aLeft;
    
    CGFloat kRight = tan(aRight);
    CGFloat kLeft = tan(aLeft);
    
    CGFloat b0 = circle0.centerPoint.y - kRight * circle0.centerPoint.x - circle0.radius / cos(aRight);
    CGFloat b1 = circle1.centerPoint.y - kRight * circle1.centerPoint.x - circle1.radius / cos(aRight);
    CGFloat b2 = circle0.centerPoint.y - kLeft * circle0.centerPoint.x + circle0.radius / cos(aLeft);
    CGFloat b3 = circle1.centerPoint.y - kLeft * circle1.centerPoint.x + circle1.radius / cos(aLeft);
    
    CGFloat tangentPoint0X = (kRight * circle0.centerPoint.y - kRight * b0 + circle0.centerPoint.x) / (1 + kRight * kRight);
    CGFloat tangentPoint0Y = kRight * tangentPoint0X + b0;
    tangentPoints[0] = [RedPointViewCalculateCenter getConvertPointFromCGPoint:CGPointMake(tangentPoint0X, tangentPoint0Y)];
    
    CGFloat tangentPoint1X = (kRight * circle1.centerPoint.y - kRight * b1 + circle1.centerPoint.x) / (1 + kRight * kRight);
    CGFloat tangentPoint1Y =  kRight * tangentPoint1X + b1;
    tangentPoints[1] = [RedPointViewCalculateCenter getConvertPointFromCGPoint:CGPointMake(tangentPoint1X, tangentPoint1Y)];
    
    CGFloat tangentPoint2X = (kLeft* circle0.centerPoint.y - kLeft* b2 + circle0.centerPoint.x) / (1 + kLeft* kLeft);
    CGFloat tangentPoint2Y =  kLeft* tangentPoint2X + b2;
    tangentPoints[2] = [RedPointViewCalculateCenter getConvertPointFromCGPoint:CGPointMake(tangentPoint2X, tangentPoint2Y)];
    
    CGFloat tangentPoint3X = (kLeft* circle1.centerPoint.y - kLeft* b3 + circle1.centerPoint.x) / (1 + kLeft* kLeft);
    CGFloat tangentPoint3Y =  kLeft* tangentPoint3X + b3;
    tangentPoints[3] = [RedPointViewCalculateCenter getConvertPointFromCGPoint:CGPointMake(tangentPoint3X, tangentPoint3Y)];
    
#ifdef recordData
    //记录参数 debug用
    NSMutableString *paramStr = [NSMutableString stringWithFormat:@"k0:%f, d:%f, deltaRadius:%f, aR:%f, aL:%f, kR:%f, kL:%f ", k0, d, deltRadius,aRight, aLeft, kRight, kLeft];
    for (int i = 0; i < 4; i ++) {
        [paramStr appendString:[NSString stringWithFormat:@"(%f, %f)", tangentPoints[i].x, tangentPoints[i].y]];
    }
    [paramStr appendString:@"\n"];
//    NSLog(@"%@", paramStr);
    [[RedPointViewCalculateCenter paramFileHandleInstance] seekToEndOfFile];
    [[RedPointViewCalculateCenter paramFileHandleInstance] writeData:[paramStr dataUsingEncoding:NSUTF8StringEncoding]];
#endif
    
    return tangentPoints;
}

//参数记录文件
+(NSFileHandle *) paramFileHandleInstance{
    static NSFileHandle *paramFileHandle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"param.txt"];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        paramFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    });
    return paramFileHandle;
}

+(CGFloat) getStartPointCircleRadiusFromOriginalStartPointCircle:(struct Circle)originalStartPointCircle toMoveToPointCircle:(struct Circle)moveToPointCircle maxStretchRadius:(CGFloat)maxStretchRadius{
    CGFloat factor = 1.0 - [RedPointViewCalculateCenter getLengthFromPoint:originalStartPointCircle.centerPoint toPoint:moveToPointCircle.centerPoint] / maxStretchRadius;
    factor = factor < MIN_RADIUS_FACTOR ? MIN_RADIUS_FACTOR : factor;
    return originalStartPointCircle.radius * factor;
}

+(CGPoint) getSpringPointFromOriginalPoint:(CGPoint)originalPoint toMaxMoveToPoint:(CGPoint)maxMovedPoint onTime:(double)time withCount:(int)count{
    double deltaX;
    double deltaY;
    
    double angle = RATIO_SPRING * time;
   
    deltaX = count / SUM_SPRING_CYCLE * (maxMovedPoint.x - originalPoint.x) * cos(angle);
    deltaY = count / SUM_SPRING_CYCLE * (maxMovedPoint.y - originalPoint.y) * cos(angle);
    
    return CGPointMake(originalPoint.x + deltaX, originalPoint.y + deltaY);
}

@end
