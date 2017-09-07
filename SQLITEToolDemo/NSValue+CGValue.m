//
//  NSValue+CGValue.m
//  SQLITEToolDemo
//
//  Created by 　yangrui on 2017/9/6.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import "NSValue+CGValue.h"

@implementation NSValue (CGValue)


/** point string -> NSValue */
+(NSValue *)pointValueWithStr:(NSString *)pointValueStr name:(NSString *)name{
    
    if (pointValueStr.length > 0) {
        
        return[NSValue valueWithCGPoint:CGPointFromString(pointValueStr)];
    }else{
        
        return[NSValue valueWithCGPoint:CGPointZero];
    }
    
    
}

/** size string -> NSValue */
+(NSValue *)sizeValueWithStr:(NSString *)sizeValueStr name:(NSString *)name{
    
    if (sizeValueStr.length > 0) {
        
        return[NSValue valueWithCGSize:CGSizeFromString(sizeValueStr)];
    }else{
        
        return[NSValue valueWithCGSize:CGSizeZero];
    }
    
    
}

/** rect string -> NSValue */
+(NSValue *)rectValueWithStr:(NSString *)rectValueStr name:(NSString *)name{
    if (rectValueStr.length > 0) {
        
        return[NSValue valueWithCGRect:CGRectFromString(rectValueStr)];
    }else{
        
        return[NSValue valueWithCGRect:CGRectZero];
    }
    
}

@end
