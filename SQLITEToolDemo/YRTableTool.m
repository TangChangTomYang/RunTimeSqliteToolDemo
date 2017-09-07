//
//  YRTableTool.m
//  SQLITEToolDemo
//
//  Created by yangrui on 2017/9/2.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import "YRTableTool.h"
#import "YRModeTool.h"
#import "YRSqliteTool.h"

@implementation YRTableTool
/** 获取 uid 数据库中 ""表名==cls"" 的所有字段(排序后的) NSArray.count == 0 表示该表不存在 */
+(NSArray<NSString *> *)sortedTableColumnNames:(Class)cls uid:(NSString *)uid{
    
    NSMutableArray *columns = [NSMutableArray array];
    
    NSString *tableName = [YRModeTool tableName:cls];
    
    //sql = "CREATE TABLE TestMode (id integer primary key autoincrement, age integer,sut blob,suts blob not null,name text,rowCount3 integer,rowCount integer)"; 这个就是查询到的结果
    NSString *querySql = [ NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'",tableName];
    
    NSArray *resultArr  = [YRSqliteTool querySql:querySql uid:uid];
    
    if(resultArr.count == 0) return nil;
    
    NSString  *createTableSqlStr = (resultArr[0])[@"sql"];
    if(createTableSqlStr.length > 0){
     
        NSArray *arr = [createTableSqlStr componentsSeparatedByString:@"("];
        if(arr.count == 2){
            
            NSString *str1 = arr[1];
            NSArray *fieldStrs = [str1 componentsSeparatedByString:@","];
            
            for(int i = 0; i < fieldStrs.count; i++){
                
                NSString *fieldStr = [fieldStrs[i] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
                
                
                NSString *column = [fieldStr componentsSeparatedByString:@" "].firstObject;
                [columns addObject:column];
            }
        }
    }
    
    // 排序
    [columns sortUsingComparator:^NSComparisonResult(NSString  *obj1, NSString  *obj2) {
        
        return [obj1 compare:obj2];
    }];
    
    NSString *primaryColumnStr = @"id";
    if([columns containsObject:primaryColumnStr]){
        [columns removeObject:primaryColumnStr];
    }
    
    return columns;
}


/** 检测当前 用户对应的数据库表是否存在 */
+(BOOL)isTableExists:(Class)cls uid:(NSString *)uid{
   
    NSString *tableName = [YRModeTool tableName:cls];
    
    NSString *querySql = [ NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'",tableName];
    
    NSArray *resultArr  = [YRSqliteTool querySql:querySql uid:uid];
    
    return  (resultArr.count > 0) ;
    
}

/** 判断 uid 数据库 的 表明 = cls 的表是否需要迁移数据*/
+(BOOL)isRequired2UpdateTable:(Class)cls uid:(NSString *)uid{
    
    NSArray *columnsInTable = [self sortedTableColumnNames:cls uid:uid];// 这里需要判断 数据库表是否存在
    
    if(columnsInTable.count == 0){
        YRLog(@"警告: 你需要在查询 是否需要 迁移数据前 确保该数据库的表存在");
        return NO;
    }
    NSArray *columnsInMode =  [YRModeTool sortedColumnNames:cls];
    
    BOOL isSame = [columnsInMode isEqualToArray:columnsInTable];
    
    return !isSame;

}

@end
