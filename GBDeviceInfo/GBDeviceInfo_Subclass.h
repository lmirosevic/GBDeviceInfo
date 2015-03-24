//
//  GBDeviceInfo_Subclass.h
//  GBDeviceInfo
//
//  Created by Luka Mirosevic on 24/03/2015.
//  Copyright (c) 2015 Luka Mirosevic. All rights reserved.
//

@interface GBDeviceInfo_Common ()

@property (strong, atomic, readwrite) NSString          *rawSystemInfoString;
@property (assign, atomic, readwrite) GBCPUInfo         cpuInfo;
@property (assign, atomic, readwrite) CGFloat           physicalMemory;
@property (assign, atomic, readwrite) GBOSVersion       osVersion;
@property (assign, atomic, readwrite) GBDeviceFamily    family;

+ (NSString *)_sysctlStringForKey:(NSString *)key;
+ (CGFloat)_sysctlCGFloatForKey:(NSString *)key;
+ (GBCPUInfo)_cpuInfo;
+ (CGFloat)_physicalMemory;
+ (GBByteOrder)_systemByteOrder;

@end
