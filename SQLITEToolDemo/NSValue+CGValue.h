//
//  NSValue+CGValue.h
//  SQLITEToolDemo
//
//  Created by 　yangrui on 2017/9/6.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (CGValue)


/** point string -> NSValue */
+(NSValue *)pointValueWithStr:(NSString *)pointValueStr name:(NSString *)name;

/** size string -> NSValue */
+(NSValue *)sizeValueWithStr:(NSString *)sizeValueStr name:(NSString *)name;

/** rect string -> NSValue */
+(NSValue *)rectValueWithStr:(NSString *)rectValueStr name:(NSString *)name;

@end
