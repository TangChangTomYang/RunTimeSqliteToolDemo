//
//  YRModeToolProtocal.h
//  SQLITEToolDemo
//
//  Created by yangrui on 2017/9/2.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YRColumnProtocal <NSObject>

@optional

/** 忽略的字段s */
+(NSArray<NSString *> *)ignoreIvarList;

/** 通过 模型中旧的名字 查找到数据库中 对应的 旧字段名 , 保证数据迁移时 有对应关系*/
+(NSString *)oldName2NewName:(NSString *)newName;


@required
/** 外面操作数据库时查询时 依赖的字段  eg: 房间 就是房间号,灯具 就是灯具mac 地址 */
+(NSString *)queryPrimarykey;
@end
