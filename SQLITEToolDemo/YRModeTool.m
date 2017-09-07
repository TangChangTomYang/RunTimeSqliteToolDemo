//
//  YRModeTool.m
//  SQLITEToolDemo
//
//  Created by yangrui on 2017/9/2.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import "YRModeTool.h"
#import <objc/runtime.h> // 运行时

@implementation YRModeTool

/** 根据对象的类型获取 数据库表的名字 */
+(NSString *)tableName:(Class)cls{
    
    NSString *name = NSStringFromClass(cls);
    
    return name;
}
/** 根据对象的类型获取 数据库 临时表的名字 */
+(NSString *)temp_tableName:(Class)cls{

   return  [NSString stringWithFormat:@"%@%@",[self tableName:cls],tempTable_SuffixStr];
}

/** (自己添加主键 id )将成员 所有的成员变量 数据类型 - > name type ([约束]),name2 type ([约束])*/
+(NSString *)createTableString:(Class)cls{
    
    return   [self createTableString:cls  temp:NO];
}

/** 生成一个 创建正式表的 sql 语句 字符串 (会自动添加id 主键 并 查询添加 必要的 字段 约束)*/
+(NSString *)createTempTableString:(Class)cls{
    
    return   [self createTableString:cls  temp:YES];
}

/** 排序后的 有效的的所有字段 [字段1  字段2]  */
+(NSArray<NSString *> *)sortedColumnNames:(Class)cls{
    NSDictionary *ivarNametypeDic =  [self classIvarNameAndSqliteType:cls];
    
    NSArray *ivarNames = ivarNametypeDic.allKeys;
    if (ivarNames.count == 0) return nil;
    
    ivarNames = [ivarNames sortedArrayUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        
        return [obj1 compare:obj2];
    }];
    
    return ivarNames;
}


/** 对象 类 -> (成员变量名 : sqlite数据类型 )*/
+(NSMutableDictionary<NSString *, NSString*> *)classIvarNameAndSqliteType:(Class)cls{

    NSMutableDictionary *dicM = [self classIvarNameAndOCRunTimeType:cls];
    NSDictionary *sqliteTypeDic = [self OCRunTimeType2SqliteTypeDic];

    [dicM enumerateKeysAndObjectsUsingBlock:^(NSString  *key, NSString  *obj, BOOL * _Nonnull stop) {
        
        NSString *sqliteType = sqliteTypeDic[obj];
        
        if (sqliteType.length == 0) {
            YRLog(@"警告!: 在执行 运行时 --> Sqlite 类型,运行时: %@ 没找到对应类型,数据丢失",obj);
        }
        dicM[key] = sqliteType;
    }];
    return dicM;
}

/** 对象 类 -> (成员变量名 : OC对象数据类型 )*/
+(NSMutableDictionary<NSString *, NSString*> *)classIvarNameAndOCObjType:(Class)cls{
    
    NSMutableDictionary *dicM = [self classIvarNameAndOCRunTimeType:cls];
    NSDictionary *ocTypeDic = [self ocRuntimeType2OCObjTypeDic];
    [dicM enumerateKeysAndObjectsUsingBlock:^(NSString  *key, NSString  *obj, BOOL * _Nonnull stop) {
        NSString *ocObjType = ocTypeDic[obj];;
        if (ocObjType.length == 0) {
            YRLog(@"警告!: 在执行 运行时 --> oc  obj 对象时,运行时: %@ 没找到对应类型,数据丢失",obj);
        }
        dicM[key] = ocObjType;
        
        
    }];
    return dicM;
}

/** 将成员 所有的成员变量 数据类型 - > name type ([约束]),name2 type ([约束])*/
+(NSString *)columnNameSqliteFieldString:(Class)cls{

   NSDictionary *dic = [self classIvarNameAndSqliteType:cls];
    
    if (dic.allValues.count == 0) {
        YRLog(@"在获取 模型表字段时, 对象 字段数为0 ,必须大于等于1个");
        return nil;
    }
    
    NSMutableArray *columnNametypeArr = [NSMutableArray array];
    
    
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key,NSString *obj, BOOL * _Nonnull stop) {
        
//        NSString *contraintStr = nil;
//        if([cls respondsToSelector:@selector(constraintForIvarName:)]){
//            contraintStr =  [cls constraintForIvarName:key];
//        }
//        
//        if(contraintStr.length > 0){
//            
//            [columnNametypeArr addObject: [NSString stringWithFormat:@"%@  %@  %@",key, obj,contraintStr]];
//        }
//        else{
            [columnNametypeArr addObject:[NSString stringWithFormat:@"%@  %@",key, obj]];
//        }
        
    }];
    
   return  [columnNametypeArr componentsJoinedByString:@","];
    
    
}





#pragma mark- 私有方法

/** 生成一个 正式或 临时的表的 sql 语句*/
+(NSString *)createTableString:(Class)cls temp:(BOOL)temp{
    
    //1. 表明
    NSString *tableName = nil;
    if (temp == YES) {
        tableName = [YRModeTool temp_tableName:cls];
    }
    else{
        tableName = [YRModeTool tableName:cls];
    }
    
    //2. 字段 + (约束)
    NSString *columnStr = [YRModeTool columnNameSqliteFieldString:cls];
    
    if(columnStr.length == 0){
        
        YRLog(@"创建table 的有效字段个数必须大于0");
        return nil;
    }
    //3. 表明 + 主键 + 字段s
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement, %@);",tableName,columnStr];
    
    return sql;
}

/** 对象 类 -> (成员变量名 :OC 运行时数据类型 )*/
+(NSMutableDictionary<NSString *, NSString*> *)classIvarNameAndOCRunTimeType:(Class)cls{
    
    unsigned int ivarCount = 0;
    Ivar *ivarList = class_copyIvarList(cls, &ivarCount);
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    
    NSArray *ignoreIvarArr = nil;
    if ([cls  respondsToSelector:@selector(ignoreIvarList)]) {
        ignoreIvarArr = [cls ignoreIvarList];
    }
    
    for ( int i = 0 ; i< ivarCount; i++) {
        
        // class 内对象定义的 实例变量 (变量类型和变量名)
        Ivar ivar = ivarList[i];
        
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if ([ivarName hasPrefix:@"_"]) {
            ivarName = [ivarName substringFromIndex:1];
        }
        
       
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        if ([ivarType containsString:@"@\""]) {
              ivarType = [ivarType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        }
        
        if ([ivarType containsString:@"\""]) {
            ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        }

        if ([ivarType containsString:@" "]) {
            ivarType = [ivarType stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        
        if (!([ignoreIvarArr containsObject:ivarName] || [ignoreIvarArr containsObject:[NSString stringWithFormat:@"_%@",ivarName]] )) {
            dicM[ivarName] = ivarType;
        }
        
    }
    
    if(dicM.allValues.count == 0){
        YRLog(@"警告:  在获取 表字段时, 检测到有效字段数为0,请确认代码");
    }

    
    return dicM;
    
}





/** OC运行时数据类型 -> sqlite 数据类型  的映射关系 */
+(NSDictionary<NSString *,NSString *> *)OCRunTimeType2SqliteTypeDic{

    return  @{
       @"d":@"real",//CGFloat double
       @"f":@"real",//float
       
       @"i":@"integer",//int
       @"q":@"integer",//long
       @"Q":@"integer",//long long
       @"B":@"integer",//bool
       
       @"NSData":@"text",
       @"NSMutableData":@"text",
       
       @"NSString":@"text",
       
       @"NSArray":@"text",
       @"NSMutableArray":@"text",
       
       @"NSDictionary":@"text",
       @"NSMutableDictionary":@"text",
       
       @"{CGRect=origin{CGPoint=xdyd}size{CGSize=widthdheightd}}":@"text",
       @"{CGPoint=xdyd}":@"text",
       @"{CGSize=widthdheightd}":@"text",

       
       @"NSNumber":@"text"
       };
    
}


/** OC运行时数据类型 -> OC Obj对象 数据类型  的映射关系 */
+(NSDictionary<NSString *,NSString *> *)ocRuntimeType2OCObjTypeDic{
    
    return  @{
              @"d":@"CGFloat",
              @"f":@"float",//
              
              @"i":@"int",
              @"q":@"long",
              @"Q":@"long long",
              @"B":@"BOOL",
              
              @"NSData":@"NSData",
              @"NSMutableData":@"NSMutableData",
              
              @"NSString":@"NSString",
              
              @"NSArray":@"NSArray",
              @"NSMutableArray":@"NSMutableArray",
              
              @"NSDictionary":@"NSDictionary",
              @"NSMutableDictionary":@"NSMutableDictionary",
              
              @"{CGRect=origin{CGPoint=xdyd}size{CGSize=widthdheightd}}":@"CGRect",
              @"{CGPoint=xdyd}":@"CGPoint",
              @"{CGSize=widthdheightd}":@"CGSize"
              
              
              };
    
}


/** OC运行时数据类型 -> OC Obj对象 数据类型  的映射关系 */
+(NSDictionary *)defaultValueForOCObjType:(NSString *)OCObjType{
    
   NSDictionary *dic =  @{
              @"CGFloat":@(0),
              @"float":@(0),
              
              @"int":@(0),
              @"long":@(0),
              @"long long":@(0),
              @"BOOL":@(NO),
              
              @"NSData":[NSData data],
              @"NSMutableData":[NSMutableData data],
              
              @"NSString":@"",
              
              @"NSArray":[NSArray array],
              @"NSMutableArray":[NSMutableArray array],
              
              @"NSDictionary":[NSDictionary dictionary],
              @"NSMutableDictionary":[NSMutableDictionary dictionary],
              
              @"CGRect":[NSValue valueWithCGRect:CGRectZero],
              @"CGPoint":[NSValue valueWithCGPoint:CGPointZero],
              @"CGSize": [NSValue valueWithCGSize:CGSizeZero]
              };
    
    
    return dic[OCObjType];
    
}


  /** 获取 mode 中 keyPath 对应的值, 若 value 不存在 则返回 OCObjType 对应的默认值 */
+(id)valueForKeyPath:(NSString *)keyPath mode:(id)mode OCObjType:(NSString *)OCObjType{

    id value = [mode valueForKeyPath:keyPath];
    
    if (value == nil) {
        value =  [self defaultValueForOCObjType:OCObjType];
    }
    return value;
    
}

  /**  空值得默认值 */
+(id)nilValueForClass:(Class)cls name:(NSString *)name{
    
    NSString *OCObjType = [YRModeTool classIvarNameAndOCObjType:cls][name];
    
    return [self defaultValueForOCObjType:OCObjType];
}



@end
