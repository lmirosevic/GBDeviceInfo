//
//  GBDeviceInfo_iOS.h
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

#import "GBDeviceInfo_Common.h"

#import "GBDeviceInfoTypes_iOS.h"

@interface GBDeviceInfo : GBDeviceInfo_Common

/**
 The device version. e.g. {7, 2}.
 */
@property (assign, atomic, readonly) GBDeviceVersion    deviceVersion;

/**
 The human readable name for the device, e.g. "iPhone 6".
 */
@property (strong, atomic, readonly) NSString           *modelString;


/**
 The specific device model, e.g. GBDeviceModeliPhone6.
 */
@property (assign, atomic, readonly) GBDeviceModel      model;

/**
 The display identifier, e.g. GBDeviceDisplayiPhone47Inch
 */
@property (assign, atomic, readonly) GBDeviceDisplay    display;

/**
 Information about the display.
 */
@property (assign, atomic, readonly) GBDisplayInfo      displayInfo;

/**
 Is the device jailbroken? Add the `GBDeviceInfo/Jailbreak` subspec to your project to use this property.
 */
@property (assign, atomic, readonly) BOOL               isJailbroken;

@end
