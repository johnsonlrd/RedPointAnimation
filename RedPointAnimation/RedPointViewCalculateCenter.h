//
//  RedPointViewCalculateCenter.h
//  RedPointAnimation
//
//  Created by 余曦 on 8/2/15.
//  Copyright (c) 2015 余曦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define BOUNDS_SCREEN [[UIScreen mainScreen] bounds]
#define MIN_RADIUS_FACTOR 0.5                                               //startPointCircle当前半径相对于初始半径的最小比例 

struct Circle{
    CGPoint centerPoint;
    CGFloat radius;
};

@interface RedPointViewCalculateCenter : NSObject

+(CGRect)getRectFromCircle:(struct Circle)circle;

+(struct Circle) getCircleFromRect:(CGRect) rect;

+(CGPoint) getMiddlePointFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2;

+(CGFloat)getLengthFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2;

//CG坐标和左下角原点右上为正的坐标里点的转换
+(CGPoint)getConvertPointFromCGPoint:(CGPoint)point;

+(CGPoint *)get4TangentPointsFromCircle:(struct Circle)circle0 toCircle:(struct Circle)circle1;

+(CGFloat) getStartPointCircleRadiusFromOriginalStartPointCircle:(struct Circle)originalStartPointCircle toMoveToPointCircle:(struct Circle)moveToPointCircle maxStretchRadius:(CGFloat)maxStretchRadius;

@end
