//
//  TestMode.m
//  SQLITEToolDemo
//
//  Created by yangrui on 2017/9/2.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import "TestMode.h"

@interface TestMode ()
@end

@implementation TestMode


//-(instancetype)init{
//    self = [super init];
//    if (self) {
//      
////        self.intAge ;
////        self.longAge;
////        self.NSIntegerAge;
////        
////        self.doubleScore;
////        self.floatScore;
////        self.CGFloatScore;
//        
//        self.frame = CGRectZero;
//        self.size = CGSizeZero;
//        self.point = CGPointZero;
//        
//        self.name = @"aa";
//        
//        self.friends = @[@"friends"];
//        self.friendsM = [@[@"friendsM"] mutableCopy];
//        
//        self.relationDic = @{@"relationDic":@"relationDic"};
//        self.relationDicM = [@{@"relationDicM":@"relationDicM"}mutableCopy];
//        
//       
//        
//        self.data =  UIImagePNGRepresentation([UIImage imageNamed:@"avc"]);
//        self.dataM = [[@"dataM" dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
//
//    }
//    return self;
//}

#pragma mark- 数据库协议
/** 通过 模型中旧的名字 查找到数据库中 对应的 旧字段名 */
+(NSString *)oldName2NewName:(NSString *)newName{

    //@{@"新名字": @"旧名字"}
    NSDictionary *newOldMapRelationDic = @{@"age2":@"age不不不",
                                           @"name":@"name2"};
    return newOldMapRelationDic[newName];
}


/** 忽略的字段s */
//+(NSArray<NSString *> *)ignoreIvarList{
//
//    return @[@"name"];
//}





#warning  数据库协议  必须要实现这个方法-> 外面查询数据 更新数据的依据 字段
/** 外面操作数据库时查询时 依赖的字段  */
+(NSString *)queryPrimarykey{
    return @"name";
}

@end
