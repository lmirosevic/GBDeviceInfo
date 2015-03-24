//
//  GBDeviceInfoTypes_Common.h
//  GBDeviceInfo
//
//  Created by Luka Mirosevic on 20/02/2015.
//  Copyright (c) 2015 Luka Mirosevic. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBDeviceInfoTypes_Common.h"
#import "GBDeviceInfoInterface.h"

#pragma mark - Public

@interface GBDeviceInfo_Common : NSObject <GBDeviceInfoInterface>

/**
 The raw system info string, e.g. "iPhone7,2".
 */
@property (strong, atomic, readonly) NSString           *rawSystemInfoString;

/**
 The device family. e.g. GBDeviceFamilyiPhone.
 */
@property (assign, atomic, readonly) GBDeviceFamily     family;

/**
 Information about the CPU.
 */
@property (assign, atomic, readonly) GBCPUInfo          cpuInfo;

/**
 Amount of physical memory (RAM) available to the system, in GB.
 */
@property (assign, atomic, readonly) CGFloat            physicalMemory;         // GB (gibi)

/**
 Information about the system's OS. e.g. {10, 8, 2}.
 */
@property (assign, atomic, readonly) GBOSVersion        osVersion;

@end
