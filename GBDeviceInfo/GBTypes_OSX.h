//
//  GBTypes_OSX.h
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

typedef NS_ENUM(NSInteger, GBByteOrder) {
    GBByteOrderLittleEndian,
    GBByteOrderBigEndian,
};

typedef NS_ENUM(NSInteger, GBDeviceFamily) {
    GBDeviceFamilyUnknown = 0,
    GBDeviceFamilyiMac,
    GBDeviceFamilyMacMini,
    GBDeviceFamilyMacPro,
    GBDeviceFamilyMacBook,
    GBDeviceFamilyMacBookAir,
    GBDeviceFamilyMacBookPro,
    GBDeviceFamilyXserve,
};

typedef struct {
    /**
     Major OS version number. For e.g. 10.8.2 => 10
     */
    NSUInteger                                          major;
    
    /**
     Minor OS version number. For e.g. 10.8.2 => 8
     */
    NSUInteger                                          minor;
    
    /**
     Patch OS version number. For e.g. 10.8.2 => 2
     */
    NSUInteger                                          patch;
} GBOSVersion;

/**
 Makes a GBOSVersion struct.
 */
inline static GBOSVersion GBOSVersionMake(NSUInteger major, NSUInteger minor,  NSUInteger patch) {
    return (GBOSVersion){major, minor, patch};
};

typedef struct {
    /** 
     Major device model. e.g. 13 for iMac13,2
     */
    NSUInteger                                          major;

    /**
     Minor device model. e.g. 2 for iMac13,2
     */
    NSUInteger                                          minor;
} GBDeviceVersion;

/**
 Makes a GBDeviceVersion struct.
 */
inline static GBDeviceVersion GBDeviceVersionMake(NSUInteger major, NSUInteger minor) {
    return (GBDeviceVersion){major, minor};
};

typedef struct {
    /**
     CPU frequency, in GHz.
     */
    CGFloat                                             frequency;              // GHz (giga)
    
    /**
     Number of logical cores the CPU has.
     */
    NSUInteger                                          numberOfCores;
    
    /**
     CPU's l2 cache size, in KB.
     */
    CGFloat                                             l2CacheSize;            // KB (kibi)
} GBCPUInfo;

/**
 Makes a GBCPUInfo struct.
 */
inline static GBCPUInfo GBCPUInfoMake(CGFloat frequency, NSUInteger numberOfCores, CGFloat l2CacheSize) {
    return (GBCPUInfo){frequency, numberOfCores, l2CacheSize};
};

typedef struct {
    /**
     The main display's resolution.
     */
    CGSize                                              resolution;
} GBDisplayInfo;

/**
 Makes a GBDisplayInfo struct.
 */
inline static GBDisplayInfo GBDisplayInfoMake(CGSize resolution) {
    return (GBDisplayInfo){resolution};
};

@interface GBDeviceDetails : NSObject

/**
 The raw system info string, e.g. "iMac13,2".
 */
@property (strong, atomic, readonly) NSString           *rawSystemInfoString;

/**
 The node name on the network, e.g. "MyMachine.local".
 */
@property (strong, atomic, readonly) NSString           *nodeName;

/**
 The device family. e.g. GBDeviceFamilyiMac.
 */
@property (assign, atomic, readonly) GBDeviceFamily     family;

/**
 The device version. e.g. {13, 2}.
 */
@property (assign, atomic, readonly) GBDeviceVersion    deviceVersion;

/**
 Information about the CPU.
 */
@property (assign, atomic, readonly) GBCPUInfo          cpuInfo;

/**
 Amount of physical memory (RAM) available to the system, in GB.
 */
@property (assign, atomic, readonly) CGFloat            physicalMemory;         // GB (gibi)

/**
 System byte order, e.g. GBByteOrderLittleEndian.
 */
@property (assign, atomic, readonly) GBByteOrder        systemByteOrder;

/** 
 Information about the display.
 */
@property (assign, atomic, readonly) GBDisplayInfo      displayInfo;

/**
 Information about the system's OS. e.g. {10, 8, 2}.
 */
@property (assign, atomic, readonly) GBOSVersion        osVersion;

/**
 Indicates whether the app store is available on this machine.
 */
@property (assign, atomic, readonly) BOOL               isMacAppStoreAvailable; //YES if OSX >= 10.6.6

/**
 Indicates whether IAP is available on this machine.
 */
@property (assign, atomic, readonly) BOOL               isIAPAvailable;         //YES if OSX >= 10.7

@end
