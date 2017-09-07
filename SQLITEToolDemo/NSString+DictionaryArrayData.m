//
//  NSString+DictionaryArrayData.m
//  SQLITEToolDemo
//
//  Created by 　yangrui on 2017/9/6.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import "NSString+DictionaryArrayData.h"

@implementation NSString (DictionaryArrayData)


+(NSData *)dataWithStr:(NSString *)dataStr name:(NSString *)name{
    NSData *data  = nil;
    if (dataStr.length > 0) {
        data =  [[NSData alloc]initWithBase64EncodedString:dataStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    
    if (data.length > 0) {
        return data;
    }else{
        YRLog(@"警告: 在解析 %@ 时 NSData 没解析出来",name);
        return [NSData data];
    }
}

+(NSMutableData *)mulDataWithStr:(NSString *)dataStr name:(NSString *)name{
    NSMutableData *data  = nil;
    if (dataStr.length > 0) {
        data =  [[NSMutableData alloc]initWithBase64EncodedString:dataStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    
    if (data.length > 0) {
        return data;
    }else{
        YRLog(@"警告: 在解析 %@ 时 NSMutableData 没解析出来",name);
        return [NSMutableData data];
    }
}



/**string -> 数组*/
+(NSArray *)arrayWithStr:(NSString *)arrStr  name:(NSString *)name{
    
    NSArray *arr = nil;
    
    if (arrStr.length > 0) {
        NSData *arrStrData = [arrStr dataUsingEncoding:NSUTF8StringEncoding];
        arr = [NSJSONSerialization JSONObjectWithData:arrStrData options:kNilOptions error:nil];
    }
    
    if (arr == nil) {
        arr = [NSArray array];
        YRLog(@"警告: 数据库查询到的字段: %@ 对应的数据不能转成NSArray对象",name);
    }
    return arr;
}

/**string -> 可变数组*/
+(NSMutableArray *)mulArrayWithStr:(NSString *)arrStr  name:(NSString *)name{
    
    NSMutableArray *arrM = nil;
    
    if (arrStr.length > 0) {
        NSData *arrStrData = [arrStr dataUsingEncoding:NSUTF8StringEncoding];
        arrM = [NSJSONSerialization JSONObjectWithData:arrStrData options:NSJSONReadingMutableContainers error:nil];
        
    }
    
    if (arrM == nil) {
        arrM = [NSMutableArray array] ;
        
        YRLog(@"警告: 数据库查询到的字段: %@ 对应的数据不能转成 NSMutableArray对象",name);
    }
    return arrM;
}




/**string -> 字典*/
+(NSDictionary *)dictionaryWithStr:(NSString *)dicStr  name:(NSString *)name{
    
    NSDictionary *dic = nil;
    
    if (dicStr.length > 0) {
        NSData *dicStrData = [dicStr dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:dicStrData options:kNilOptions error:nil];
    }
    
    if (dic == nil) {
        dic = [NSDictionary dictionary];
        
        YRLog(@"警告: 数据库查询到的字段: %@ 对应的数据不能转成NSDictionary 对象",name);
    }
    
    return dic;
}

/**string -> 可变字典*/
+(NSMutableDictionary *)mulDictionaryWithStr:(NSString *)dicStr  name:(NSString *)name{
    
    NSMutableDictionary *dicM = nil;
    
    if (dicStr.length > 0) {
        NSData *dicStrData = [dicStr dataUsingEncoding:NSUTF8StringEncoding];
        dicM = [NSJSONSerialization JSONObjectWithData:dicStrData options:NSJSONReadingMutableContainers error:nil];
        
    }
    
    if (dicM == nil) {
        
        dicM = [NSMutableDictionary dictionary];
        YRLog(@"警告: 数据库查询到的字段: %@ 对应的数据不能转成NSMutableDictionary 对象",name);
    }
    return dicM;
}



/**将 NSConcreteValue 类型的数据转换成字符串  */
+(NSString *)stringOfConcreteValue:(id)concreteValue  forColumnName:(NSString *)columnName inClass:(Class)cls{
    
    
    
    NSDictionary *columnNameOCObjTypeDic = [YRModeTool classIvarNameAndOCObjType:cls];
    NSString *columnOCObjTypeStr = columnNameOCObjTypeDic[columnName];
    
    NSString *concreteValueStr  = nil;
    if ([columnOCObjTypeStr isEqualToString:@"CGRect"]) {
        
        CGRect frame = [concreteValue CGRectValue];
        concreteValueStr =NSStringFromCGRect(frame);
    }
    else  if ([columnOCObjTypeStr isEqualToString:@"CGSize"]) {
        
        CGSize size  = [concreteValue CGSizeValue];
        concreteValueStr =NSStringFromCGSize(size);
    }
    else  if ([columnOCObjTypeStr isEqualToString:@"CGPoint"]) {
        
        CGPoint point  = [concreteValue CGPointValue];
        concreteValueStr =NSStringFromCGPoint(point);
    }
    
    return concreteValueStr;
    
}


@end
