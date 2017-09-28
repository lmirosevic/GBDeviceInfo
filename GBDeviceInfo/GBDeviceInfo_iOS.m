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

#import <sys/utsname.h>
#import "dlfcn.h"

#import "GBDeviceInfo_Common.h"
#import "GBDeviceInfo_Subclass.h"

@interface GBDeviceInfo ()

@property (assign, atomic, readwrite) GBDeviceVersion       deviceVersion;
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
    return [NSString stringWithFormat:@"%@\nrawSystemInfoString: %@\nmodel: %ld\nfamily: %ld\ndisplay: %ld\nppi: %ld\ndeviceVersion.major: %ld\ndeviceVersion.minor: %ld\nosVersion.major: %ld\nosVersion.minor: %ld\nosVersion.patch: %ld\ncpuInfo.frequency: %.3f\ncpuInfo.numberOfCores: %ld\ncpuInfo.l2CacheSize: %.3f\npysicalMemory: %.3f",
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
    
    // Simulator
    if (TARGET_IPHONE_SIMULATOR) {
        family = GBDeviceFamilySimulator;
        BOOL iPadScreen = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        model = iPadScreen ? GBDeviceModelSimulatoriPad : GBDeviceModelSimulatoriPhone;
        modelString = iPadScreen ? @"iPad Simulator": @"iPhone Simulator";
        display = GBDeviceDisplayUnknown;
        pixelsPerInch = 0;
    }
    // Actual device
    else {
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
            },
            @"iPad": @{
                // 1
                @[@1, @1]: @[@(GBDeviceModeliPad1), @"iPad 1", @(GBDeviceDisplay9p7Inch), @132],

                // 2
                @[@2, @1]: @[@(GBDeviceModeliPad2), @"iPad 2", @(GBDeviceDisplay9p7Inch), @132],
                @[@2, @2]: @[@(GBDeviceModeliPad2), @"iPad 2", @(GBDeviceDisplay9p7Inch), @132],
                @[@2, @3]: @[@(GBDeviceModeliPad2), @"iPad 2", @(GBDeviceDisplay9p7Inch), @132],
                @[@2, @4]: @[@(GBDeviceModeliPad2), @"iPad 2", @(GBDeviceDisplay9p7Inch), @132],

                // Mini
                @[@2, @5]: @[@(GBDeviceModeliPadMini1), @"iPad Mini 1", @(GBDeviceDisplay7p9Inch), @163],
                @[@2, @6]: @[@(GBDeviceModeliPadMini1), @"iPad Mini 1", @(GBDeviceDisplay7p9Inch), @163],
                @[@2, @7]: @[@(GBDeviceModeliPadMini1), @"iPad Mini 1", @(GBDeviceDisplay7p9Inch), @163],

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

                // Mini 2
                @[@4, @4]: @[@(GBDeviceModeliPadMini2), @"iPad Mini 2", @(GBDeviceDisplay7p9Inch), @326],
                @[@4, @5]: @[@(GBDeviceModeliPadMini2), @"iPad Mini 2", @(GBDeviceDisplay7p9Inch), @326],
                @[@4, @6]: @[@(GBDeviceModeliPadMini2), @"iPad Mini 2", @(GBDeviceDisplay7p9Inch), @326],

                // Mini 3
                @[@4, @7]: @[@(GBDeviceModeliPadMini3), @"iPad Mini 3", @(GBDeviceDisplay7p9Inch), @326],
                @[@4, @8]: @[@(GBDeviceModeliPadMini3), @"iPad Mini 3", @(GBDeviceDisplay7p9Inch), @326],
                @[@4, @9]: @[@(GBDeviceModeliPadMini3), @"iPad Mini 3", @(GBDeviceDisplay7p9Inch), @326],
                
                // Mini 4
                @[@5, @1]: @[@(GBDeviceModeliPadMini4), @"iPad Mini 4", @(GBDeviceDisplay7p9Inch), @326],
                @[@5, @2]: @[@(GBDeviceModeliPadMini4), @"iPad Mini 4", @(GBDeviceDisplay7p9Inch), @326],

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
                @[@6, @11]: @[@(GBDeviceModeliPad5), @"iPad 2017",
                              @(GBDeviceDisplay9p7Inch), @264],
                @[@6, @12]: @[@(GBDeviceModeliPad5), @"iPad 2017",
                              @(GBDeviceDisplay9p7Inch), @264],
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
    }
    
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
