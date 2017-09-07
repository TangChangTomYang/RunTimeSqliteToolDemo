//
//  YRmode.m
//  SQLITEToolDemo
//
//  Created by 　yangrui on 2017/9/5.
//  Copyright © 2017年 yangrui. All rights reserved.
//

#import "YRmode.h"

@implementation YRmode

  /**
   @property(nonatomic, strong)NSString *name;
   @property(nonatomic, strong)NSInteger age;
   */


-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.age forKey:@"age"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.age = [aDecoder decodeIntegerForKey:@"age"];
    }
    return self;
}


@end
