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
