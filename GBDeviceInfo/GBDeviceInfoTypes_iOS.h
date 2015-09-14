//
//  GBDeviceInfoTypes_iOS.h
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

typedef NS_ENUM(NSInteger, GBDeviceModel) {
    GBDeviceModelUnknown = 0,
    GBDeviceModelSimulatoriPhone,
    GBDeviceModelSimulatoriPad,
    GBDeviceModeliPhone1,
    GBDeviceModeliPhone3G,
    GBDeviceModeliPhone3GS,
    GBDeviceModeliPhone4,
    GBDeviceModeliPhone4S,
    GBDeviceModeliPhone5,
    GBDeviceModeliPhone5C,
    GBDeviceModeliPhone5S,
    GBDeviceModeliPhone6,
    GBDeviceModeliPhone6Plus,
    GBDeviceModeliPhone6S,
    GBDeviceModeliPhone6SPlus,
    GBDeviceModeliPad1,
    GBDeviceModeliPad2,
    GBDeviceModeliPad3,
    GBDeviceModeliPad4,
    GBDeviceModeliPadMini1,
    GBDeviceModeliPadMini2,
    GBDeviceModeliPadMini3,
    GBDeviceModeliPadAir1,
    GBDeviceModeliPadAir2,
    GBDeviceModeliPod1,
    GBDeviceModeliPod2,
    GBDeviceModeliPod3,
    GBDeviceModeliPod4,
    GBDeviceModeliPod5,
};

typedef NS_ENUM(NSInteger, GBDeviceDisplay) {
    GBDeviceDisplayUnknown = 0,
    GBDeviceDisplayiPad,
    GBDeviceDisplayiPhone35Inch,
    GBDeviceDisplayiPhone4Inch,
    GBDeviceDisplayiPhone47Inch,
    GBDeviceDisplayiPhone55Inch,
};

typedef struct {
    /**
     The display's pixel density in ppi (pixels per inch).
     */
    CGFloat                                              pixelsPerInch;
} GBDisplayInfo;

/**
 Makes a GBDisplayInfo struct.
 */
inline static GBDisplayInfo GBDisplayInfoMake(CGFloat pixelsPerInch) {
    return (GBDisplayInfo){pixelsPerInch};
};
