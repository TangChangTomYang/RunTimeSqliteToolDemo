//
//  YRSqliteModeTool.m
//  SQLITEToolDemo
//
//  Created by yangrui on 2017/9/2.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import "YRSqliteModeTool.h"
#import "YRModeTool.h"
#import "NSValue+CGValue.h"
#import "NSString+DictionaryArrayData.h"

@implementation YRSqliteModeTool



#pragma mark- 数据库 表相关操作
/** 给一个对象的 类型 创建一个  正式数据库的表 */
+(BOOL)createTable:(Class)cls uid:(NSString *)uid{

  return   [self newTable:cls uid:uid temp:NO];
}

/** 数据库数据迁移(有映射关系)  (有映射关系的字段和字段的值都会 迁移) */
+(BOOL)updateTable:(Class)cls withMapRelationUid:(NSString *)uid{
    
    
 return    [self updateTable:cls mapRelation:YES uid:uid];
}

/** 数据库数据迁移(有映射关系)  (有映射关系的字段和字段的值都会 迁移) */
+(BOOL)updateTable:(Class)cls mapRelation:(BOOL)mapRelation uid:(NSString *)uid{
    
    if (![YRTableTool isTableExists:cls uid:uid]) {
        
        if (! [self createTable:cls uid:uid]) {
            YRLog(@" 在 更新 表: %@ 时,表不存在,创建表失败",cls);
            return NO;
        }
        return YES;
    }
    
    
    BOOL updateResult = YES;
    if ([YRTableTool isRequired2UpdateTable:cls uid:uid] == YES) {
        
        
        NSString *tableName = [YRModeTool tableName:cls];
        NSString *tempTableName = [YRModeTool temp_tableName:cls];
        
        NSMutableArray<NSString *> *sqls = [NSMutableArray array];
        
        // 迁移 数据库的数据
        //1.根据 类型 创建一个 xxx_temp 名字的临时表
        NSString *createTempTableSql = [YRModeTool createTempTableString:cls];
        [sqls addObject:createTempTableSql];
        
        //0.  如果旧表 记录大于0条 则需要 -> 插入主键 -> 根据主键替换内容
        if ([self recordsCount:cls uid:uid] > 0) {
            
            //2.将旧表的 主键数据 插入新表的主键
            NSString *inserPrimarySql = [NSString stringWithFormat:@"insert into %@(id) select id from %@;",tempTableName,tableName];
            [sqls addObject:inserPrimarySql];
            
            
            //3.根据 插入的主键的数据 依次更新其他字段的数据
            NSArray *columnsInTable =  [YRTableTool sortedTableColumnNames:cls uid:uid];
            NSArray *columnsInMode =   [YRModeTool sortedColumnNames:cls];
            
            for (int i = 0 ; i < columnsInMode.count; i++) {
                
                NSString *columnInMode = columnsInMode[i];
                
                // 默认情况下 模型数据字段 名 和 table 中的字段名一样
                NSString *oldColumnInTable = columnInMode;
                
              
                if ( [cls respondsToSelector:@selector(oldName2NewName:)] && mapRelation == YES) {
                    
                    NSString *tempOldName = [cls  oldName2NewName:columnInMode] ;
                    if (tempOldName.length > 0) {
                        oldColumnInTable = tempOldName;
                    }
                }
                
                
                //
                if ([columnsInTable containsObject:oldColumnInTable]) {
                    // @"update  table_temp set column = (select column from table where table.id = table_tem.id)";
                    NSString *updateColumnSql = [NSString stringWithFormat:@"update  %@ set %@ = (select %@ from %@ where %@.id = %@.id);",tempTableName,columnInMode,oldColumnInTable,tableName,tableName,tempTableName];
                    YRLog(@"updateColumnSql : %@",updateColumnSql);
                    [sqls addObject:updateColumnSql];
                    
                }
                else  if ([columnsInTable containsObject:columnInMode]) {
                    // @"update  table_temp set column = (select column from table where table.id = table_tem.id)";
                    NSString *updateColumnSql = [NSString stringWithFormat:@"update  %@ set %@ = (select %@ from %@ where %@.id = %@.id);",tempTableName,columnInMode,columnInMode,tableName,tableName,tempTableName];
                    YRLog(@"updateColumnSql : %@",updateColumnSql);
                    [sqls addObject:updateColumnSql];
                    
                }
                
            }
            
        }
        
        //4.将就的表 删除
        NSString *dropSql = [NSString stringWithFormat:@"drop table if exists %@;",tableName];
        [sqls addObject:dropSql];
        
        //5.将新的 临时的表名字 修改为和旧表 一样
        NSString *renameSql = [NSString stringWithFormat:@"alter table %@ rename to %@;",tempTableName,tableName];
        [sqls addObject:renameSql];
        
        //6. 统一执行sql 语句
        updateResult =  [YRSqliteTool dealSqls:sqls uid:uid];
        
    }
    
    return updateResult;
}



#pragma mark- 查询类方法
/** 根据 sql 语句查询 数据库 ,结果是一个 字典的数据  */
+(NSMutableArray<NSMutableDictionary *>*)queryWithSql:(NSString *)sql uid:(NSString *)uid{

  return  [YRSqliteTool querySql:sql uid:uid];
}

/** 查询数据库数据  的所有模型数组 */
+(NSMutableArray*)queryMode:(Class)cls uid:(NSString *)uid{
    
    
    //1. 判断表格是否存在,不存在则创建表格
    if ([YRTableTool isTableExists:cls uid:uid] == NO) {
        
        if ([self createTable:cls uid:uid] == NO) {
            YRLog(@"查询表格   %@ 时 创建 表格 失败",cls);
            return nil;
        }
    }
    
    //2. 检查表格是否需要更新
    if ( [YRTableTool isRequired2UpdateTable:cls uid:uid] == YES) {
        
        if ([self updateTable:cls withMapRelationUid:uid] == NO) {
            YRLog(@"查询表格 %@ 时 更新表格结构 失败",cls);
            return nil;
        }
    }
    
   
    NSString *tableName = [YRModeTool tableName:cls];
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where ;",tableName];
    NSMutableArray<NSMutableDictionary *> *resultArr = [YRSqliteTool querySql:querySql uid:uid];
    return  [self parseResultArr:resultArr withClass:cls];
    
}

/** 根据模型 查询满足条件的 所有 模型  eg; whereStr = @"name = 'zhangsan'"*/
+(NSMutableArray *)queryModeArray:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid{
    
    //1. 判断表格是否存在,不存在则创建表格
    if ([YRTableTool isTableExists:cls uid:uid] == NO) {
        
        if ([self createTable:cls uid:uid] == NO) {
            YRLog(@"查询表格(queryModeArray)   %@ 时 创建 表格 失败",cls);
            return nil;
        }
    }
    
    //2. 检查表格是否需要更新
    if ( [YRTableTool isRequired2UpdateTable:cls uid:uid] == YES) {
        
        if ([self updateTable:cls withMapRelationUid:uid] == NO) {
            YRLog(@"查询表格(queryModeArray) %@ 时 更新表格结构 失败",cls);
            return nil;
        }
    }
    
    
    NSString *tableName = [YRModeTool tableName:cls];
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where %@;",tableName,whereStr]; 
    NSMutableArray<NSMutableDictionary *> *resultArr = [YRSqliteTool querySql:querySql uid:uid];
    
    return  [self parseResultArr:resultArr withClass:cls];
   
}

/** 查询数据库数据  name != value*/
+(NSMutableArray *)queryModeArray:(Class)cls  columnName:(NSString *)columnName  relationType:(SqliteRelationType)relationType value:(id)value  uid:(NSString *)uid{
    NSString *relationStr = [self sqliteRelationDic][@(relationType)];
    NSString *whereStr = [NSString stringWithFormat:@"%@ %@ '%@'",columnName,relationStr,value ];
    return [self queryModeArray:cls whereStr:whereStr uid:uid];

}





#pragma mark- 数据库 数据类(记录类)操作
+(BOOL)saveOrUpdateMode:(id)mode uid:(NSString *)uid{
    
    // 用户 可以使用这个方法直接保存 模型数据
    Class cls = [mode class];
    
    //1. 判断表格是否存在,不存在则创建表格
    if ([YRTableTool isTableExists:cls uid:uid] == NO) {
        
        if ([self createTable:cls uid:uid] == NO) {
            YRLog(@"在保存 更新 模型数据时 创建 表格 失败");
            return NO;
        }
    }
    
    //2. 检查表格是否需要更新
    if ( [YRTableTool isRequired2UpdateTable:cls uid:uid] == YES) {
        
        if ([self updateTable:cls withMapRelationUid:uid] == NO) {
            YRLog(@"在保存 更新 模型数据时 更新表格结构 失败");
            return NO;
        }
    }
    
    //3.
    NSString * saveOrUpdateSql = [self createSaveOrUpdataSqlForMode:mode uid:uid needCheckExistsAndUpdate:NO];
    
    if (saveOrUpdateSql.length == 0) {
        return NO;
    }
    
    return [YRSqliteTool dealSql:saveOrUpdateSql uid:uid];
    
}

/** 保存 或者 更新 modeArray */
+(BOOL)saveOrUpdateSameModeArray:(NSArray*)modeArray uid:(NSString *)uid{
    
    // 用户 可以使用这个方法直接保存 模型数据
    id mode = modeArray[0];
    
    Class cls = [mode class];
    
    //1. 判断表格是否存在,不存在则创建表格
    if ([YRTableTool isTableExists:cls uid:uid] == NO) {
        
        if ([self createTable:cls uid:uid] == NO) {
            YRLog(@"在保存 更新 模型数据时 创建 表格 失败");
            return NO;
        }
    }
    
    //2. 检查表格是否需要更新
    if ( [YRTableTool isRequired2UpdateTable:cls uid:uid] == YES) {
        
        if ([self updateTable:cls withMapRelationUid:uid] == NO) {
            YRLog(@"在保存 更新 模型数据时 更新表格结构 失败");
            return NO;
        }
    }
    
    NSMutableArray *sqls = [NSMutableArray array];
    for (int  i = 0; i < modeArray.count; i++) {
        
        NSString *sqlStr = [self createSaveOrUpdataSqlForMode:modeArray[i] uid:uid needCheckExistsAndUpdate:NO];
        if (sqlStr.length > 0) {
            [sqls addObject:sqlStr];
        }
        else{
            YRLog(@"在 保存或者更新 第  %d  条数据时 失败 %@",i,cls);
            return NO;
        }
    }
    
    return  [YRSqliteTool dealSqls:sqls uid:uid];
    
}

/** 保存 或者 更新 modeArray  array 内的对象可以是不同 类型  */
+(BOOL)saveOrUpdateDifferentModeArray:(NSArray*)modeArray uid:(NSString *)uid{
    
    NSMutableArray *sqls = [NSMutableArray array];
    for (int  i = 0; i < modeArray.count; i++) {
        
        NSString *sqlStr = [self createSaveOrUpdataSqlForMode:modeArray[i] uid:uid needCheckExistsAndUpdate:YES];
        if (sqlStr.length > 0) {
            [sqls addObject:sqlStr];
        }
        else{
            YRLog(@"在 保存或者更新不同模型数据 第  %d  条数据时 失败 %@",i,[modeArray[i] class]);
            return NO;
        }
    }
    
    return  [YRSqliteTool dealSqls:sqls uid:uid];
}



#pragma mark- 更新
/**  更新 表内 满足条件 的 那些 字段的值
 // update 表明 set 字段1=字段1值,字段2=字段2值 ... where 主键 = '主键';
 */
+(BOOL)updateMode:(Class)cls columnName:(NSString *)columnName value:(id)value whereStr:(NSString *)whereStr uid:(NSString *)uid{
    
    //1. 判断表格是否存在,不存在则创建表格
    if ([YRTableTool isTableExists:cls uid:uid] == NO) {
        
        if ([self createTable:cls uid:uid] == NO) {
            YRLog(@"createSaveOrUpdataSql  %@ 时 创建 表格 失败",cls);
            return NO;
        }
    }
    
    //2. 检查表格是否需要更新
    if ( [YRTableTool isRequired2UpdateTable:cls uid:uid] == YES) {
        
        if ([self updateTable:cls withMapRelationUid:uid] == NO) {
            YRLog(@"createSaveOrUpdataSql %@ 时 更新表格结构 失败",cls);
            return NO;
        }
    }
    
    //3. value 转换
    id columnValue = value;
    if (columnValue == nil) {
        //5.2 将 columnValue 转换成 sqlite 中匹配的数据类型
        columnValue = [YRModeTool nilValueForClass:cls name:columnName];
        
    }
    columnValue = [self convertValue:columnValue toSqliteValueinClass:cls columnName:columnName];
    NSString *tableName = [YRModeTool tableName:cls];
    NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where %@ ",tableName,columnName,columnValue,whereStr];
    
    return [YRSqliteTool dealSql:updateSql uid:uid];
    
}

/**  更新 表内 满足条件 的 那些 字段的值
 update 表明 set 字段1=字段1值,字段2=字段2值 ... where 主键 = '主键';
 */
+(BOOL)updateModeArr:(Class)cls columnNames:(NSArray<NSString *>*)columnNames values:(NSArray *)values whereStr:(NSString *)whereStr uid:(NSString *)uid{
    
    //1. 判断表格是否存在,不存在则创建表格
    if ([YRTableTool isTableExists:cls uid:uid] == NO) {
        
        if ([self createTable:cls uid:uid] == NO) {
            YRLog(@"createSaveOrUpdataSql  %@ 时 创建 表格 失败",cls);
            return NO;
        }
    }
    
    //2. 检查表格是否需要更新
    if ( [YRTableTool isRequired2UpdateTable:cls uid:uid] == YES) {
        
        if ([self updateTable:cls withMapRelationUid:uid] == NO) {
            YRLog(@"createSaveOrUpdataSql %@ 时 更新表格结构 失败",cls);
            return NO;
        }
    }
    
    
    NSMutableArray *setArrM = [NSMutableArray array];
    for (int i = 0; i < values.count; i++) {
        
        id value =  [self convertValue:values[i] toSqliteValueinClass:cls columnName:columnNames[i]];
        
        [setArrM addObject:[NSString stringWithFormat:@"%@ = '%@'",columnNames[i],value ]];
        
    }
    
    NSString *tableName = [YRModeTool tableName:cls];
    NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@ where %@ ",tableName,[setArrM componentsJoinedByString:@","],whereStr];
    
    
    return  [YRSqliteTool dealSql:updateSql uid:uid];
    
}


#pragma mark- 删除
/** 删除 表中 模型对应的 记录 (参考主键) */
+(BOOL)deleteMode:(id)mode uid:(NSString *)uid{
    // 用户 可以使用这个方法直接保存 模型数据
    Class cls = [mode class];
    
    //1. 判断表格是否存在,不存在则创建表格
    if ([YRTableTool isTableExists:cls uid:uid] == NO) {
        
        YRLog(@"删除 mode: %@ 时,发现 mode 对应的表格不存在", mode);
        if ([self createTable:cls uid:uid] == NO) {
            YRLog(@"删除 mode: %@ 时,发现 mode 对应的表格不存在,创建 表格 失败", mode);
            return NO;
        }
        return YES;
    }
    
    
    if(![cls  respondsToSelector:@selector(queryPrimarykey)]){
        
        YRLog(@"在删除 模型数据时 根据模型的 类型没有找到 '关键查询主键'");
        return NO;
    }
    
    NSString *queryPrimaryKey =  [cls queryPrimarykey];
    id queryPrimaryValue = [mode valueForKeyPath:queryPrimaryKey];
    if(queryPrimaryValue == nil){
        YRLog(@"警告! 在保存 更新 模型数据时 根据模型的 类型没有找到 '关键查询主键  的值'");
        queryPrimaryValue = @"";
        
    }
    
    NSString *tableName = [YRModeTool tableName:cls];
    NSString *delteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@';",tableName,queryPrimaryKey,queryPrimaryValue];

    return  [YRSqliteTool dealSql:delteSql uid:uid];
}

/** 删除 表中 所有的记录 */
+(BOOL)deleteAllMode:(Class)cls uid:(NSString *)uid{
    //1. 判断表格是否存在,不存在则创建表格
    if ([YRTableTool isTableExists:cls uid:uid] == NO) {
        
        YRLog(@"删除 所有的记录 时,表格 %@ 不存在", cls);
        if ([self createTable:cls uid:uid] == NO) {
            YRLog(@"删除 所有的记录 时,表格 %@ 不存在,创建 表格 失败", cls);
            return NO;
        }
        return YES;
    }
    
    NSString *delteSql = [NSString stringWithFormat:@"delete from %@ ;",[YRModeTool tableName:cls]];
    
    return  [YRSqliteTool dealSql:delteSql uid:uid];
}


/** 删除 表中 满足 whereStr 的记录 */
+(BOOL)deleteMode:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid{

    //1. 判断表格是否存在,不存在则创建表格
    if ([YRTableTool isTableExists:cls uid:uid] == NO) {
        
        YRLog(@"删除 所有的记录 时,表格 %@ 不存在", cls);
        if ([self createTable:cls uid:uid] == NO) {
            YRLog(@"删除 所有的记录 时,表格 %@ 不存在,创建 表格 失败", cls);
            return NO;
        }
        return YES;
    }
    
    NSString *delteSql = nil;
    if (whereStr.length > 0) {
        delteSql = [NSString stringWithFormat:@"delete from %@  where %@;",[YRModeTool tableName:cls],whereStr];
    }
    else{
        delteSql = [NSString stringWithFormat:@"delete from %@ ;",[YRModeTool tableName:cls]];
    }
    
    
    return  [YRSqliteTool dealSql:delteSql uid:uid];

}

/** 删除数据库中 字段 满足  relationType value 的记录*/
+(BOOL)deleteMode:(Class)cls columnName:(NSString *)columnName  relationType:(SqliteRelationType)relationType value:(id)value uid:(NSString *)uid{
    //1. 判断表格是否存在,不存在则创建表格
    if ([YRTableTool isTableExists:cls uid:uid] == NO) {
        
        YRLog(@"删除 所有的记录 时,表格 %@ 不存在", cls);
        if ([self createTable:cls uid:uid] == NO) {
            YRLog(@"删除 所有的记录 时,表格 %@ 不存在,创建 表格 失败", cls);
            return NO;
        }
        return YES;
    }
    
    NSString *delteSql = nil;
    if (columnName.length > 0 && value != nil) {
        delteSql = [NSString stringWithFormat:@"delete from %@  where %@ %@ '%@';",[YRModeTool tableName:cls],columnName,[self sqliteRelationDic][@(relationType)],value];
    }
    else{
        delteSql = [NSString stringWithFormat:@"delete from %@ ;",[YRModeTool tableName:cls]];
    }
    
    
    return  [YRSqliteTool dealSql:delteSql uid:uid];
}









#pragma mark- 私有方法  内部调用
  /**将查询到的 数组 字典 转换为 模型的数据*/
+(NSMutableArray *)parseResultArr:(NSArray <NSDictionary *>*)resultArr withClass:(Class)cls{
    
    NSMutableArray *modesM = [NSMutableArray array];
    NSDictionary *nameOCObjTypeDic = [YRModeTool classIvarNameAndOCObjType:cls];
    for (NSDictionary *dic in resultArr){
        
        id mode = [[cls alloc] init];
        
        [dic enumerateKeysAndObjectsUsingBlock:^(NSString *name, id  _Nonnull value, BOOL * _Nonnull stop) {
            
            NSString *OCObjType = nameOCObjTypeDic[name];
            
            if (![name isEqualToString:@"id"]) {
                
                if ([OCObjType isEqualToString:@"CGPoint"]) {// text -> CGPoint
                    
                    [mode setValue:[NSValue pointValueWithStr:(NSString *)value name:name] forKeyPath:name];
                    
                }
                else if ([OCObjType isEqualToString:@"CGSize"]) {// text -> CGSize
                    
                    [mode setValue:[NSValue sizeValueWithStr:(NSString *)value name:name] forKeyPath:name];
                    
                }
                else if ([OCObjType isEqualToString:@"CGRect"]) {// text -> GRect
                    
                    [mode setValue:[NSValue rectValueWithStr:(NSString *)value name:name]  forKeyPath:name];
                    
                }
                else if ([OCObjType isEqualToString:@"NSData"]) {
                    
                    [mode setValue:[NSString dataWithStr:(NSString *)value name:name] forKey:name];
                    
                }
                else if ([OCObjType isEqualToString:@"NSMutableData"]) {
                    
                    YRLog(@" %@ : %@",value,name);
                    [mode setValue:[NSString mulDataWithStr:(NSString *)value name:name] forKey:name];
                    
                }
                else if ([OCObjType isEqualToString:@"NSArray"] ) {
                    
                    [mode setValue:[NSString arrayWithStr:(NSString *)value name:name] forKey:name];
                }
                else if ([OCObjType isEqualToString:@"NSDictionary"]) {
                    
                    [mode setValue:[NSString dictionaryWithStr:(NSString *)value name:name] forKey:name];
                }
                else if ([OCObjType isEqualToString:@"NSMutableArray"] ) {
                    
                    [mode setValue:[NSString mulArrayWithStr:(NSString *)value name:name]  forKey:name];
                    
                }
                else if ([OCObjType isEqualToString:@"NSMutableDictionary"] ) {
                    
                    [mode setValue:[NSString mulDictionaryWithStr:(NSString *)value name:name]  forKey:name];
                    
                }
                else  {// 其他
                    
                    [mode setValue:value forKeyPath:name];
                }
            }
            
        }];
        
        [modesM addObject:mode];
    }
    return modesM;
    
    
}

/**根据 给定的数据模型 生成 对应的  更新或者插入 的sql 语句,  在生成每个 模型 时 检查 表是否存在 是否需要更新 */
+(NSString *)createSaveOrUpdataSqlForMode:(id)mode  uid:(NSString *)uid needCheckExistsAndUpdate:(BOOL)needCheckExistsAndUpdate{
    
    
  
    // 用户 可以使用这个方法直接保存 模型数据
    Class cls = [mode class];
    
    if (needCheckExistsAndUpdate == YES) {
        //1. 判断表格是否存在,不存在则创建表格
        if ([YRTableTool isTableExists:cls uid:uid] == NO) {
            
            if ([self createTable:cls uid:uid] == NO) {
                YRLog(@"createSaveOrUpdataSql  %@ 时 创建 表格 失败",cls);
                return nil;
            }
        }
        
        //2. 检查表格是否需要更新
        if ( [YRTableTool isRequired2UpdateTable:cls uid:uid] == YES) {
            
            if ([self updateTable:cls withMapRelationUid:uid] == NO) {
                YRLog(@"createSaveOrUpdataSql %@ 时 更新表格结构 失败",cls);
                return nil;
            }
        }
        
    }
    
    
    //3. 判断记录是否存在 主键(不一定是表的主键)
    if(![cls  respondsToSelector:@selector(queryPrimarykey)]){
        
        YRLog(@"在保存 更新 模型数据时 根据模型的 类型没有找到 '关键查询主键',eg: 房间 就是房间号,灯具 就是灯具mac 地址");
        return nil;
    }
    
    NSString *queryPrimaryKey =  [cls queryPrimarykey];
    id queryPrimaryValue = [mode valueForKeyPath:queryPrimaryKey];
    
    if(queryPrimaryValue == nil){
        YRLog(@"警告-----------> 在保存 更新 模型数据时 根据模型的 类型没有找到 '关键查询主键  的值',eg: 关键查询主键是灯具mac地址,地址是 '0311223344556677'");
        queryPrimaryValue = @"";
        
    }
    NSString *tableName = [YRModeTool tableName:cls];
    
    
    //4. 获取字段数组
    NSDictionary *columnNameSqliteTypeDic = [YRModeTool classIvarNameAndSqliteType:cls];
    NSDictionary *columnNameOCObjTypeDic = [YRModeTool classIvarNameAndOCObjType:cls];
    NSArray *columnNames = columnNameSqliteTypeDic.allKeys;
    
    //5. 获取值数组
    NSMutableArray *columnValues = [NSMutableArray array];
    for (NSString *columnName in  columnNames) {
        
        //5.1 这里有风险  value 可能为空
        id columnValue = [YRModeTool valueForKeyPath:columnName mode:mode OCObjType:columnNameOCObjTypeDic[columnName]];
        
        //5.2 将 columnValue 转换成 sqlite 中匹配的数据类型
        columnValue = [self convertValue:columnValue toSqliteValueinClass:cls columnName:columnName];
       
        //5.3
        [columnValues addObject:columnValue];
        
    }
    
    // 拼接 保存
    NSMutableArray *setValueArrM = [NSMutableArray array];
    for (int i = 0 ; i < columnNames.count ; i++ ){
        
        NSString *columnName = columnNames[i];
        id columnValue = columnValues[i];
        
        [setValueArrM addObject:[NSString stringWithFormat:@"%@ = '%@'",columnName,columnValue]];
    }
    
    // 更新   (字段名称 , 字段值)
    // update 表明 set 字段1=字段1值,字段2=字段2值 ... where 主键 = '主键';
    
    NSString *checkModeSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@';",tableName,queryPrimaryKey,queryPrimaryValue];
    NSMutableArray *arrM = [YRSqliteTool querySql:checkModeSql uid:uid];
    NSString *exeSql = @"";
    if (arrM.count > 0) {
        exeSql = [NSString stringWithFormat:@"update %@ set %@ where %@ = '%@';",tableName,[setValueArrM componentsJoinedByString:@","],queryPrimaryKey,queryPrimaryValue];
        
        YRLog(@"更新的sql : %@ for : %@",exeSql,cls);
    }
    else if(columnNames.count > 0){
        //insert into 表名 (字段1,字段2,字段3) values ('值1','值2','值3')
        
        for (int i = 0; i < columnValues.count ; i++) {
            id value = columnValues[i];
            if ([value isKindOfClass:[NSString class]]) {
                
                [columnValues replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"'%@'",value]];
            }
            
        }
        
        exeSql = [NSString stringWithFormat:@"insert into %@(%@) values (%@);",tableName,[columnNames componentsJoinedByString:@","],[columnValues componentsJoinedByString:@","]];
        
        
        YRLog(@"插入的sql : %@ for : %@",exeSql,cls);
    }
    
    
    if (exeSql.length == 0 ) {
        YRLog(@"在生成 %@ 的 保存 更新sql 时 失败",cls);
    }
    
    return exeSql;
    
}

/** 将  Class 类 模型 中 字段columnName 对应的 value 转化成 sqlite 中匹配的数据类型  */
+(id)convertValue:(id)value toSqliteValueinClass:(Class)cls columnName:(NSString *)columnName{

    id columnValue = value;
    // NSData
    if ([columnValue isKindOfClass:[NSData class]]) {
        
        columnValue = [((NSData *)columnValue) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    }
    
    if (columnValue == nil) {
        YRLog(@"警告: 你在更新 或 保存模型数据时,必须保证每个 字段都有值 ,%@ 中 %@ 的值 为nil,去查看",cls,columnName);
        return nil;
        
    }
    
    
    if ([columnValue isKindOfClass:[NSDictionary class]] || [columnValue isKindOfClass:[NSArray class]]) {
        
        NSData *columnValueData = [NSJSONSerialization dataWithJSONObject:columnValue options:NSJSONWritingPrettyPrinted error:nil];
        
        if (columnValueData.length == 0) {
            YRLog(@"警告: 在保存或者更新 %@ 时,错误, %@ 数据不能序列化,",cls,columnValue);
            return nil;
        }
        
        NSString *columnValueDataStr = [[NSString alloc] initWithData:columnValueData encoding:NSUTF8StringEncoding];
        if(columnValueDataStr.length == 0){
            YRLog(@"警告: 在保存或者更新 %@ 时,错误, %@不能转成 字符串,",cls,columnValue);
            return nil;
        }
        columnValue = columnValueDataStr;
        
    }
    else if ([columnValue isKindOfClass:NSClassFromString(@"NSConcreteValue") ]){
        
        NSString *columnValueStr  = [NSString stringOfConcreteValue:columnValue forColumnName:columnName inClass:cls];
        
        if (columnValueStr.length == 0) {
            YRLog(@"警告: 在保存或者更新 %@ 时,错误, %@不能转成 字符串,",cls,columnValue);
            return nil;
        }
        columnValue = columnValueStr;
    }
    
    
    return columnValue;
}

/** 数据库数据迁移 */
+(BOOL)updateTable:(Class)cls uid:(NSString *)uid{
    
    return  [self updateTable:cls mapRelation:NO uid:uid];
}

/** 查询旧表中当前有多少条记录 */
+(NSInteger)recordsCount:(Class)cls uid:(NSString *)uid{
    
    NSString *tableName = [YRModeTool tableName:cls];
    NSString *checkRecordSql = [NSString stringWithFormat:@"select id from %@;",tableName];
    NSArray *arr = [YRSqliteTool querySql:checkRecordSql uid:uid];
    
    return arr.count;
}

/** 给一个对象的 类型 创建一个  临时数据库的表 */
+(BOOL)createTempTable:(Class)cls uid:(NSString *)uid{
    return   [self newTable:cls uid:uid temp:YES];
    
}

/** 给一个对象的 类型 创建一个  正式或者 临时的数据库表 */
+(BOOL)newTable:(Class)cls uid:(NSString *)uid temp:(BOOL)temp{
    
    NSString  *sql = nil;
    if (temp == YES) {
        sql = [YRModeTool createTempTableString:cls];
    }else{
        sql = [YRModeTool createTableString:cls];
    }
  
    if(sql.length == 0)return NO;
    
    return   [YRSqliteTool dealSql:sql uid:uid];
}

+(NSDictionary *)sqliteRelationDic{

    return @{ @(SqliteRelationType_equal):@"=",
              @(SqliteRelationType_more):@">",
              @(SqliteRelationType_less):@"<",
              @(SqliteRelationType_moreEqual):@">=",
              @(SqliteRelationType_lessEqual):@"<=",
              @(SqliteRelationType_notEqual):@"!=",
              };
}









@end















































