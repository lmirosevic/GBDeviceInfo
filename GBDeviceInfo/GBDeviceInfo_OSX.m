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

static NSString * const kHardwareModelKey =                @"hw.model";
static NSString * const kHardwareMemorySizeKey =           @"hw.memsize";
static NSString * const kHardwareCPUFrequencyKey =         @"hw.cpufrequency";
static NSString * const kHardwareNumberOfCoresKey =        @"hw.ncpu";
static NSString * const kHardwareByteOrderKey =            @"hw.byteorder";
static NSString * const kHardwareL2CacheSizeKey =          @"hw.l2cachesize";

@interface GBDeviceDetails ()

@property (strong, atomic, readwrite) NSString           *rawSystemInfoString;
@property (strong, atomic, readwrite) NSString           *nodeName;
@property (assign, atomic, readwrite) GBDeviceFamily     family;
@property (assign, atomic, readwrite) NSUInteger         majorModelNumber;
@property (assign, atomic, readwrite) NSUInteger         minorModelNumber;
@property (assign, atomic, readwrite) CGFloat            physicalMemory;
@property (assign, atomic, readwrite) CGFloat            cpuFrequency;
@property (assign, atomic, readwrite) NSUInteger         numberOfCores;
@property (assign, atomic, readwrite) CGFloat            l2CacheSize;
@property (assign, atomic, readwrite) GBByteOrder        byteOrder;
@property (assign, atomic, readwrite) CGSize             screenResolution;
@property (assign, atomic, readwrite) NSUInteger         majorOSVersion;
@property (assign, atomic, readwrite) NSUInteger         minorOSVersion;
@property (assign, atomic, readwrite) BOOL               isMacAppStoreAvailable;
@property (assign, atomic, readwrite) BOOL               isIAPAvailable;

@end

@implementation GBDeviceDetails

-(NSString *)description {
    return [NSString stringWithFormat:@"%@\nrawSystemInfoString: %@\nnodeName: %@\nfamily: %d\nmajorModelNumber: %ld\nminorModelNumber: %ld\npysicalMemory: %.3f\ncpuFrequency: %.3f\nnumberOfCores: %ld\nl2CacheSize: %.3f\nbyteOrder: %d\nscreenResolution: %.0fx%.0f\nmajorOSVersion: %ld\nminorOSVersion: %ld", [super description], self.rawSystemInfoString, self.nodeName, self.family, (unsigned long)self.majorModelNumber, (unsigned long)self.minorModelNumber, self.physicalMemory, self.cpuFrequency, (unsigned long)self.numberOfCores, self.l2CacheSize, self.byteOrder, self.screenResolution.width, self.screenResolution.height, (unsigned long)self.majorOSVersion, (unsigned long)self.minorOSVersion];
}

@end


@implementation GBDeviceInfo

#pragma mark - private API

+(NSString *)_sysctlStringForKey:(NSString *)key {
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

+(CGFloat)_sysctlCGFloatForKey:(NSString *)key {
    const char *keyCString = [key UTF8String];
    CGFloat answer;
    
    size_t length;
    int64_t answerInt64;
    sysctlbyname(keyCString, &answerInt64, &length, NULL, 0);
    answer = (CGFloat)answerInt64;
    
    return answer;
}

+(struct utsname)_unameStruct {
    struct utsname systemInfo;
    uname(&systemInfo);

    return systemInfo;
}

#pragma mark - convenience

+(CGFloat)physicalMemory {
    return [self _sysctlCGFloatForKey:kHardwareMemorySizeKey] / 1073741824.; //Giga
}

+(CGFloat)cpuFrequency {
    return [self _sysctlCGFloatForKey:kHardwareCPUFrequencyKey] / 1073741824.; //Giga
}

+(NSUInteger)numberOfCores {
    return [self _sysctlCGFloatForKey:kHardwareNumberOfCoresKey];
}

+(CGFloat)l2CacheSize {
    return [self _sysctlCGFloatForKey:kHardwareL2CacheSizeKey] / 1024.; //Kilo
}

+(GBByteOrder)byteOrder {
    NSString *byteOrderString = [self _sysctlStringForKey:kHardwareByteOrderKey];
 
    if ([byteOrderString isEqualToString:@"1234"]) {
        return GBByteOrderLittleEndian;
    }
    else {
        return GBByteOrderBigEndian;
    }
}

+(NSUInteger)majorOSVersion {
    NSString *kernelVersionString = [NSString stringWithCString:[self _unameStruct].release encoding:NSUTF8StringEncoding];
    NSString *majorKernelVersion = [kernelVersionString componentsSeparatedByString:@"."][0];
    NSUInteger majorKernelVersionInteger = [majorKernelVersion integerValue];
    NSUInteger majorOSVersionInteger = majorKernelVersionInteger - 4;
    
    return majorOSVersionInteger;
}

+(NSUInteger)minorOSVersion {
    NSString *kernelVersionString = [NSString stringWithCString:[self _unameStruct].release encoding:NSUTF8StringEncoding];
    NSString *minorKernelVersion = [kernelVersionString componentsSeparatedByString:@"."][1];
    NSUInteger minorKernelVersionInteger = [minorKernelVersion integerValue];
    NSUInteger minorOSVersionInteger = minorKernelVersionInteger;
    
    return minorOSVersionInteger;
}

+(CGSize)screenResolution {
    return [NSScreen mainScreen].frame.size;
}

+(GBDeviceFamily)family {
    NSString *systemInfoString = [self rawSystemInfoString];
    
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

+(NSUInteger)majorModelNumber {
    NSString *systemInfoString = [self rawSystemInfoString];
    
    NSUInteger positionOfFirstInteger = [systemInfoString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location;
    NSUInteger positionOfComma = [systemInfoString rangeOfString:@","].location;
    
    return [[systemInfoString substringWithRange:NSMakeRange(positionOfFirstInteger, positionOfComma - positionOfFirstInteger)] integerValue];
}

+(NSUInteger)minorModelNumber {
    NSString *systemInfoString = [self rawSystemInfoString];
    
    NSUInteger positionOfComma = [systemInfoString rangeOfString:@"," options:NSBackwardsSearch].location;
    return [[systemInfoString substringFromIndex:positionOfComma + 1] integerValue];
}

+(NSString *)rawSystemInfoString {
    return [self _sysctlStringForKey:kHardwareModelKey];
}

+(NSString *)nodeName {
    return [NSString stringWithCString:[self _unameStruct].nodename encoding:NSUTF8StringEncoding];
}

+(BOOL)isMacAppStoreAvailable {
    return (([self majorOSVersion] >= 7) ||
            ([self majorOSVersion] == 6 && [self minorOSVersion] >=  6));
}

+(BOOL)isIAPAvailable {
    return ([self majorOSVersion] >= 7);
}

#pragma mark - public API

+(GBDeviceDetails *)deviceDetails {
    GBDeviceDetails *deviceDetails = [GBDeviceDetails new];
    
    deviceDetails.rawSystemInfoString = [self rawSystemInfoString];
    deviceDetails.physicalMemory = [self physicalMemory];
    deviceDetails.cpuFrequency = [self cpuFrequency];
    deviceDetails.numberOfCores = [self numberOfCores];
    deviceDetails.l2CacheSize = [self l2CacheSize];
    deviceDetails.byteOrder = [self byteOrder];
    deviceDetails.majorOSVersion = [self majorOSVersion];
    deviceDetails.minorOSVersion = [self minorOSVersion];
    deviceDetails.nodeName = [self nodeName];
    deviceDetails.screenResolution = [self screenResolution];
    deviceDetails.family = [self family];
    deviceDetails.majorModelNumber = [self majorModelNumber];
    deviceDetails.minorModelNumber = [self minorModelNumber];
    deviceDetails.isMacAppStoreAvailable = [self isMacAppStoreAvailable];
    deviceDetails.isIAPAvailable = [self isIAPAvailable];
    
    return deviceDetails;
}

@end