//
//  GBTypes_iOS.h
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
    GBDeviceModelUnknown = 0,
    GBDeviceModeliPhoneSimulator,
    GBDeviceModeliPadSimulator,
    GBDeviceModeliPhone,
    GBDeviceModeliPhone3G,
    GBDeviceModeliPhone3GS,
    GBDeviceModeliPhone4,
    GBDeviceModeliPhone4S,
    GBDeviceModeliPhone5,
    GBDeviceModeliPhone5C,
    GBDeviceModeliPhone5S,
    GBDeviceModeliPad,
    GBDeviceModeliPad2,
    GBDeviceModeliPad3,
    GBDeviceModeliPad4,
    GBDeviceModeliPadMini,
    GBDeviceModeliPadMiniRetina,
    GBDeviceModeliPadAir,
    GBDeviceModeliPod,
    GBDeviceModeliPod2,
    GBDeviceModeliPod3,
    GBDeviceModeliPod4,
    GBDeviceModeliPod5,
} GBDeviceModel;

typedef enum {
    GBDeviceFamilyUnknown = 0,
    GBDeviceFamilyiPhone,
    GBDeviceFamilyiPad,
    GBDeviceFamilyiPod,
    GBDeviceFamilySimulator,
} GBDeviceFamily;

typedef enum {
    GBDeviceDisplayUnknown = 0,
    GBDeviceDisplayiPad,
    GBDeviceDisplayiPhone35Inch,
    GBDeviceDisplayiPhone4Inch,
} GBDeviceDisplay;

@interface GBDeviceDetails : NSObject

@property (strong, atomic, readonly) NSString           *rawSystemInfoString;
@property (strong, atomic, readonly) NSString           *modelString;
@property (assign, atomic, readonly) GBDeviceModel      model;
@property (assign, atomic, readonly) GBDeviceFamily     family;
@property (assign, atomic, readonly) GBDeviceDisplay    display;
@property (assign, atomic, readonly) NSUInteger         majorModelNumber;
@property (assign, atomic, readonly) NSUInteger         minorModelNumber;
@property (assign, atomic, readonly) NSUInteger         majoriOSVersion;
@property (assign, atomic, readonly) NSUInteger         minoriOSVersion;

@end
