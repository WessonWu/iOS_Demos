//
//  IPConfig.h
//  IPConfig_OC
//
//  Created by wuweixin on 2019/5/24.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSString * _Nonnull kWXConfigInterfaceWifi = @"en0";
static const NSString * _Nonnull kWXConfigInterfaceCellular = @"pdp_ip0";
static const NSString * _Nonnull kWXConfigInterfaceVPN = @"utun0";
static const NSString * _Nonnull kWXIPConfigIPV4 = @"ipv4";
static const NSString * _Nonnull kWXIPConfigIPV6 = @"ipv6";

typedef NSDictionary<NSString*, NSString*> WXConfigIPMap;

NS_ASSUME_NONNULL_BEGIN

@interface WXIPConfig : NSObject

+ (NSString *)keyWithName: (NSString*)name version: (NSString*)version;
+ (nonnull WXConfigIPMap*)getAllIPs;
+ (nullable NSString*)getIPWithInterface: (NSString*)interface version: (NSString*)version;

@end

NS_ASSUME_NONNULL_END
