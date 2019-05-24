//
//  IPConfig.m
//  IPConfig_OC
//
//  Created by wuweixin on 2019/5/24.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

#import "WXIPConfig.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <errno.h>
#include <net/if_dl.h>
#include <net/ethernet.h>
#include <ifaddrs.h>
#include <arpa/inet.h>


@implementation WXIPConfig

+ (NSString *)keyWithName: (NSString*)name version: (NSString*)version {
    return [NSString stringWithFormat:@"%@/%@", name, version];
}

+ (nonnull NSDictionary *)getAllIPs {
    NSMutableDictionary *ips = [[NSMutableDictionary alloc] initWithCapacity:32];
    struct ifaddrs *interfaces;
    if (!getifaddrs(&interfaces)) {
        struct ifaddrs *temp_interface;
        for (temp_interface = interfaces; temp_interface != NULL; temp_interface = temp_interface->ifa_next) {
            const struct sockaddr_in *addr = (const struct sockaddr_in*)temp_interface->ifa_addr;
            if (addr == NULL) {
                continue;
            }
            
            sa_family_t family = addr->sin_family;
            if (!(family == AF_INET || family == AF_INET6)) {
                continue;
            }
            
            NSString *name = [NSString stringWithUTF8String:temp_interface->ifa_name];
            const NSString *version;
            char addrBuffer[MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN)];
            const char *result;
            
            if (family == AF_INET) {
                version = kWXIPConfigIPV4;
                result = inet_ntop(AF_INET, &addr->sin_addr, addrBuffer, INET_ADDRSTRLEN);
            } else {
                version = kWXIPConfigIPV6;
                const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)temp_interface->ifa_addr;
                result = inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuffer, INET6_ADDRSTRLEN);
            }
            
            if (result != NULL) {
                NSString *key = [NSString stringWithFormat:@"%@/%@", name, version];
                ips[key] = [NSString stringWithUTF8String:addrBuffer];
            }
        }
    }
    return ips;
}

+ (nullable NSString*)getIPWithInterface: (NSString*)interface version: (NSString*)version {
    NSString *key = [WXIPConfig keyWithName:interface version:version];
    return [WXIPConfig getAllIPs][key];
}

@end
