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
@property (assign, atomic, readwrite) GBDeviceDisplay       display;
@property (assign, atomic, readwrite) GBDisplayInfo         displayInfo;

@end

@implementation GBDeviceInfo

#pragma mark - Custom Accessors

- (BOOL)isJailbroken {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"You have to include the Jailbreak subspec in order to access this property. Add `pod 'GBDeviceInfo/Jailbreak'` to your Podfile." userInfo:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\nrawSystemInfoString: %@\nmodel: %ld\nfamily: %ld\ndisplay: %ld\nppi: %ld\ndeviceVersion.major: %ld\ndeviceVersion.minor: %ld\nosVersion.major: %ld\nosVersion.minor: %ld\nosVersion.patch: %ld\ncpuInfo.frequency: %.3f\ncpuInfo.numberOfCores: %ld\ncpuInfo.l2CacheSize: %.3f\npysicalMemory: %.3f\nisJailbroken: %@",
            [super description],
            self.rawSystemInfoString,
            (long)self.model,
            (long)self.family,
            (long)self.display,
            (unsigned long)self.displayInfo.pixelsPerInch,
            (unsigned long)self.deviceVersion.major,
            (unsigned long)self.deviceVersion.minor,
            (unsigned long)self.osVersion.major,
            (unsigned long)self.osVersion.minor,
            (unsigned long)self.osVersion.patch,
            self.cpuInfo.frequency,
            (unsigned long)self.cpuInfo.numberOfCores,
            self.cpuInfo.l2CacheSize,
            self.physicalMemory,
            self.isJailbroken ? @"YES" : @"NO"
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
        self.displayInfo = GBDisplayInfoMake([modelNuances[3] doubleValue]);
        
        // Display
        self.display = [self.class _display];
        
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
    CGFloat pixelsPerInch = 0;
    
    // Simulator
    if (TARGET_IPHONE_SIMULATOR) {
        family = GBDeviceFamilySimulator;
        
        BOOL iPadScreen = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        model = iPadScreen ? GBDeviceModelSimulatoriPad : GBDeviceModelSimulatoriPhone;
        modelString = iPadScreen ? @"iPad Simulator": @"iPhone Simulator";
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
                @[@(1), @(1)]: @[@(GBDeviceModeliPhone1), @"iPhone 1", @(163)],

                // 3G
                @[@(1), @(2)]: @[@(GBDeviceModeliPhone3G), @"iPhone 3G", @(163)],

                // 3GS
                @[@(2), @(1)]: @[@(GBDeviceModeliPhone3GS), @"iPhone 3GS", @(163)],

                // 4
                @[@(3), @(1)]: @[@(GBDeviceModeliPhone4), @"iPhone 4", @(326)],
                @[@(3), @(2)]: @[@(GBDeviceModeliPhone4), @"iPhone 4", @(326)],
                @[@(3), @(3)]: @[@(GBDeviceModeliPhone4), @"iPhone 4", @(326)],

                // 4S
                @[@(4), @(1)]: @[@(GBDeviceModeliPhone4S), @"iPhone 4S", @(326)],

                // 5
                @[@(5), @(1)]: @[@(GBDeviceModeliPhone5), @"iPhone 5", @(326)],
                @[@(5), @(2)]: @[@(GBDeviceModeliPhone5), @"iPhone 5", @(326)],

                // 5C
                @[@(5), @(3)]: @[@(GBDeviceModeliPhone5C), @"iPhone 5C", @(326)],
                @[@(5), @(4)]: @[@(GBDeviceModeliPhone5C), @"iPhone 5C", @(326)],

                // 5S
                @[@(6), @(1)]: @[@(GBDeviceModeliPhone5S), @"iPhone 5S", @(326)],
                @[@(6), @(2)]: @[@(GBDeviceModeliPhone5S), @"iPhone 5S", @(326)],

                // 6 Plus
                @[@(7), @(1)]: @[@(GBDeviceModeliPhone6Plus), @"iPhone 6 Plus", @(401)],

                // 6
                @[@(7), @(2)]: @[@(GBDeviceModeliPhone6), @"iPhone 6", @(326)],
                
                // 6S
                @[@(8), @(1)]: @[@(GBDeviceModeliPhone6S), @"iPhone 6S", @(326)],
                
                // 6S Plus
                @[@(8), @(2)]: @[@(GBDeviceModeliPhone6SPlus), @"iPhone 6S Plus", @(401)],
            },
            @"iPad": @{
                // 1
                @[@(1), @(1)]: @[@(GBDeviceModeliPad1), @"iPad 1", @(132)],

                // 2
                @[@(2), @(1)]: @[@(GBDeviceModeliPad2), @"iPad 2", @(132)],
                @[@(2), @(2)]: @[@(GBDeviceModeliPad2), @"iPad 2", @(132)],
                @[@(2), @(3)]: @[@(GBDeviceModeliPad2), @"iPad 2", @(132)],
                @[@(2), @(4)]: @[@(GBDeviceModeliPad2), @"iPad 2", @(132)],

                // Mini
                @[@(2), @(5)]: @[@(GBDeviceModeliPadMini1), @"iPad Mini 1", @(163)],
                @[@(2), @(6)]: @[@(GBDeviceModeliPadMini1), @"iPad Mini 1", @(163)],
                @[@(2), @(7)]: @[@(GBDeviceModeliPadMini1), @"iPad Mini 1", @(163)],

                // 3
                @[@(3), @(1)]: @[@(GBDeviceModeliPad3), @"iPad 3", @(264)],
                @[@(3), @(2)]: @[@(GBDeviceModeliPad3), @"iPad 3", @(264)],
                @[@(3), @(3)]: @[@(GBDeviceModeliPad3), @"iPad 3", @(264)],

                // 4
                @[@(3), @(4)]: @[@(GBDeviceModeliPad4), @"iPad 4", @(264)],
                @[@(3), @(5)]: @[@(GBDeviceModeliPad4), @"iPad 4", @(264)],
                @[@(3), @(6)]: @[@(GBDeviceModeliPad4), @"iPad 4", @(264)],

                // Air
                @[@(4), @(1)]: @[@(GBDeviceModeliPadAir1), @"iPad Air 1", @(264)],
                @[@(4), @(2)]: @[@(GBDeviceModeliPadAir1), @"iPad Air 1", @(264)],
                @[@(4), @(3)]: @[@(GBDeviceModeliPadAir1), @"iPad Air 1", @(264)],

                // Mini 2
                @[@(4), @(4)]: @[@(GBDeviceModeliPadMini2), @"iPad Mini 2", @(326)],
                @[@(4), @(5)]: @[@(GBDeviceModeliPadMini2), @"iPad Mini 2", @(326)],
                @[@(4), @(6)]: @[@(GBDeviceModeliPadMini2), @"iPad Mini 2", @(326)],

                // Mini 3
                @[@(4), @(7)]: @[@(GBDeviceModeliPadMini3), @"iPad Mini 3", @(326)],
                @[@(4), @(8)]: @[@(GBDeviceModeliPadMini3), @"iPad Mini 3", @(326)],
                @[@(4), @(9)]: @[@(GBDeviceModeliPadMini3), @"iPad Mini 3", @(326)],

                // Air 2
                @[@(5), @(3)]: @[@(GBDeviceModeliPadAir2), @"iPad Air 2", @(264)],
                @[@(5), @(4)]: @[@(GBDeviceModeliPadAir2), @"iPad Air 2", @(264)],
            },
            @"iPod": @{
                // 1st Gen
                @[@(1), @(1)]: @[@(GBDeviceModeliPod1), @"iPod Touch 1", @(163)],

                // 2nd Gen
                @[@(2), @(1)]: @[@(GBDeviceModeliPod2), @"iPod Touch 2", @(163)],

                // 3rd Gen
                @[@(3), @(1)]: @[@(GBDeviceModeliPod3), @"iPod Touch 3", @(163)],

                // 4th Gen
                @[@(4), @(1)]: @[@(GBDeviceModeliPod4), @"iPod Touch 4", @(326)],

                // 5th Gen
                @[@(5), @(1)]: @[@(GBDeviceModeliPod5), @"iPod Touch 5", @(326)],
            },
        };
        
        for (NSString *familyString in familyManifest) {
            if ([systemInfoString hasPrefix:familyString]) {
                family = [familyManifest[familyString] integerValue];
                
                NSArray *modelNuances = modelManifest[familyString][@[@(deviceVersion.major), @(deviceVersion.minor)]];
                if (modelNuances) {
                    model = [modelNuances[0] integerValue];
                    modelString = modelNuances[1];
                    pixelsPerInch = [modelNuances[2] doubleValue];
                }
                
                break;
            }
        }
    }
    
    return @[@(family), @(model), modelString, @(pixelsPerInch)];
}

+ (GBDeviceDisplay)_display {
    // Display
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // iPad
    if (((screenWidth == 768) && (screenHeight == 1024)) ||
        ((screenWidth == 1024) && (screenHeight == 768))) {
        return GBDeviceDisplayiPad;
    }
    // iPhone 3.5 inch
    else if (((screenWidth == 320) && (screenHeight == 480)) ||
             ((screenWidth == 480) && (screenHeight == 320))) {
        return GBDeviceDisplayiPhone35Inch;
    }
    // iPhone 4 inch
    else if (((screenWidth == 320) && (screenHeight == 568)) ||
             ((screenWidth == 568) && (screenHeight == 320))) {
        return GBDeviceDisplayiPhone4Inch;
    }
    // iPhone 4.7 inch
    else if (((screenWidth == 375) && (screenHeight == 667)) ||
             ((screenWidth == 667) && (screenHeight == 375))) {
        return GBDeviceDisplayiPhone47Inch;
    }
    // iPhone 5.5 inch
    else if (((screenWidth == 414) && (screenHeight == 736)) ||
             ((screenWidth == 736) && (screenHeight == 414))) {
        return GBDeviceDisplayiPhone55Inch;
    }
    // unknown
    else {
        return GBDeviceDisplayUnknown;
    }
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
