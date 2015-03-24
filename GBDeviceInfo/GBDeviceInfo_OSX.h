//
//  GBDeviceInfo_OSX.h
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

#import "GBDeviceInfo_Common.h"

#import "GBDeviceInfoTypes_OSX.h"

@interface GBDeviceInfo : GBDeviceInfo_Common

/**
 The node name on the network, e.g. "MyMachine.local".
 
 N.B.: Dynamic getter that recalculates the value each time.
 */
@property (strong, atomic, readonly) NSString           *nodeName;

/**
 The device version. e.g. {13, 2}.
 */
@property (assign, atomic, readonly) GBDeviceVersion    deviceVersion;

/**
 System byte order, e.g. GBByteOrderLittleEndian.
 */
@property (assign, atomic, readonly) GBByteOrder        systemByteOrder;

/**
 Information about the display.
 
  N.B.: Dynamic getter that recalculates the value each time.
 */
@property (assign, atomic, readonly) GBDisplayInfo      displayInfo;

/**
 Indicates whether the app store is available on this machine.
 */
@property (assign, atomic, readonly) BOOL               isMacAppStoreAvailable; //YES if OSX >= 10.6.6

/**
 Indicates whether IAP is available on this machine.
 */
@property (assign, atomic, readonly) BOOL               isIAPAvailable;         //YES if OSX >= 10.7

@end
