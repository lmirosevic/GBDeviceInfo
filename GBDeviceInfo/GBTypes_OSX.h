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

typedef enum {
    GBByteOrderLittleEndian,
    GBByteOrderBigEndian,
} GBByteOrder;

typedef enum {
    GBDeviceFamilyUnknown = 0,
    GBDeviceFamilyiMac,
    GBDeviceFamilyMacMini,
    GBDeviceFamilyMacPro,
    GBDeviceFamilyMacBook,
    GBDeviceFamilyMacBookAir,
    GBDeviceFamilyMacBookPro,
    GBDeviceFamilyXserve,
} GBDeviceFamily;

@interface GBDeviceDetails : NSObject

@property (strong, atomic, readonly) NSString           *rawSystemInfoString;
@property (strong, atomic, readonly) NSString           *nodeName;
@property (assign, atomic, readonly) GBDeviceFamily     family;
@property (assign, atomic, readonly) NSUInteger         majorModelNumber;
@property (assign, atomic, readonly) NSUInteger         minorModelNumber;
@property (assign, atomic, readonly) CGFloat            physicalMemory;         // GB
@property (assign, atomic, readonly) CGFloat            cpuFrequency;           // GHz
@property (assign, atomic, readonly) NSUInteger         numberOfCores;
@property (assign, atomic, readonly) CGFloat            l2CacheSize;            // KB
@property (assign, atomic, readonly) GBByteOrder        byteOrder;
@property (assign, atomic, readonly) CGSize             screenResolution;
@property (assign, atomic, readonly) NSUInteger         majorOSVersion;
@property (assign, atomic, readonly) NSUInteger         minorOSVersion;

@end