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

#import <stdlib.h>
#import <stdio.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>

static NSString * const kHardwareModelKey =                 @"hw.model";
static NSString * const kHardwareMemorySizeKey =            @"hw.memsize";
static NSString * const kHardwareCPUFrequencyKey =          @"hw.cpufrequency";
static NSString * const kHardwareNumberOfCoresKey =         @"hw.ncpu";
static NSString * const kHardwareByteOrderKey =             @"hw.byteorder";
static NSString * const kHardwareL2CacheSizeKey =           @"hw.l2cachesize";

@interface GBDeviceDetails ()

@property (strong, atomic, readwrite) NSString              *rawSystemInfoString;
@property (strong, atomic, readwrite) NSString              *nodeName;
@property (assign, atomic, readwrite) GBDeviceFamily        family;
@property (assign, atomic, readwrite) GBDeviceModel         deviceModel;
@property (assign, atomic, readwrite) GBCPUInfo             cpuInfo;
@property (assign, atomic, readwrite) CGFloat               physicalMemory;
@property (assign, atomic, readwrite) GBByteOrder           systemByteOrder;
@property (assign, atomic, readwrite) GBDisplayInfo         displayInfo;
@property (assign, atomic, readwrite) GBOSVersion           osVersion;
@property (assign, atomic, readwrite) BOOL                  isMacAppStoreAvailable;
@property (assign, atomic, readwrite) BOOL                  isIAPAvailable;

@end

@implementation GBDeviceDetails

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\nrawSystemInfoString: %@\nnodeName: %@\nfamily: %ld\ndeviceModel.major: %ld\ndeviceModel.minor: %ld\ncpuInfo.frequency: %.3f\ncpuInfo.numberOfCores: %ld\ncpuInfo.l2CacheSize: %.3f\npysicalMemory: %.3f\nsystemByteOrder: %ld\nscreenResolution: %.0fx%.0f\nosVersion.major: %ld\nosVersion.minor: %ld\nosVersion.patch: %ld",
        [super description],
        self.rawSystemInfoString,
        self.nodeName,
        self.family,
        (unsigned long)self.deviceModel.major,
        (unsigned long)self.deviceModel.minor,
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

@end

@implementation GBDeviceInfo

#pragma mark - Public API

+ (GBDeviceDetails *)deviceDetails {
    GBDeviceDetails *deviceDetails = [GBDeviceDetails new];

    deviceDetails.rawSystemInfoString = [self _rawSystemInfoString];
    deviceDetails.nodeName = [self _nodeName];
    deviceDetails.family = [self _deviceFamily];
    deviceDetails.cpuInfo = [self _cpuInfo];
    deviceDetails.physicalMemory = [self _physicalMemory];
    deviceDetails.systemByteOrder = [self _systemByteOrder];
    deviceDetails.osVersion = [self _osVersion];
    deviceDetails.displayInfo = [self _displayInfo];
    deviceDetails.deviceModel = [self _deviceModel];
    deviceDetails.isMacAppStoreAvailable = [self _isMacAppStoreAvailable];
    deviceDetails.isIAPAvailable = [self _isIAPAvailable];

    return deviceDetails;
}

#pragma mark - Private API

+ (NSString *)_sysctlStringForKey:(NSString *)key {
    const char *keyCString = [key UTF8String];
    NSString *answer;
    
    size_t length;
    sysctlbyname(keyCString, NULL, &length, NULL, 0);
    if (length) {
        char *answerCString = malloc(length*sizeof(char));
        sysctlbyname(keyCString, answerCString, &length, NULL, 0);
        answer = [NSString stringWithCString:answerCString encoding:NSUTF8StringEncoding];
        free(answerCString);
    }
    
    return answer;
}

+ (CGFloat)_sysctlCGFloatForKey:(NSString *)key {
    const char *keyCString = [key UTF8String];

    size_t length;
    sysctlbyname(keyCString, NULL, &length, NULL, 0);
    char *answerRaw = malloc(length);
    sysctlbyname(keyCString, answerRaw, &length, NULL, 0);
    CGFloat answerFloat;
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
    
    return answerFloat;
}

+ (struct utsname)_unameStruct {
    struct utsname systemInfo;
    uname(&systemInfo);

    return systemInfo;
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
    
    if (systemInfoString.length >=4 && [[systemInfoString substringToIndex:4] isEqualToString:@"iMac"]) {
        return GBDeviceFamilyiMac;
    }
    else if (systemInfoString.length >=7 && [[systemInfoString substringToIndex:7] isEqualToString:@"Macmini"]) {
        return GBDeviceFamilyMacMini;
    }
    else if (systemInfoString.length >=6 && [[systemInfoString substringToIndex:6] isEqualToString:@"MacPro"]) {
        return GBDeviceFamilyMacPro;
    }
    else if (systemInfoString.length >=10 && [[systemInfoString substringToIndex:10] isEqualToString:@"MacBookPro"]) {
        return GBDeviceFamilyMacBookPro;
    }
    else if (systemInfoString.length >=10 && [[systemInfoString substringToIndex:10] isEqualToString:@"MacBookAir"]) {
        return GBDeviceFamilyMacBookAir;
    }
    else if (systemInfoString.length >=7 && [[systemInfoString substringToIndex:7] isEqualToString:@"MacBook"]) {
        return GBDeviceFamilyMacBook;
    }
    else if (systemInfoString.length >=6 && [[systemInfoString substringToIndex:6] isEqualToString:@"Xserve"]) {
        return GBDeviceFamilyXserve;
    }
    else {
        return GBDeviceFamilyUnknown;
    }
}

+ (GBDeviceModel)_deviceModel {
    NSString *systemInfoString = [self _rawSystemInfoString];
    
    NSUInteger positionOfFirstInteger = [systemInfoString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location;
    NSUInteger positionOfComma = [systemInfoString rangeOfString:@","].location;

    return GBDeviceModelMake(
        [[systemInfoString substringWithRange:NSMakeRange(positionOfFirstInteger, positionOfComma - positionOfFirstInteger)] integerValue],
        [[systemInfoString substringFromIndex:positionOfComma + 1] integerValue]
     );
}

+ (NSString *)_rawSystemInfoString {
    return [self _sysctlStringForKey:kHardwareModelKey];
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
