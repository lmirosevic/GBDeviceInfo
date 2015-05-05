//
//  GBDeviceInfoTypes_Common.m
//  GBDeviceInfo
//
//  Created by Luka Mirosevic on 20/02/2015.
//  Copyright (c) 2015 Luka Mirosevic. All rights reserved.
//

#import "GBDeviceInfo_Common.h"
#import "GBDeviceInfo_Subclass.h"

#if TARGET_OS_IPHONE
#import "GBDeviceInfo_iOS.h"
#else
#import "GBDeviceInfo_OSX.h"
#endif

#import <stdlib.h>
#import <stdio.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>

static NSString * const kHardwareCPUFrequencyKey =          @"hw.cpufrequency";
static NSString * const kHardwareNumberOfCoresKey =         @"hw.ncpu";
static NSString * const kHardwareByteOrderKey =             @"hw.byteorder";
static NSString * const kHardwareL2CacheSizeKey =           @"hw.l2cachesize";

@implementation GBDeviceInfo_Common

#pragma mark - Public

+ (instancetype)deviceInfo {
    static id _shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [self new];
    });

    return _shared;
}

- (BOOL)isOperatingSystemAtLeastOSVersion:(GBOSVersion)version {
    GBOSVersion currentVersion = [GBDeviceInfo deviceInfo].osVersion;
    
    // major bigger
    if (currentVersion.major > version.major) {
        return YES;
    }
    // major equal
    else if (currentVersion.major == version.major) {
        // minor bigger
        if (currentVersion.minor > version.minor) {
            return YES;
        }
        // minor equal
        else if (currentVersion.minor == version.minor) {
            // patch bigger
            if (currentVersion.patch > version.patch) {
                return YES;
            }
            // patch equal
            else if (currentVersion.patch == version.patch) {
                return YES;
            }
            // patch smaller
            else {
                return NO;
            }
        }
        // minor smaller
        else {
            return NO;
        }
    }
    // major smaller
    else {
        return NO;
    }
}

- (BOOL)isOperatingSystemAtLeastVersion:(NSString *)versionString {
    return [self isOperatingSystemAtLeastOSVersion:GBOSVersionFromString(versionString)];
}

#pragma mark - Private

+ (NSString *)_sysctlStringForKey:(NSString *)key {
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

+ (CGFloat)_sysctlCGFloatForKey:(NSString *)key {
    const char *keyCString = [key UTF8String];
    CGFloat answerFloat = 0;
    
    size_t length = 0;
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


+ (GBCPUInfo)_cpuInfo {
    return GBCPUInfoMake(
                         [self _sysctlCGFloatForKey:kHardwareCPUFrequencyKey] / 1000000000., //giga
                         (NSUInteger)[self _sysctlCGFloatForKey:kHardwareNumberOfCoresKey],
                         [self _sysctlCGFloatForKey:kHardwareL2CacheSizeKey] / 1024          //kibi
                         );
}

+ (CGFloat)_physicalMemory {
    return [[NSProcessInfo processInfo] physicalMemory] / 1073741824.;      //gibi
}

+ (GBByteOrder)_systemByteOrder {
    NSString *byteOrderString = [self _sysctlStringForKey:kHardwareByteOrderKey];
    
    if ([byteOrderString isEqualToString:@"1234"]) {
        return GBByteOrderLittleEndian;
    }
    else {
        return GBByteOrderBigEndian;
    }
}

@end
