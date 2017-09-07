//
//  YRSqliteTool.m
//  YRSqliteTool
//
//  Created by yangrui on 2017/9/2.
//  Copyright © 2017年 TangChangTomYang. All rights reserved.
//

#import "YRSqliteTool.h"

//#define DBCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject
#define DBCachePath  @"/Users/yangrui/Desktop/sqliteTestFolder"
@implementation YRSqliteTool





/** 将一个数据库中的某一列数据迁移到另一列
 //1. 旧表
 create table if not exists t_stu(id integer primary key autoincrement, name text not null,age integer)
 //2. 新表
 create table if not exists t_stu_temp(id integer primary key autoincrement, name text not null,age integer,score float)
 
 //3. //step1. 插入主键
 insert into t_stu_temp(id) select id from t_stu; //这个语句有问题
 //4. //step2. 以主键做参考 移更新其他字段数据
 update t_stu_temp set name = (select name from t_stu where t_stu_temp.id = t_stu.id);
 //5  //step3. 删除老表
 drop table if exists t_stu;
 //6  //step. 重命名 新表
 alter table t_stu_temp rename to t_stu;
 
 
 
 
 */



+(BOOL)dealSql:(NSString *)sql uid:(NSString *)uid{

    if( ![self openDataBase:uid]){
        YRLog(@"执行sql : %@ 时,打开数据库失败",sql);
        return NO;
    }
    
    //2. 执行数据库语句
    BOOL  exeSqltResult = [self justDealSql:sql];
 
    [self closeDataBase];
    
    return exeSqltResult;
}




/** 同时执行 读条语句  用事物来管理*/
+(BOOL)dealSqls:(NSArray<NSString *> *)sqls uid:(NSString *)uid{
   
    if( ![self openDataBase:uid]){
        YRLog(@"执行多条sqls : %@ 时,打开数据库失败",sqls);
        return NO;
    }
    
    if (![self beginTransaction:uid]) {
        YRLog(@"执行 多条 sql 开启事物 失败");
        [self closeDataBase];
        return NO;
    }
    
    
    
    BOOL exeResult = YES;
    for(int i = 0; i< sqls.count; i++ ){
        
        NSString *sql = sqls[i];
       exeResult = [self justDealSql:sql];
    
        if (exeResult == NO) {
            YRLog(@"执行多条sql语句 sql %@ 时失败:",sql);
            break;
        }
        
    }
    
    if (exeResult == YES) {// 提交事物
        [self commitTransaction:uid];
    }
    else{//回滚事物
        [self rollBackTransaction:uid];
    }
    
    [self closeDataBase];
    return exeResult;
}





/** 数据库打开的方式与差异
 
 1. sqlite3_open_v2(const char *filename, sqlite3 **ppDb, int flags, const char *zVfs)
 是sqlite 的进阶版本(这个有个弊端,当数据库路径不存在不会帮我们创建一个新的)
 
 2. sqlite3_open16(const void *filename, sqlite3 **ppDb) 是sqlite 的utf16编码

 3. sqlite3_open(const char *filename, sqlite3 **ppDb) 这个是sqlite 的UTF8 编码,我们使用这个,这个有个特点,当数据库路径不存在是会帮我们创建一个新的数据库并打开
 */



+(NSMutableArray<NSMutableDictionary *> *)querySql:(NSString *)sql uid:(NSString *)uid{
   
    
    if(![self openDataBase:uid]){
        YRLog(@"查询 sql : %@ 时,打开数据库失败",sql);
        return nil;
    }
    
    // 准备语句(预处理语句)
    
    //1. 创建准备语句
    //sqlite3 *db  数据库, const char *zSql SQL语句,int nByte, sql语句字节长度,sqlite3_stmt **ppStmt 结果矩阵,const char **pzTail,
    sqlite3_stmt *ppStmt  = nil;
    if (sqlite3_prepare_v2(db, sql.UTF8String, -1, &ppStmt, nil) != SQLITE_OK) {
        
         YRLog(@" 查询 sql: %@ 操作 失败 ",sql);
        return nil;
    }
    
    
     NSMutableArray *arrM = [NSMutableArray array];

    // 执行
    while ( sqlite3_step(ppStmt) == SQLITE_ROW) {
        // 一条一条的 记录 -> 字典
        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
        //1. 获取一共有多少列(字段)
        int columnCount = sqlite3_column_count(ppStmt);
       
        //2. 遍历所有的列
        for (int i = 0; i< columnCount; i++) {
            //3. 获取列名
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(ppStmt, i)];
            
            //4.获取列值
            //4.1 获取列的数据类型
            int dataType = sqlite3_column_type(ppStmt, i);
            //4.2 根据获取列的数据类型获取列的值
            switch (dataType) {
                case SQLITE_INTEGER:{
                                    dicM[columnName] = @(sqlite3_column_int64(ppStmt, i));
                    break;
                }//整型
                    
                case SQLITE_FLOAT:  {
                                    dicM[columnName] = @(sqlite3_column_double(ppStmt, i));
                    break;}//浮点
                case SQLITE_BLOB:   {
                                    dicM[columnName] = CFBridgingRelease( sqlite3_column_blob(ppStmt, i));
                    break;} //对象(二进制)
                case SQLITE_NULL:   {
                                    dicM[columnName] = @"" ;
                    break;}
                case SQLITE3_TEXT:  {
                                    dicM[columnName] = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(ppStmt, i)];
                    break;}

            }
           
            
        }
        
        [arrM addObject:dicM];
    }
    
   // 释放资源
    sqlite3_finalize(ppStmt);
    
    [self closeDataBase];
    
    return arrM;
    
    
}




#pragma mark- 私有方法,内部调用
static sqlite3 *db = nil;
// 我们在封装 工具是一共有两种语句:
// 执行语句: 返回是否成功
// 查询语句: 返回结果集  (有字典对应的数组(每个字典对应一条记录))

/** 我们使用数据库时引入用户机制,如果 用户名为nil ,则  common.db,如果 用户名为张三, 则  zhangsan.db */
+(BOOL)openDataBase:(NSString *)uid{
    
    NSString *dbName = @"common.sqlite";
    if (uid.length > 0) {
        dbName = [NSString stringWithFormat:@"%@.sqlite",uid];
    }
    NSString *dbPath = [DBCachePath stringByAppendingPathComponent:dbName];
    
    return  (sqlite3_open(dbPath.UTF8String , &db) == SQLITE_OK);
    
}

/** 仅仅是执行sql 语句 前提 数据库是打开的 ,执行完也不会关闭数据库 */
+(BOOL)justDealSql:(NSString *)sql{
    //2. 执行数据库语句
    
    int result = sqlite3_exec(db, sql.UTF8String, nil, nil, nil);
    BOOL exeSqltResult = (result == SQLITE_OK);
    
    if( ! exeSqltResult){
        YRLog(@" justDealSql 执行 sql: %@ 操作 失败 ",sql);
    }
    
    return exeSqltResult;
}


+(void)closeDataBase{
    //3. 关闭数据库
    sqlite3_close(db);
}


/** 开始事物 */
+(BOOL)beginTransaction:(NSString *)uid{
    
   return  [self justDealSql:@"begin transaction;"];
    
}

/** 提交事物 */
+(BOOL)commitTransaction:(NSString *)uid{
    
  return   [self justDealSql:@"commit transaction;"];
}

/** 回滚事物 */
+(BOOL)rollBackTransaction:(NSString *)uid{
  
    return [self justDealSql:@"rollback transaction;"];
    
}







@end
