//
//  YRModeTool.h
//  SQLITEToolDemo
//
//  Created by yangrui on 2017/9/2.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YRColumnProtocal.h"
#define tempTable_SuffixStr   @"_temp"

@interface YRModeTool : NSObject

/** 根据对象的类型获取 数据库表的名字 */
+(NSString *)tableName:(Class)cls;

/** 根据对象的类型获取 数据库 临时表的名字 */
+(NSString *)temp_tableName:(Class)cls;

/** 生成一个 创建正式表的 sql 语句 字符串 (会自动添加id 主键 并 查询添加 必要的 字段 约束)*/
+(NSString *)createTableString:(Class)cls;

/** 生成一个 创建正式表的 sql 语句 字符串 (会自动添加id 主键 并 查询添加 必要的 字段 约束)*/
+(NSString *)createTempTableString:(Class)cls;

/** 排序后的 有效的的所有字段 [字段1  字段2]  */
+(NSArray<NSString *> *)sortedColumnNames:(Class)cls ;



/** 对象 类 -> (成员变量名 :OC 运行时数据类型 )*/
+(NSMutableDictionary<NSString *, NSString*> *)classIvarNameAndOCRunTimeType:(Class)cls;

/** 对象 类 -> (成员变量名 : sqlite数据类型 )*/
+(NSMutableDictionary<NSString *, NSString*> *)classIvarNameAndSqliteType:(Class)cls;

/** 对象 类 -> (成员变量名 : OC obj 对象数据类型 )*/
+(NSMutableDictionary<NSString *, NSString*> *)classIvarNameAndOCObjType:(Class)cls;

/** 将有效的成员 所有的成员变量 数据类型 - > name type ([约束]),name2 type ([约束])*/
+(NSString *)columnNameSqliteFieldString:(Class)cls;



/** 获取 mode 中 keyPath 对应的值, 若 value 不存在 则返回 OCObjType 对应的默认值 */
+(id)valueForKeyPath:(NSString *)keyPath mode:(id)mode OCObjType:(NSString *)OCObjType;

/**  空值得默认值 */
+(id)nilValueForClass:(Class)cls name:(NSString *)name;

@end
