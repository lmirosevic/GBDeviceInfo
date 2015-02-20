//
//  GBDeviceInfoCommonUtils.m
//  GBDeviceInfo
//
//  Created by Luka Mirosevic on 20/02/2015.
//  Copyright (c) 2015 Luka Mirosevic. All rights reserved.
//

#import "GBDeviceInfoCommonUtils.h"

#import <stdlib.h>
#import <stdio.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>

static NSString * const kHardwareCPUFrequencyKey =          @"hw.cpufrequency";
static NSString * const kHardwareNumberOfCoresKey =         @"hw.ncpu";
static NSString * const kHardwareByteOrderKey =             @"hw.byteorder";
static NSString * const kHardwareL2CacheSizeKey =           @"hw.l2cachesize";

@implementation GBDeviceInfoCommonUtils

+ (NSString *)sysctlStringForKey:(NSString *)key {
    const char *keyCString = [key UTF8String];
    NSString *answer = @"";
    
    size_t length;
    sysctlbyname(keyCString, NULL, &length, NULL, 0);
    if (length) {
        char *answerCString = malloc(length * sizeof(char));
        sysctlbyname(keyCString, answerCString, &length, NULL, 0);
        answer = [NSString stringWithCString:answerCString encoding:NSUTF8StringEncoding];
        free(answerCString);
    }
    
    return answer;
}

+ (CGFloat)sysctlCGFloatForKey:(NSString *)key {
    const char *keyCString = [key UTF8String];
    CGFloat answerFloat = 0;
    
    size_t length;
    sysctlbyname(keyCString, NULL, &length, NULL, 0);
    if (length) {
        char *answerRaw = malloc(length * sizeof(char));
        sysctlbyname(keyCString, answerRaw, &length, NULL, 0);
        switch (length) {
            case 8: {
                answerFloat = (CGFloat)*(int64_t *)answerRaw;
            } break;
                
            case 4: {
                answerFloat = (CGFloat)*(int32_t *)answerRaw;
            } break;
                
            default: {
                answerFloat = 0.;
            } break;
        }
        free(answerRaw);
    }
    
    return answerFloat;
}


+ (GBCPUInfo)cpuInfo {
    return GBCPUInfoMake(
                         [self sysctlCGFloatForKey:kHardwareCPUFrequencyKey] / 1000000000., //giga
                         (NSUInteger)[self sysctlCGFloatForKey:kHardwareNumberOfCoresKey],
                         [self sysctlCGFloatForKey:kHardwareL2CacheSizeKey] / 1024          //kibi
                         );
}

+ (CGFloat)physicalMemory {
    return [[NSProcessInfo processInfo] physicalMemory] / 1073741824.;      //gibi
}

+ (GBByteOrder)systemByteOrder {
    NSString *byteOrderString = [self sysctlStringForKey:kHardwareByteOrderKey];
    
    if ([byteOrderString isEqualToString:@"1234"]) {
        return GBByteOrderLittleEndian;
    }
    else {
        return GBByteOrderBigEndian;
    }
}

@end
