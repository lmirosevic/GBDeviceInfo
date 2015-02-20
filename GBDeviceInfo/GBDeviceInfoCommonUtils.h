//
//  GBDeviceInfoCommonUtils.h
//  GBDeviceInfo
//
//  Created by Luka Mirosevic on 20/02/2015.
//  Copyright (c) 2015 Luka Mirosevic. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBDeviceInfoTypes_Common.h"

@interface GBDeviceInfoCommonUtils : NSObject

+ (NSString *)sysctlStringForKey:(NSString *)key;
+ (CGFloat)sysctlCGFloatForKey:(NSString *)key;
+ (GBCPUInfo)cpuInfo;
+ (CGFloat)physicalMemory;
+ (GBByteOrder)systemByteOrder;

@end
