//
//  YRTableTool.h
//  SQLITEToolDemo
//
//  Created by yangrui on 2017/9/2.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YRColumnProtocal.h"
@interface YRTableTool : NSObject


/** 获取 uid 数据库中 ""表名==cls"" 的所有字段(排序后的)  */
+(NSArray<NSString *> *)sortedTableColumnNames:(Class)cls uid:(NSString *)uid;

/** 判断当前用户下的这个数据库的表是否需要迁移数据 */
+(BOOL)isRequired2UpdateTable:(Class)cls uid:(NSString *)uid;

/** 检测当前 用户对应的数据库表是否存在 */
+(BOOL)isTableExists:(Class)cls uid:(NSString *)uid;

@end
