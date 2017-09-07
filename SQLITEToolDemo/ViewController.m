//
//  ViewController.m
//  SQLITEToolDemo
//
//  Created by yangrui on 2017/9/2.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import "ViewController.h"
#import "TestMode.h"
#import "YRTableTool.h"
#import "abc.h"

#import "YRmode.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  
//   TestMode *mode1 = [TestMode new];
//    mode1.name = @"zhangsan";
//    mode1.frame = CGRectMake(101, 201, 301, 401);
//    
//    TestMode *mode2 = [TestMode new];
//    mode2.name = @"zhangsan";
//    mode2.frame = CGRectMake(102, 202, 302, 402);
//    
//    
//    TestMode *mode3 = [TestMode new];
//    mode3.name = @"zhangsan";
//    mode3.frame = CGRectMake(103, 203, 303, 403);
//    
//    
//    BOOL rst = [YRSqliteModeTool saveOrUpdateSameModeArray:@[mode1,mode2,mode3] uid:@"zghang"];
//     YRLog(@"rst : %d",rst);
    
   NSString *whereStr = [NSString stringWithFormat:@"frame != '%@'",NSStringFromCGRect(CGRectMake(102, 202, 302, 402)) ];
  
    
    NSMutableArray *arrM = [YRSqliteModeTool queryModeArray:[TestMode class] columnName:@"frame" relationType:SqliteRelationType_notEqual value:NSStringFromCGRect(CGRectMake(102, 202, 302, 402)) uid:@"zghang"];
    YRLog(@"%@",arrM);
  
}


-(void)queryrelation{
    NSString *whereStr = [NSString stringWithFormat:@"frame != '%@'",NSStringFromCGRect(CGRectMake(102, 202, 302, 402)) ];
    NSMutableArray *arrM = [YRSqliteModeTool queryModeArray:[TestMode class] whereStr:whereStr uid:@"zghang"];
    
    YRLog(@"%@",arrM);
}

-(void)deleteAll{
    BOOL rst = [YRSqliteModeTool deleteAllMode:[TestMode class] uid:@"zghang"];
    YRLog(@"rst : %d",rst);
}

-(void)deletemode{
    TestMode *mode = [TestMode new];
    mode.name = @"xhangsna";
    BOOL rst = [YRSqliteModeTool deleteMode:mode uid:@"zghang"];
    YRLog(@"rst : %d",rst);
}


-(void)saveMode{
    TestMode *mode = [TestMode new];
    mode.name = @"xhangsna";
    BOOL rst = [YRSqliteModeTool saveOrUpdateMode:mode uid:@"zghang"];
    YRLog(@"rst : %d",rst);
}

-(void)updateModes{
    
    NSString * rectStr =  NSStringFromCGRect(CGRectMake(200, 100, 100, 100));
    BOOL rst =  [YRSqliteModeTool updateModeArr:[TestMode class] columnNames:@[@"frame",@"name"] values:@[rectStr,@"gunkaixi"] whereStr:@"intAge < 30" uid:@"zghang"];
    YRLog(@"rst : %d",rst);
    
    

//    NSValue *rectValue = [NSValue valueWithCGRect:CGRectMake(100, 100, 100, 100)];
//    BOOL rst =  [YRSqliteModeTool updateModeArr:[TestMode class] columnNames:@[@"frame",@"name"] values:@[rectValue,@"gunkaixi"] whereStr:@"intAge < 30" uid:@"zghang"];
//    YRLog(@"rst : %d",rst);

}

-(void)updatemode{

    BOOL rst = [YRSqliteModeTool updateMode:[TestMode class] columnName:@"intAge" value:@(20) whereStr:@"intAge > 10" uid:@"zghang"];
    
    YRLog(@"rst : %d",rst);
}


@end
