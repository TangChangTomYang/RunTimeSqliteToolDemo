//
//  TestMode.h
//  SQLITEToolDemo
//
//  Created by yangrui on 2017/9/2.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YRColumnProtocal.h"
@interface TestMode : NSObject<YRColumnProtocal>


@property(nonatomic, assign)int  intAge;
@property(nonatomic, assign)long  longAge;
@property(nonatomic, assign)NSInteger  NSIntegerAge;

@property(nonatomic, assign)double  doubleScore;
@property(nonatomic, assign)float  floatScore;
@property(nonatomic, assign)CGFloat  CGFloatScore;

@property(nonatomic, assign)CGRect  frame;
@property(nonatomic, assign)CGSize  size;
@property(nonatomic, assign)CGPoint  point;

@property(nonatomic, strong)NSString *name;


@property(nonatomic, strong)NSArray *friends;
@property(nonatomic, strong)NSMutableArray *friendsM;

@property(nonatomic, strong)NSDictionary *relationDic ;
@property(nonatomic, strong)NSMutableDictionary *relationDicM;

@property(nonatomic, strong)NSData *data;
@property(nonatomic, strong)NSMutableData *dataM;

@end
