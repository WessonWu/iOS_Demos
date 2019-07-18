//
//  Test.h
//  SwizzleMethodDemo
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Category调用顺序参阅：https://tech.meituan.com/2015/03/03/diveintocategory.html
 
 load方法调用顺序：原生类 > 分类
 分类load调用顺序：根据Build Phases -> Complie Sources的文件顺序
 */

NS_ASSUME_NONNULL_BEGIN

@interface Test : NSObject

+ (void)doSomething;

@end

NS_ASSUME_NONNULL_END
