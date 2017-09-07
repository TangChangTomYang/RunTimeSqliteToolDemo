//
//  NSString+DictionaryArrayData.h
//  SQLITEToolDemo
//
//  Created by 　yangrui on 2017/9/6.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DictionaryArrayData)

  /**string -> NSData*/
+(NSData *)dataWithStr:(NSString *)dataStr name:(NSString *)name;

  /**string -> NSMutableData*/
+(NSMutableData *)mulDataWithStr:(NSString *)dataStr name:(NSString *)name;



/**string -> 数组*/
+(NSArray *)arrayWithStr:(NSString *)arrStr  name:(NSString *)name;

/**string -> 可变数组*/
+(NSMutableArray *)mulArrayWithStr:(NSString *)arrStr  name:(NSString *)name;



/**string -> 字典*/
+(NSDictionary *)dictionaryWithStr:(NSString *)dicStr  name:(NSString *)name;

/**string -> 可变字典*/
+(NSMutableDictionary *)mulDictionaryWithStr:(NSString *)dicStr  name:(NSString *)name;


/**将 NSConcreteValue 类型的数据转换成字符串  */
+(NSString *)stringOfConcreteValue:(id)concreteValue  forColumnName:(NSString *)columnName inClass:(Class)cls;
@end
