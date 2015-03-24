//
//  GBDeviceInfo_OSX.m
//  GBDeviceInfo
//
//  Created by Luka Mirosevic on 14/03/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
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

#import "GBDeviceInfo_OSX.h"

#import <sys/utsname.h>

#import "GBDeviceInfo_Common.h"
#import "GBDeviceInfo_Subclass.h"

static NSString * const kHardwareModelKey =                 @"hw.model";

@interface GBDeviceInfo ()

@property (assign, atomic, readwrite) GBDeviceVersion       deviceVersion;
@property (assign, atomic, readwrite) GBByteOrder           systemByteOrder;
@property (assign, atomic, readwrite) BOOL                  isMacAppStoreAvailable;
@property (assign, atomic, readwrite) BOOL                  isIAPAvailable;

@end

@implementation GBDeviceInfo

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\nrawSystemInfoString: %@\nnodeName: %@\nfamily: %ld\ndeviceModel.major: %ld\ndeviceModel.minor: %ld\ncpuInfo.frequency: %.3f\ncpuInfo.numberOfCores: %ld\ncpuInfo.l2CacheSize: %.3f\npysicalMemory: %.3f\nsystemByteOrder: %ld\nscreenResolution: %.0fx%.0f\nosVersion.major: %ld\nosVersion.minor: %ld\nosVersion.patch: %ld",
        [super description],
        self.rawSystemInfoString,
        self.nodeName,
        self.family,
        (unsigned long)self.deviceVersion.major,
        (unsigned long)self.deviceVersion.minor,
        self.cpuInfo.frequency,
        (unsigned long)self.cpuInfo.numberOfCores,
        self.cpuInfo.l2CacheSize,
        self.physicalMemory,
        self.systemByteOrder,
        self.displayInfo.resolution.width,
        self.displayInfo.resolution.height,
        (unsigned long)self.osVersion.major,
        (unsigned long)self.osVersion.minor,
        (unsigned long)self.osVersion.patch
    ];
}

#pragma mark - Public API

- (instancetype)init {
    if (self = [super init]) {
        self.rawSystemInfoString = [self.class _rawSystemInfoString];
        self.family = [self.class _deviceFamily];
        self.physicalMemory = [self.class _physicalMemory];
        self.systemByteOrder = [self.class _systemByteOrder];
        self.osVersion = [self.class _osVersion];
        self.deviceVersion = [self.class _deviceVersion];
        self.isMacAppStoreAvailable = [self.class _isMacAppStoreAvailable];
        self.isIAPAvailable = [self.class _isIAPAvailable];
    }
    
    return self;
}

#pragma mark - Dynamic Properties

- (NSString *)nodeName {
    return [self.class _nodeName];
}

- (GBCPUInfo)cpuInfo {
    return [self.class _cpuInfo];
}

- (GBDisplayInfo)displayInfo {
    return [self.class _displayInfo];
}

#pragma mark - Private API

+ (struct utsname)_unameStruct {
    struct utsname systemInfo;
    uname(&systemInfo);

    return systemInfo;
}

+ (GBOSVersion)_osVersion {
    GBOSVersion osVersion;
    
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
        NSOperatingSystemVersion osSystemVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
        
        osVersion.major = osSystemVersion.majorVersion;
        osVersion.minor = osSystemVersion.minorVersion;
        osVersion.patch = osSystemVersion.patchVersion;
    }
    else {
        SInt32 majorVersion, minorVersion, patchVersion;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        Gestalt(gestaltSystemVersionMajor, &majorVersion);
        Gestalt(gestaltSystemVersionMinor, &minorVersion);
        Gestalt(gestaltSystemVersionBugFix, &patchVersion);
#pragma clang diagnostic pop
        
        osVersion.major = majorVersion;
        osVersion.minor = minorVersion;
        osVersion.patch = patchVersion;
    }
    
    return osVersion;
}

+ (GBDisplayInfo)_displayInfo {
    return GBDisplayInfoMake(
        [NSScreen mainScreen].frame.size
    );
}

+ (GBDeviceFamily)_deviceFamily {
    NSString *systemInfoString = [self _rawSystemInfoString];
    
    if ([systemInfoString hasPrefix:@"iMac"]) {
        return GBDeviceFamilyiMac;
    }
    else if ([systemInfoString hasPrefix:@"Mac Mini"]) {
        return GBDeviceFamilyMacMini;
    }
    else if ([systemInfoString hasPrefix:@"Mac Pro"]) {
        return GBDeviceFamilyMacPro;
    }
    else if ([systemInfoString hasPrefix:@"MacBook Pro"]) {
        return GBDeviceFamilyMacBookPro;
    }
    else if ([systemInfoString hasPrefix:@"MacBook Air"]) {
        return GBDeviceFamilyMacBookAir;
    }
    else if ([systemInfoString hasPrefix:@"MacBook"]) {
        return GBDeviceFamilyMacBook;
    }
    else if ([systemInfoString hasPrefix:@"Xserve"]) {
        return GBDeviceFamilyXserve;
    }
    else {
        return GBDeviceFamilyUnknown;
    }
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

+ (NSString *)_rawSystemInfoString {
    return [GBDeviceInfo_Common _sysctlStringForKey:kHardwareModelKey];
}

+ (NSString *)_nodeName {
    return [NSString stringWithCString:[self _unameStruct].nodename encoding:NSUTF8StringEncoding];
}

+ (BOOL)_isMacAppStoreAvailable {
    GBOSVersion osVersion = [self _osVersion];
    
    return ((osVersion.minor >= 7) ||
            (osVersion.minor == 6 && osVersion.patch >=  6));
}

+ (BOOL)_isIAPAvailable {
    GBOSVersion osVersion = [self _osVersion];
    
    return (osVersion.minor >= 7);
}

@end
