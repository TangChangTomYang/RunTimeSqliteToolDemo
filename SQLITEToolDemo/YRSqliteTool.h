//
//  YRSqliteTool.h
//  YRSqliteTool
//
//  Created by yangrui on 2017/9/2.
//  Copyright © 2017年 TangChangTomYang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "sqlite3.h"
#import "YRSqliteModeTool.h"


@interface YRSqliteTool : NSObject
// 考虑 在执行操作之前是否需要判断表是否存在  ???

/** 
  我们使用数据库时引入用户机制
  如果 用户名为nil ,则  common.db
  如果 用户名为张三, 则  zhangsan.db
 */
+(BOOL)dealSql:(NSString *)sql uid:(NSString *)uid;

/** 同时执行 读条语句  用事物来管理*/
+(BOOL)dealSqls:(NSArray<NSString *> *)sqls uid:(NSString *)uid;

/** 根据sql 语句查询 结果 */
+(NSMutableArray<NSMutableDictionary *> *)querySql:(NSString *)sql uid:(NSString *)uid;

@end
