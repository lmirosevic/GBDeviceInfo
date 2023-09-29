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

#include <TargetConditionals.h>

#if TARGET_OS_IPHONE

#import "GBDeviceInfo_iOS.h"

#import <UIKit/UIKit.h>

#import <sys/utsname.h>
#import "dlfcn.h"

#import "GBDeviceInfo_Common.h"
#import "GBDeviceInfo_Subclass.h"

@interface GBDeviceInfo ()

@property (strong, atomic, readwrite) NSString              *modelString;
@property (assign, atomic, readwrite) GBDeviceModel         model;
@property (assign, atomic, readwrite) GBDisplayInfo         displayInfo;

@end

@implementation GBDeviceInfo

#pragma mark - Custom Accessors

- (BOOL)isJailbroken {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"You have to include the Jailbreak subspec in order to access this property. Add `pod 'GBDeviceInfo/Jailbreak'` to your Podfile." userInfo:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\nrawSystemInfoString: %@\nmodel: %ld\nfamily: %ld\ndisplay: %ld\nppi: %ld\ndeviceVersion.major: %ld\ndeviceVersion.minor: %ld\nosVersion.major: %ld\nosVersion.minor: %ld\nosVersion.patch: %ld\ncpuInfo.frequency: %.3f\ncpuInfo.numberOfCores: %ld\ncpuInfo.l2CacheSize: %.3f\nphysicalMemory: %.3f",
            [super description],
            self.rawSystemInfoString,
            (long)self.model,
            (long)self.family,
            (long)self.displayInfo.display,
            (unsigned long)self.displayInfo.pixelsPerInch,
            (unsigned long)self.deviceVersion.major,
            (unsigned long)self.deviceVersion.minor,
            (unsigned long)self.osVersion.major,
            (unsigned long)self.osVersion.minor,
            (unsigned long)self.osVersion.patch,
            self.cpuInfo.frequency,
            (unsigned long)self.cpuInfo.numberOfCores,
            self.cpuInfo.l2CacheSize,
            self.physicalMemory
        ];
}

#pragma mark - Public API

- (instancetype)init {
    if (self = [super init]) {
        // system info string
        self.rawSystemInfoString = [self.class _rawSystemInfoString];
        
        // device version
        self.deviceVersion = [self.class _deviceVersion];
        
        // model nuances
        NSArray *modelNuances = [self.class _modelNuances];
        self.family = [modelNuances[0] integerValue];
        self.model = [modelNuances[1] integerValue];
        self.modelString = modelNuances[2];
        self.displayInfo = GBDisplayInfoMake([modelNuances[3] integerValue], [modelNuances[4] doubleValue]);
        
        // iOS version
        self.osVersion = [self.class _osVersion];
        
        // RAM
        self.physicalMemory = [self.class _physicalMemory];
        
        // CPU info
        self.cpuInfo = [self.class _cpuInfo];
    }
    
    return self;
}

#pragma mark - Dynamic Properties

// none yet

#pragma mark - Private API

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

+ (NSArray *)_modelNuances {
    GBDeviceFamily family = GBDeviceFamilyUnknown;
    GBDeviceModel model = GBDeviceModelUnknown;
    NSString *modelString = @"Unknown Device";
    GBDeviceDisplay display = GBDeviceDisplayUnknown;
    CGFloat pixelsPerInch = 0;
    
    #if TARGET_OS_SIMULATOR
        family = GBDeviceFamilySimulator;
        BOOL iPadScreen = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        model = iPadScreen ? GBDeviceModelSimulatoriPad : GBDeviceModelSimulatoriPhone;
        modelString = iPadScreen ? @"iPad Simulator": @"iPhone Simulator";
        display = GBDeviceDisplayUnknown;
        pixelsPerInch = 0;
    #else
        // Actual device
        GBDeviceVersion deviceVersion = [self _deviceVersion];
        NSString *systemInfoString = [self _rawSystemInfoString];
        
        
        NSDictionary *familyManifest = @{
            @"iPhone": @(GBDeviceFamilyiPhone),
            @"iPad": @(GBDeviceFamilyiPad),
            @"iPod": @(GBDeviceFamilyiPod),
        };
        
        NSDictionary *modelManifest = @{
            @"iPhone": @{
                // 1st Gen
                @[@1, @1]: @[@(GBDeviceModeliPhone1), @"iPhone 1", @(GBDeviceDisplay3p5Inch), @163],

                // 3G
                @[@1, @2]: @[@(GBDeviceModeliPhone3G), @"iPhone 3G", @(GBDeviceDisplay3p5Inch), @163],

                // 3GS
                @[@2, @1]: @[@(GBDeviceModeliPhone3GS), @"iPhone 3GS", @(GBDeviceDisplay3p5Inch), @163],

                // 4
                @[@3, @1]: @[@(GBDeviceModeliPhone4), @"iPhone 4", @(GBDeviceDisplay3p5Inch), @326],
                @[@3, @2]: @[@(GBDeviceModeliPhone4), @"iPhone 4", @(GBDeviceDisplay3p5Inch), @326],
                @[@3, @3]: @[@(GBDeviceModeliPhone4), @"iPhone 4", @(GBDeviceDisplay3p5Inch), @326],

                // 4S
                @[@4, @1]: @[@(GBDeviceModeliPhone4S), @"iPhone 4S", @(GBDeviceDisplay3p5Inch), @326],

                // 5
                @[@5, @1]: @[@(GBDeviceModeliPhone5), @"iPhone 5", @(GBDeviceDisplay4Inch), @326],
                @[@5, @2]: @[@(GBDeviceModeliPhone5), @"iPhone 5", @(GBDeviceDisplay4Inch), @326],

                // 5c
                @[@5, @3]: @[@(GBDeviceModeliPhone5c), @"iPhone 5c", @(GBDeviceDisplay4Inch), @326],
                @[@5, @4]: @[@(GBDeviceModeliPhone5c), @"iPhone 5c", @(GBDeviceDisplay4Inch), @326],

                // 5s
                @[@6, @1]: @[@(GBDeviceModeliPhone5s), @"iPhone 5s", @(GBDeviceDisplay4Inch), @326],
                @[@6, @2]: @[@(GBDeviceModeliPhone5s), @"iPhone 5s", @(GBDeviceDisplay4Inch), @326],

                // 6 Plus
                @[@7, @1]: @[@(GBDeviceModeliPhone6Plus), @"iPhone 6 Plus", @(GBDeviceDisplay5p5Inch), @401],

                // 6
                @[@7, @2]: @[@(GBDeviceModeliPhone6), @"iPhone 6", @(GBDeviceDisplay4p7Inch), @326],
                
                // 6s
                @[@8, @1]: @[@(GBDeviceModeliPhone6s), @"iPhone 6s", @(GBDeviceDisplay4p7Inch), @326],
                
                // 6s Plus
                @[@8, @2]: @[@(GBDeviceModeliPhone6sPlus), @"iPhone 6s Plus", @(GBDeviceDisplay5p5Inch), @401],
                
                // SE
                @[@8, @4]: @[@(GBDeviceModeliPhoneSE), @"iPhone SE", @(GBDeviceDisplay4Inch), @326],
                
                // 7
                @[@9, @1]: @[@(GBDeviceModeliPhone7), @"iPhone 7", @(GBDeviceDisplay4p7Inch), @326],
                @[@9, @3]: @[@(GBDeviceModeliPhone7), @"iPhone 7", @(GBDeviceDisplay4p7Inch), @326],
                
                // 7 Plus
                @[@9, @2]: @[@(GBDeviceModeliPhone7Plus), @"iPhone 7 Plus", @(GBDeviceDisplay5p5Inch), @401],
                @[@9, @4]: @[@(GBDeviceModeliPhone7Plus), @"iPhone 7 Plus", @(GBDeviceDisplay5p5Inch), @401],
                
                // 8
                @[@10, @1]: @[@(GBDeviceModeliPhone8), @"iPhone 8", @(GBDeviceDisplay4p7Inch), @326],
                @[@10, @4]: @[@(GBDeviceModeliPhone8), @"iPhone 8", @(GBDeviceDisplay4p7Inch), @326],

                // 8 Plus
                @[@10, @2]: @[@(GBDeviceModeliPhone8Plus), @"iPhone 8 Plus", @(GBDeviceDisplay5p5Inch), @401],
                @[@10, @5]: @[@(GBDeviceModeliPhone8Plus), @"iPhone 8 Plus", @(GBDeviceDisplay5p5Inch), @401],
                
                // X
                @[@10, @3]: @[@(GBDeviceModeliPhoneX), @"iPhone X", @(GBDeviceDisplay5p8Inch), @458],
                @[@10, @6]: @[@(GBDeviceModeliPhoneX), @"iPhone X", @(GBDeviceDisplay5p8Inch), @458],

                // XR
                @[@11, @8]: @[@(GBDeviceModeliPhoneXR), @"iPhone XR", @(GBDeviceDisplay6p1Inch), @326],

                // XS
                @[@11, @2]: @[@(GBDeviceModeliPhoneXS), @"iPhone XS", @(GBDeviceDisplay5p8Inch), @458],

                // XS Max
                @[@11, @4]: @[@(GBDeviceModeliPhoneXSMax), @"iPhone XS Max", @(GBDeviceDisplay6p5Inch), @458],
                @[@11, @6]: @[@(GBDeviceModeliPhoneXSMax), @"iPhone XS Max", @(GBDeviceDisplay6p5Inch), @458],
                
                // 11
                @[@12, @1]: @[@(GBDeviceModeliPhone11), @"iPhone 11", @(GBDeviceDisplay6p1Inch), @326],

                // 11 Pro
                @[@12, @3]: @[@(GBDeviceModeliPhone11Pro), @"iPhone 11 Pro", @(GBDeviceDisplay5p8Inch), @458],

                // 11 Pro Max
                @[@12, @5]: @[@(GBDeviceModeliPhone11ProMax), @"iPhone 11 Pro Max", @(GBDeviceDisplay6p5Inch), @458],

                // SE 2
                @[@12, @8]: @[@(GBDeviceModeliPhoneSE2), @"iPhone SE 2", @(GBDeviceDisplay4p7Inch), @326],

                // 12 mini
                @[@13, @1]: @[@(GBDeviceModeliPhone12Mini), @"iPhone 12 mini", @(GBDeviceDisplay5p4Inch), @476],

                // 12
                @[@13, @2]: @[@(GBDeviceModeliPhone12), @"iPhone 12", @(GBDeviceDisplay6p1Inch), @460],

                // 12 Pro
                @[@13, @3]: @[@(GBDeviceModeliPhone12Pro), @"iPhone 12 Pro", @(GBDeviceDisplay6p1Inch), @460],

                // 12 Pro Max
                @[@13, @4]: @[@(GBDeviceModeliPhone12ProMax), @"iPhone 12 Pro Max", @(GBDeviceDisplay6p7Inch), @458],
                
                // 13 mini
                @[@14, @4]: @[@(GBDeviceModeliPhone13Mini), @"iPhone 13 mini", @(GBDeviceDisplay5p4Inch), @476],

                // 13
                @[@14, @5]: @[@(GBDeviceModeliPhone13), @"iPhone 13", @(GBDeviceDisplay6p1Inch), @460],

                // 13 Pro
                @[@14, @2]: @[@(GBDeviceModeliPhone13Pro), @"iPhone 13 Pro", @(GBDeviceDisplay6p1Inch), @460],

                // 13 Pro Max
                @[@14, @3]: @[@(GBDeviceModeliPhone13ProMax), @"iPhone 13 Pro Max", @(GBDeviceDisplay6p7Inch), @458],

                // SE 3rd Gen
                @[@14, @6]: @[@(GBDeviceModeliPhoneSE3), @"iPhone SE 3rd Gen", @(GBDeviceDisplay4p7Inch), @326],

                // 14
                @[@14, @7]: @[@(GBDeviceModeliPhone14), @"iPhone 14", @(GBDeviceDisplay6p1Inch), @460],

                // 14 Plus
                @[@14, @8]: @[@(GBDeviceModeliPhone14Plus), @"iPhone 14 Plus", @(GBDeviceDisplay6p7Inch), @458],

                // 14 Pro
                @[@15, @2]: @[@(GBDeviceModeliPhone14Pro), @"iPhone 14 Pro", @(GBDeviceDisplay6p1Inch), @460],

                // 14 Pro Max
                @[@15, @3]: @[@(GBDeviceModeliPhone14ProMax), @"iPhone 14 Pro Max", @(GBDeviceDisplay6p7Inch), @460],
            },
            @"iPad": @{
                // 1
                @[@1, @1]: @[@(GBDeviceModeliPad1), @"iPad 1", @(GBDeviceDisplay9p7Inch), @132],

                // 2
                @[@2, @1]: @[@(GBDeviceModeliPad2), @"iPad 2", @(GBDeviceDisplay9p7Inch), @132],
                @[@2, @2]: @[@(GBDeviceModeliPad2), @"iPad 2", @(GBDeviceDisplay9p7Inch), @132],
                @[@2, @3]: @[@(GBDeviceModeliPad2), @"iPad 2", @(GBDeviceDisplay9p7Inch), @132],
                @[@2, @4]: @[@(GBDeviceModeliPad2), @"iPad 2", @(GBDeviceDisplay9p7Inch), @132],

                // mini
                @[@2, @5]: @[@(GBDeviceModeliPadMini1), @"iPad mini 1", @(GBDeviceDisplay7p9Inch), @163],
                @[@2, @6]: @[@(GBDeviceModeliPadMini1), @"iPad mini 1", @(GBDeviceDisplay7p9Inch), @163],
                @[@2, @7]: @[@(GBDeviceModeliPadMini1), @"iPad mini 1", @(GBDeviceDisplay7p9Inch), @163],

                // 3
                @[@3, @1]: @[@(GBDeviceModeliPad3), @"iPad 3", @(GBDeviceDisplay9p7Inch), @264],
                @[@3, @2]: @[@(GBDeviceModeliPad3), @"iPad 3", @(GBDeviceDisplay9p7Inch), @264],
                @[@3, @3]: @[@(GBDeviceModeliPad3), @"iPad 3", @(GBDeviceDisplay9p7Inch), @264],

                // 4
                @[@3, @4]: @[@(GBDeviceModeliPad4), @"iPad 4", @(GBDeviceDisplay9p7Inch), @264],
                @[@3, @5]: @[@(GBDeviceModeliPad4), @"iPad 4", @(GBDeviceDisplay9p7Inch), @264],
                @[@3, @6]: @[@(GBDeviceModeliPad4), @"iPad 4", @(GBDeviceDisplay9p7Inch), @264],

                // Air
                @[@4, @1]: @[@(GBDeviceModeliPadAir1), @"iPad Air 1", @(GBDeviceDisplay9p7Inch), @264],
                @[@4, @2]: @[@(GBDeviceModeliPadAir1), @"iPad Air 1", @(GBDeviceDisplay9p7Inch), @264],
                @[@4, @3]: @[@(GBDeviceModeliPadAir1), @"iPad Air 1", @(GBDeviceDisplay9p7Inch), @264],

                // mini 2
                @[@4, @4]: @[@(GBDeviceModeliPadMini2), @"iPad mini 2", @(GBDeviceDisplay7p9Inch), @326],
                @[@4, @5]: @[@(GBDeviceModeliPadMini2), @"iPad mini 2", @(GBDeviceDisplay7p9Inch), @326],
                @[@4, @6]: @[@(GBDeviceModeliPadMini2), @"iPad mini 2", @(GBDeviceDisplay7p9Inch), @326],

                // mini 3
                @[@4, @7]: @[@(GBDeviceModeliPadMini3), @"iPad mini 3", @(GBDeviceDisplay7p9Inch), @326],
                @[@4, @8]: @[@(GBDeviceModeliPadMini3), @"iPad mini 3", @(GBDeviceDisplay7p9Inch), @326],
                @[@4, @9]: @[@(GBDeviceModeliPadMini3), @"iPad mini 3", @(GBDeviceDisplay7p9Inch), @326],
                
                // mini 4
                @[@5, @1]: @[@(GBDeviceModeliPadMini4), @"iPad mini 4", @(GBDeviceDisplay7p9Inch), @326],
                @[@5, @2]: @[@(GBDeviceModeliPadMini4), @"iPad mini 4", @(GBDeviceDisplay7p9Inch), @326],

                // Air 2
                @[@5, @3]: @[@(GBDeviceModeliPadAir2), @"iPad Air 2", @(GBDeviceDisplay9p7Inch), @264],
                @[@5, @4]: @[@(GBDeviceModeliPadAir2), @"iPad Air 2", @(GBDeviceDisplay9p7Inch), @264],
                
                // Pro 12.9-inch
                @[@6, @7]: @[@(GBDeviceModeliPadPro12p9Inch), @"iPad Pro 12.9-inch", @(GBDeviceDisplay12p9Inch), @264],
                @[@6, @8]: @[@(GBDeviceModeliPadPro12p9Inch), @"iPad Pro 12.9-inch", @(GBDeviceDisplay12p9Inch), @264],
                
                // Pro 9.7-inch
                @[@6, @3]: @[@(GBDeviceModeliPadPro9p7Inch), @"iPad Pro 9.7-inch", @(GBDeviceDisplay9p7Inch), @264],
                @[@6, @4]: @[@(GBDeviceModeliPadPro9p7Inch), @"iPad Pro 9.7-inch", @(GBDeviceDisplay9p7Inch), @264],
                
                // iPad 5th Gen, 2017
                @[@6, @11]: @[@(GBDeviceModeliPad5), @"iPad 2017", @(GBDeviceDisplay9p7Inch), @264],
                @[@6, @12]: @[@(GBDeviceModeliPad5), @"iPad 2017", @(GBDeviceDisplay9p7Inch), @264],

                // Pro 12.9-inch, 2017
                @[@7, @1]: @[@(GBDeviceModeliPadPro12p9Inch2), @"iPad Pro 12.9-inch 2017", @(GBDeviceDisplay12p9Inch), @264],
                @[@7, @2]: @[@(GBDeviceModeliPadPro12p9Inch2), @"iPad Pro 12.9-inch 2017", @(GBDeviceDisplay12p9Inch), @264],
                
                // Pro 10.5-inch, 2017
                @[@7, @3]: @[@(GBDeviceModeliPadPro10p5Inch), @"iPad Pro 10.5-inch 2017", @(GBDeviceDisplay10p5Inch), @264],
                @[@7, @4]: @[@(GBDeviceModeliPadPro10p5Inch), @"iPad Pro 10.5-inch 2017", @(GBDeviceDisplay10p5Inch), @264],
                
                // iPad 6th Gen, 2018
                @[@7, @5]: @[@(GBDeviceModeliPad6), @"iPad 2018", @(GBDeviceDisplay9p7Inch), @264],
                @[@7, @6]: @[@(GBDeviceModeliPad6), @"iPad 2018", @(GBDeviceDisplay9p7Inch), @264],
                
                // iPad 7th Gen, 2019
                @[@7, @11]: @[@(GBDeviceModeliPad7), @"iPad 2019", @(GBDeviceDisplay10p2Inch), @264],
                @[@7, @12]: @[@(GBDeviceModeliPad7), @"iPad 2019", @(GBDeviceDisplay10p2Inch), @264],

                // iPad Pro 11-inch, 2018
                @[@8, @1]: @[@(GBDeviceModeliPadPro11Inch), @"iPad Pro (11 inch, WiFi)", @(GBDeviceDisplay11Inch), @264],
                @[@8, @3]: @[@(GBDeviceModeliPadPro11Inch), @"iPad Pro (11 inch, WiFi+Cellular)", @(GBDeviceDisplay11Inch), @264],

                // iPad Pro 11-inch 1TB, 2018
                @[@8, @2]: @[@(GBDeviceModeliPadPro11Inch), @"iPad Pro (11 inch, 1TB, WiFi)", @(GBDeviceDisplay11Inch), @264],
                @[@8, @4]: @[@(GBDeviceModeliPadPro11Inch), @"iPad Pro (11 inch, 1TB, WiFi+Cellular)", @(GBDeviceDisplay11Inch), @264],

                // iPad Pro 3rd Gen 12.9-inch, 2018
                @[@8, @5]: @[@(GBDeviceModeliPadPro12p9Inch3), @"iPad Pro 3rd Gen (12.9 inch, WiFi)", @(GBDeviceDisplay12p9Inch), @264],
                @[@8, @7]: @[@(GBDeviceModeliPadPro12p9Inch3), @"iPad Pro 3rd Gen (12.9 inch, WiFi+Cellular)", @(GBDeviceDisplay12p9Inch), @264],

                // iPad Pro 3rd Gen 12.9-inch 1TB, 2018
                @[@8, @6]: @[@(GBDeviceModeliPadPro12p9Inch3), @"iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi)", @(GBDeviceDisplay12p9Inch), @264],
                @[@8, @8]: @[@(GBDeviceModeliPadPro12p9Inch3), @"iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi+Cellular)", @(GBDeviceDisplay12p9Inch), @264],
                
                // iPad Pro 2nd Gen 11-inch, 2020
                @[@8, @9]: @[@(GBDeviceModeliPadPro11Inch2), @"iPad Pro 2nd Gen (11 inch, WiFi)", @(GBDeviceDisplay11Inch), @264],
                @[@8, @10]: @[@(GBDeviceModeliPadPro11Inch2), @"iPad Pro 2nd Gen (11 inch, WiFi+Cellular)", @(GBDeviceDisplay11Inch), @264],

                // iPad Pro 4th Gen 12.9-inch, 2020
                @[@8, @11]: @[@(GBDeviceModeliPadPro12p9Inch4), @"iPad Pro 4th Gen (12.9 inch, WiFi)", @(GBDeviceDisplay12p9Inch), @264],
                @[@8, @12]: @[@(GBDeviceModeliPadPro12p9Inch4), @"iPad Pro 4th Gen (12.9 inch, WiFi+Cellular)", @(GBDeviceDisplay12p9Inch), @264],

                // mini 5
                @[@11, @1]: @[@(GBDeviceModeliPadMini5), @"iPad mini 5", @(GBDeviceDisplay7p9Inch), @326],
                @[@11, @2]: @[@(GBDeviceModeliPadMini5), @"iPad mini 5", @(GBDeviceDisplay7p9Inch), @326],
                
                // Air 3
                @[@11, @3]: @[@(GBDeviceModeliPadAir3), @"iPad Air 3", @(GBDeviceDisplay10p5Inch), @264],
                @[@11, @4]: @[@(GBDeviceModeliPadAir3), @"iPad Air 3", @(GBDeviceDisplay10p5Inch), @264],

                // iPad 8th Gen, 2020
                @[@11, @6]: @[@(GBDeviceModeliPad8), @"iPad 2020", @(GBDeviceDisplay10p2Inch), @264],
                @[@11, @7]: @[@(GBDeviceModeliPad8), @"iPad 2020", @(GBDeviceDisplay10p2Inch), @264],

                // Air 4
                @[@13, @1]: @[@(GBDeviceModeliPadAir4), @"iPad Air 4", @(GBDeviceDisplay10p9Inch), @264],
                @[@13, @2]: @[@(GBDeviceModeliPadAir4), @"iPad Air 4", @(GBDeviceDisplay10p9Inch), @264],

                // iPad Pro 3rd Gen 11-inch, 2021
                @[@13, @4]: @[@(GBDeviceModeliPadPro11Inch3), @"iPad Pro 3rd Gen (11 inch, WiFi)", @(GBDeviceDisplay11Inch), @264],
                @[@13, @5]: @[@(GBDeviceModeliPadPro11Inch3), @"iPad Pro 3rd Gen (11 inch, WiFi+Cellular)", @(GBDeviceDisplay11Inch), @264],
                @[@13, @6]: @[@(GBDeviceModeliPadPro11Inch3), @"iPad Pro 3rd Gen (11 inch, WiFi+Cellular)", @(GBDeviceDisplay11Inch), @264],
                @[@13, @7]: @[@(GBDeviceModeliPadPro11Inch3), @"iPad Pro 3rd Gen (11 inch, WiFi+Cellular)", @(GBDeviceDisplay11Inch), @264],

                // iPad Pro 5th Gen 12.9-inch, 2021
                @[@13, @8]: @[@(GBDeviceModeliPadPro12p9Inch5), @"iPad Pro 5th Gen (12.9 inch, WiFi)", @(GBDeviceDisplay12p9Inch), @264],
                @[@13, @9]: @[@(GBDeviceModeliPadPro12p9Inch5), @"iPad Pro 5th Gen (12.9 inch, WiFi+Cellular)", @(GBDeviceDisplay12p9Inch), @264],
                @[@13, @10]: @[@(GBDeviceModeliPadPro12p9Inch5), @"iPad Pro 5th Gen (12.9 inch, WiFi+Cellular)", @(GBDeviceDisplay12p9Inch), @264],
                @[@13, @11]: @[@(GBDeviceModeliPadPro12p9Inch5), @"iPad Pro 5th Gen (12.9 inch, WiFi+Cellular)", @(GBDeviceDisplay12p9Inch), @264],

                // Air 5, 2022
                @[@13, @16]: @[@(GBDeviceModeliPadAir5), @"iPad Air 5th Gen (WiFi)", @(GBDeviceDisplay10p9Inch), @264],
                @[@13, @17]: @[@(GBDeviceModeliPadAir5), @"iPad Air 5th Gen (WiFi+Cellular)", @(GBDeviceDisplay10p9Inch), @264],
                
                // iPad Pro 3rd Gen 11-inch, 2021
                @[@13, @4]: @[@(GBDeviceModeliPadPro11Inch3), @"iPad Pro 3rd Gen (11 inch, WiFi)", @(GBDeviceDisplay11Inch), @264],
                @[@13, @5]: @[@(GBDeviceModeliPadPro11Inch3), @"iPad Pro 3rd Gen (11 inch, WiFi+Cellular)", @(GBDeviceDisplay11Inch), @264],
                @[@13, @6]: @[@(GBDeviceModeliPadPro11Inch3), @"iPad Pro 3rd Gen (11 inch, WiFi+Cellular)", @(GBDeviceDisplay11Inch), @264],
                @[@13, @7]: @[@(GBDeviceModeliPadPro11Inch3), @"iPad Pro 3rd Gen (11 inch, WiFi+Cellular)", @(GBDeviceDisplay11Inch), @264],
                
                // iPad Pro 5th Gen 12.9-inch, 2021
                @[@13, @8]: @[@(GBDeviceModeliPadPro12p9Inch5), @"iPad Pro 5th Gen (12.9 inch, WiFi)", @(GBDeviceDisplay12p9Inch), @264],
                @[@13, @9]: @[@(GBDeviceModeliPadPro12p9Inch5), @"iPad Pro 5th Gen (12.9 inch, WiFi+Cellular)", @(GBDeviceDisplay12p9Inch), @264],
                @[@13, @10]: @[@(GBDeviceModeliPadPro12p9Inch5), @"iPad Pro 5th Gen (12.9 inch, WiFi+Cellular)", @(GBDeviceDisplay12p9Inch), @264],
                @[@13, @11]: @[@(GBDeviceModeliPadPro12p9Inch5), @"iPad Pro 5th Gen (12.9 inch, WiFi+Cellular)", @(GBDeviceDisplay12p9Inch), @264],
                                
                // Air 5, 2022
                @[@13, @16]: @[@(GBDeviceModeliPadAir5), @"iPad Air 5th Gen (WiFi)", @(GBDeviceDisplay10p9Inch), @264],
                @[@13, @17]: @[@(GBDeviceModeliPadAir5), @"iPad Air 5th Gen (WiFi+Cellular)", @(GBDeviceDisplay10p9Inch), @264],
                
                // mini 6
                @[@14, @1]: @[@(GBDeviceModeliPadMini6), @"iPad mini 6", @(GBDeviceDisplay8p3Inch), @326],
                @[@14, @2]: @[@(GBDeviceModeliPadMini6), @"iPad mini 6", @(GBDeviceDisplay8p3Inch), @326],
                
                // iPad 9th Gen, 2021
                @[@12, @1]: @[@(GBDeviceModeliPad9), @"iPad 2021", @(GBDeviceDisplay10p2Inch), @264],
                @[@12, @2]: @[@(GBDeviceModeliPad9), @"iPad 2021", @(GBDeviceDisplay10p2Inch), @264],

                // iPad 10th Gen, 2022
                @[@13, @18]: @[@(GBDeviceModeliPad10), @"iPad 2022", @(GBDeviceDisplay10p9Inch), @264],
                @[@13, @19]: @[@(GBDeviceModeliPad10), @"iPad 2022", @(GBDeviceDisplay10p9Inch), @264],

                // iPad Pro 4th Gen 11-inch, 2022
                @[@14, @3]: @[@(GBDeviceModeliPadPro11Inch4), @"iPad Pro 4th Gen (11 inch, WiFi)", @(GBDeviceDisplay11Inch), @264],
                @[@14, @4]: @[@(GBDeviceModeliPadPro11Inch4), @"iPad Pro 4th Gen (11 inch, WiFi+Cellular)", @(GBDeviceDisplay11Inch), @264],
                
                // iPad Pro 6th Gen 12.9-inch, 2022
                @[@14, @5]: @[@(GBDeviceModeliPadPro12p9Inch6), @"iPad Pro 6th Gen (12.9 inch, WiFi)", @(GBDeviceDisplay12p9Inch), @264],
                @[@14, @6]: @[@(GBDeviceModeliPadPro12p9Inch6), @"iPad Pro 6th Gen (12.9 inch, WiFi+Cellular)", @(GBDeviceDisplay12p9Inch), @264],
            },
            @"iPod": @{
                // 1st Gen
                @[@1, @1]: @[@(GBDeviceModeliPod1), @"iPod Touch 1", @(GBDeviceDisplay3p5Inch), @163],

                // 2nd Gen
                @[@2, @1]: @[@(GBDeviceModeliPod2), @"iPod Touch 2", @(GBDeviceDisplay3p5Inch), @163],

                // 3rd Gen
                @[@3, @1]: @[@(GBDeviceModeliPod3), @"iPod Touch 3", @(GBDeviceDisplay3p5Inch), @163],

                // 4th Gen
                @[@4, @1]: @[@(GBDeviceModeliPod4), @"iPod Touch 4", @(GBDeviceDisplay3p5Inch), @326],

                // 5th Gen
                @[@5, @1]: @[@(GBDeviceModeliPod5), @"iPod Touch 5", @(GBDeviceDisplay4Inch), @326],

                // 6th Gen
                @[@7, @1]: @[@(GBDeviceModeliPod6), @"iPod Touch 6", @(GBDeviceDisplay4Inch), @326],
                
                // 7th Gen
                @[@9, @1]: @[@(GBDeviceModeliPod7), @"iPod Touch 7", @(GBDeviceDisplay4Inch), @326],
            },
        };
        
        for (NSString *familyString in familyManifest) {
            if ([systemInfoString hasPrefix:familyString]) {
                family = [familyManifest[familyString] integerValue];
                
                NSArray *modelNuances = modelManifest[familyString][@[@(deviceVersion.major), @(deviceVersion.minor)]];
                if (modelNuances) {
                    model = [modelNuances[0] integerValue];
                    modelString = modelNuances[1];
                    display = [modelNuances[2] integerValue];
                    pixelsPerInch = [modelNuances[3] doubleValue];
                }
                break;
            }
        }
    #endif
    
    return @[@(family), @(model), modelString, @(display), @(pixelsPerInch)];
}

+ (GBOSVersion)_osVersion {
    NSInteger majorVersion = 0;
    NSInteger minorVersion = 0;
    NSInteger patchVersion = 0;
    
    NSArray *decomposedOSVersion = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if (decomposedOSVersion.count > 0) majorVersion = [decomposedOSVersion[0] integerValue];
    if (decomposedOSVersion.count > 1) minorVersion = [decomposedOSVersion[1] integerValue];
    if (decomposedOSVersion.count > 2) patchVersion = [decomposedOSVersion[2] integerValue];
    
    return GBOSVersionMake(majorVersion, minorVersion, patchVersion);
}

@end

#endif
