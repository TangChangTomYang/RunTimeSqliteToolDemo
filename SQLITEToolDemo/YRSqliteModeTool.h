//
//  YRSqliteModeTool.h
//  SQLITEToolDemo
//
//  Created by yangrui on 2017/9/2.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YRModeTool.h"
#import "YRTableTool.h"
#import "YRSqliteTool.h"

typedef enum {
SqliteRelationType_equal, // 等于 =
    SqliteRelationType_more,//大于 >
    SqliteRelationType_less,//小于 <
    SqliteRelationType_moreEqual,//大于等于 >=
    SqliteRelationType_lessEqual//小于等于 <=

}SqliteRelationType;


//#warning 使用说明, 凡是涉及到的数据模型,在 保存 或者 更新时 所有的字段不能 为nil 必须有确定的值
//#warning 也就是说, 所使用的所有的模型在 [[XXXMode alloc] init] 后,不允许有 属性的值 为 nil
//

@interface YRSqliteModeTool : NSObject

#pragma mark- 表相关操作
/** 给一个对象的 类型 创建一个  正式数据库的表  */
+(BOOL)createTable:(Class)cls uid:(NSString *)uid;

/** 根据映射关系 更新表 迁移表数据 如果表不存在则会 创建一个新表 */
+(BOOL)updateTable:(Class)cls withMapRelationUid:(NSString *)uid;



#pragma mark- 查询类方法
/** 根据 sql 语句查询 数据库 ,结果是一个 字典的数据  */
+(NSMutableArray<NSMutableDictionary *>*)queryWithSql:(NSString *)sql uid:(NSString *)uid;

/** 查询数据库数据  的所有模型数组 */
+(NSMutableArray*)queryMode:(Class)cls uid:(NSString *)uid;

/** 查询数据库数据  满足条件的模型数组*/
+(NSMutableArray *)queryModeArray:(Class)cls  whereStr:(NSString *)whereStr  uid:(NSString *)uid;



#pragma mark- 保存 或者 更新 类方法
/** 保存 或者 更新 mode */
+(BOOL)saveOrUpdateMode:(id)mode uid:(NSString *)uid;

/** 保存 或者 更新 modeArray   array 内的对象必须是同一个类型  */
+(BOOL)saveOrUpdateSameModes:(NSArray*)modeArray uid:(NSString *)uid;

/** 保存 或者 更新 modeArray  array 内的对象可以是不同 类型  */
+(BOOL)saveOrUpdateDifferentModes:(NSArray*)modeArray uid:(NSString *)uid;



#pragma mark- 更新
/**  更新 表内 满足条件 的 那些 字段的值
 update 表明 set 字段1=字段1值,字段2=字段2值 ... where 主键 = '主键';
 whereStr   -->  @"intAge > 10"
 */
+(BOOL)updateMode:(Class)cls columnName:(NSString *)columnName value:(id)value whereStr:(NSString *)whereStr uid:(NSString *)uid;


/**  更新 表内 满足条件 的 那些 字段的值
 update 表明 set 字段1=字段1值,字段2=字段2值 ... where 主键 = '主键';
 */
+(BOOL)updateModeArr:(Class)cls columnNames:(NSArray *)columnNames values:(NSArray *)values whereStr:(NSString *)whereStr uid:(NSString *)uid;






#pragma mark- 删除
/** 删除 表中 模型对应的 记录 (参考主键) */
+(BOOL)deleteMode:(id)mode uid:(NSString *)uid;

/** 删除 表中 所有的记录 */
+(BOOL)deleteAllMode:(Class)cls uid:(NSString *)uid;


/** 删除 表中 满足 whereStr 的记录 
 age > 19 
 score > 60 or sex = 'nan'*/
+(BOOL)deleteMode:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid;

/** 删除数据库中 字段 满足  relationType value 的记录*/
+(BOOL)deleteMode:(Class)cls columnName:(NSString *)columnName  relationType:(SqliteRelationType)relationType value:(id)value uid:(NSString *)uid;



@end
