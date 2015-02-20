//
//  GBDeviceInfo_iOS.m
//  GBDeviceInfo
//
//  Created by Luka Mirosevic on 11/10/2012.
//  Copyright (c) 2013 Goonbee. All Rights Reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "GBDeviceInfo_iOS.h"

#import <stdlib.h>
#import <stdio.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>

static NSString * const kHardwareCPUFrequencyKey =          @"hw.cpufrequency";
static NSString * const kHardwareNumberOfCoresKey =         @"hw.ncpu";
static NSString * const kHardwareByteOrderKey =             @"hw.byteorder";
static NSString * const kHardwareL2CacheSizeKey =           @"hw.l2cachesize";

@interface GBDeviceInfo()

@property (strong, atomic, readwrite) NSString              *rawSystemInfoString;
@property (assign, atomic, readwrite) GBDeviceVersion       deviceVersion;
@property (strong, atomic, readwrite) NSString              *modelString;
@property (assign, atomic, readwrite) GBDeviceFamily        family;
@property (assign, atomic, readwrite) GBDeviceModel         model;
@property (assign, atomic, readwrite) GBDeviceDisplay       display;
@property (assign, atomic, readwrite) GBCPUInfo             cpuInfo;
@property (assign, atomic, readwrite) CGFloat               physicalMemory;
@property (assign, atomic, readwrite) GBOSVersion           osVersion;

@end

@implementation GBDeviceInfo

//lm sort this out a little too
- (NSString *)description {
    return @"";
//    return [NSString stringWithFormat:@"%@\nrawSystemInfoString: %@\nmodel: %d\nfamily: %d\ndisplay: %d\nmajorModelNumber: %ld\nminorModelNumber: %ld\nmajoriOSVersion: %ld\nminoriOSVersion: %ld", [super description], self.rawSystemInfoString, self.model, self.family, self.display, (unsigned long)self.majorModelNumber, (unsigned long)self.minorModelNumber, (unsigned long)self.majoriOSVersion, (unsigned long)self.minoriOSVersion];
}

#pragma mark - convenience

+ (NSString *)_rawSystemInfoString {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (GBDeviceVersion)_deviceVersion {
    NSString *systemInfoString = [self _rawSystemInfoString];
    
    NSUInteger positionOfFirstInteger = [systemInfoString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location;
    NSUInteger positionOfComma = [systemInfoString rangeOfString:@","].location;
    
    NSUInteger major = 0;
    NSUInteger minor = 0;
    
    if (positionOfComma != NSNotFound) {
        major = [[systemInfoString substringWithRange:NSMakeRange(positionOfFirstInteger, positionOfComma - positionOfFirstInteger)] integerValue];
        minor = [[systemInfoString substringFromIndex:positionOfComma + 1] integerValue];
    }
    
    return GBDeviceVersionMake(major, minor);
}

//lm swap
#pragma mark - Public API

+ (GBDeviceInfo *)deviceInfo {
    GBDeviceInfo *info = [GBDeviceInfo new];
    
    NSString *systemInfoString = [self _rawSystemInfoString];
    
    // system info string
    info.rawSystemInfoString = systemInfoString;
    
    // model numbers
    GBDeviceVersion deviceVersion = [self _deviceVersion];
    info.deviceVersion = deviceVersion;
    
    // default fallback values
    info.model = GBDeviceModelUnknown;
    info.modelString = info.rawSystemInfoString;

    NSDictionary *familyManifest = @{
                                     @"iPhone": @(GBDeviceFamilyiPhone),
                                     @"iPad": @(GBDeviceFamilyiPad),
                                     @"iPod": @(GBDeviceFamilyiPod),
                                     };
    
    NSDictionary *modelManifest = @{
                                    @"iPhone": @{
                                            // 1st Gen
                                            @[@(1), @(1)]: @[@(GBDeviceModeliPhone1), @"iPhone 1"],
                                            
                                            // 3G
                                            @[@(1), @(2)]: @[@(GBDeviceModeliPhone3G), @"iPhone 3G"],
                                            
                                            // 3GS
                                            @[@(2), @(1)]: @[@(GBDeviceModeliPhone3GS), @"iPhone 3GS"],
                                            
                                            // 4
                                            @[@(3), @(1)]: @[@(GBDeviceModeliPhone4), @"iPhone 4"],
                                            @[@(3), @(2)]: @[@(GBDeviceModeliPhone4), @"iPhone 4"],
                                            @[@(3), @(3)]: @[@(GBDeviceModeliPhone4), @"iPhone 4"],
                                            
                                            // 4S
                                            @[@(4), @(1)]: @[@(GBDeviceModeliPhone4S), @"iPhone 4S"],
                                            
                                            // 5
                                            @[@(5), @(1)]: @[@(GBDeviceModeliPhone5), @"iPhone 5"],
                                            @[@(5), @(2)]: @[@(GBDeviceModeliPhone5), @"iPhone 5"],
                                            
                                            // 5C
                                            @[@(5), @(3)]: @[@(GBDeviceModeliPhone5C), @"iPhone 5C"],
                                            @[@(5), @(4)]: @[@(GBDeviceModeliPhone5C), @"iPhone 5C"],
                                            
                                            // 5S
                                            @[@(6), @(1)]: @[@(GBDeviceModeliPhone5S), @"iPhone 5S"],
                                            @[@(6), @(2)]: @[@(GBDeviceModeliPhone5S), @"iPhone 5S"],
                                            
                                            // 6 Plus
                                            @[@(7), @(1)]: @[@(GBDeviceModeliPhone6Plus), @"iPhone 6 Plus"],
                                            
                                            // 6
                                            @[@(7), @(2)]: @[@(GBDeviceModeliPhone6), @"iPhone 6"],
                                            
                                        },
                                    @"iPad": @{
                                            
                                            // 1
                                            @[@(1), @(1)]: @[@(GBDeviceModeliPad1), @"iPad 1"],
                                            
                                            // 2
                                            @[@(2), @(1)]: @[@(GBDeviceModeliPad2), @"iPad 2"],
                                            @[@(2), @(2)]: @[@(GBDeviceModeliPad2), @"iPad 2"],
                                            @[@(2), @(3)]: @[@(GBDeviceModeliPad2), @"iPad 2"],
                                            @[@(2), @(4)]: @[@(GBDeviceModeliPad2), @"iPad 2"],
                                            
                                            // Mini
                                            @[@(2), @(5)]: @[@(GBDeviceModeliPadMini1), @"iPad Mini 1"],
                                            @[@(2), @(6)]: @[@(GBDeviceModeliPadMini1), @"iPad Mini 1"],
                                            @[@(2), @(7)]: @[@(GBDeviceModeliPadMini1), @"iPad Mini 1"],
                                            
                                            // 3
                                            @[@(3), @(1)]: @[@(GBDeviceModeliPad3), @"iPad 3"],
                                            @[@(3), @(2)]: @[@(GBDeviceModeliPad3), @"iPad 3"],
                                            @[@(3), @(3)]: @[@(GBDeviceModeliPad3), @"iPad 3"],
                                            
                                            // 4
                                            @[@(3), @(4)]: @[@(GBDeviceModeliPad4), @"iPad 4"],
                                            @[@(3), @(5)]: @[@(GBDeviceModeliPad4), @"iPad 4"],
                                            @[@(3), @(6)]: @[@(GBDeviceModeliPad4), @"iPad 4"],
                                            
                                            // Air
                                            @[@(4), @(1)]: @[@(GBDeviceModeliPadAir1), @"iPad Air 1"],
                                            @[@(4), @(2)]: @[@(GBDeviceModeliPadAir1), @"iPad Air 1"],
                                            @[@(4), @(3)]: @[@(GBDeviceModeliPadAir1), @"iPad Air 1"],
                                            
                                            // Mini 2
                                            @[@(4), @(4)]: @[@(GBDeviceModeliPadMini2), @"iPad Mini 2"],
                                            @[@(4), @(5)]: @[@(GBDeviceModeliPadMini2), @"iPad Mini 2"],
                                            @[@(4), @(6)]: @[@(GBDeviceModeliPadMini2), @"iPad Mini 2"],
                                            
                                            // Mini 3
                                            @[@(4), @(7)]: @[@(GBDeviceModeliPadMini3), @"iPad Mini 3"],
                                            @[@(4), @(8)]: @[@(GBDeviceModeliPadMini3), @"iPad Mini 3"],
                                            @[@(4), @(9)]: @[@(GBDeviceModeliPadMini3), @"iPad Mini 3"],
                                            
                                            // Air 2
                                            @[@(5), @(3)]: @[@(GBDeviceModeliPadAir2), @"iPad Air 2"],
                                            @[@(5), @(4)]: @[@(GBDeviceModeliPadAir2), @"iPad Air 2"],
                                            
                                            
                                            },
                                    @"iPod": @{
                                            
                                            // 1st Gen
                                            @[@(1), @(1)]: @[@(GBDeviceModeliPod1), @"iPod Touch 1"],
                                            
                                            // 2nd Gen
                                            @[@(2), @(1)]: @[@(GBDeviceModeliPod2), @"iPod Touch 2"],
                                            
                                            // 3rd Gen
                                            @[@(3), @(1)]: @[@(GBDeviceModeliPod3), @"iPod Touch 3"],
                                            
                                            // 4th Gen
                                            @[@(4), @(1)]: @[@(GBDeviceModeliPod4), @"iPod Touch 4"],
                                            
                                            // 5th Gen
                                            @[@(5), @(1)]: @[@(GBDeviceModeliPod5), @"iPod Touch 5"],
                                            },
                                    
                                    @"Simulator": @{
                                            }//lm what goes here? and what about unknown device?
                                    };
    
    // device model info
    BOOL found = NO;
    for (NSString *familyString in familyManifest) {
        if ([systemInfoString hasPrefix:familyString]) {
            info.family = [familyManifest[familyString] integerValue];
            info.model = [modelManifest[familyString][@[@(deviceVersion.major), @(deviceVersion.minor)]][0] integerValue];
            info.modelString = modelManifest[familyString][@[@(deviceVersion.major), @(deviceVersion.minor)]][0];
            
            found = YES;
            break;
        }
    }
    
    if (!found) {
        info.family = GBDeviceDisplayUnknown;
        info.model = GBDeviceModelUnknown;
        info.modelString = @"Unknown Device";
    }
    
    //lm what about simulator here?
    
    
    
    // Display
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // iPad
    if (((screenWidth == 768) && (screenHeight == 1024)) ||
        ((screenWidth == 1024) && (screenHeight == 768))) {
        info.display = GBDeviceDisplayiPad;
    }
    // iPhone 3.5 inch
    else if (((screenWidth == 320) && (screenHeight == 480)) ||
             ((screenWidth == 480) && (screenHeight == 320))) {
        info.display = GBDeviceDisplayiPhone35Inch;
    }
    // iPhone 4 inch
    else if (((screenWidth == 320) && (screenHeight == 568)) ||
             ((screenWidth == 568) && (screenHeight == 320))) {
        info.display = GBDeviceDisplayiPhone4Inch;
    }
    // iPhone 4.7 inch
    else if (((screenWidth == 375) && (screenHeight == 667)) ||
             ((screenWidth == 667) && (screenHeight == 375))) {
        info.display = GBDeviceDisplayiPhone47Inch;
    }
    // iPhone 5.5 inch
    else if (((screenWidth == 414) && (screenHeight == 736)) ||
             ((screenWidth == 736) && (screenHeight == 414))) {
        info.display = GBDeviceDisplayiPhone55Inch;
    }
    // unknown
    else {
        info.display = GBDeviceDisplayUnknown;
    }
    
    // iOS version
    NSArray *decomposedOSVersion = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if (decomposedOSVersion.count >= 3) {
        NSInteger majorVersion = [decomposedOSVersion[0] integerValue];
        NSInteger minorVersion = [decomposedOSVersion[1] integerValue];//lm is there a patch too?
        NSInteger patchVersion = [decomposedOSVersion[2] integerValue];//lm is there a patch too?
        
        info.osVersion = GBOSVersionMake(majorVersion, minorVersion, patchVersion);
    }
    
    // RAM
    info.physicalMemory = [[NSProcessInfo processInfo] physicalMemory] / 1073741824.;      //gibi
    
    
    // CPU info
    info.cpuInfo = [self _cpuInfo];
    
    return info;    
}

+ (GBCPUInfo)_cpuInfo {
    return GBCPUInfoMake(
        [self _sysctlCGFloatForKey:kHardwareCPUFrequencyKey] / 1000000000., //giga
        (NSUInteger)[self _sysctlCGFloatForKey:kHardwareNumberOfCoresKey],
        [self _sysctlCGFloatForKey:kHardwareL2CacheSizeKey] / 1024          //kibi
    );
}
+ (NSString *)_sysctlStringForKey:(NSString *)key {
    const char *keyCString = [key UTF8String];
    NSString *answer;
    
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
    CGFloat answerFloat;
    
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
