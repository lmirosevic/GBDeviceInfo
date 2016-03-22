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
    GBDeviceModeliPhone5c,
    GBDeviceModeliPhone5s,
    GBDeviceModeliPhoneSE,
    GBDeviceModeliPhone6,
    GBDeviceModeliPhone6Plus,
    GBDeviceModeliPhone6s,
    GBDeviceModeliPhone6sPlus,
    GBDeviceModeliPad1,
    GBDeviceModeliPad2,
    GBDeviceModeliPad3,
    GBDeviceModeliPad4,
    GBDeviceModeliPadMini1,
    GBDeviceModeliPadMini2,
    GBDeviceModeliPadMini3,
    GBDeviceModeliPadMini4,
    GBDeviceModeliPadAir1,
    GBDeviceModeliPadAir2,
    GBDeviceModeliPadPro9p7Inch,
    GBDeviceModeliPadPro12p9Inch,
    GBDeviceModeliPod1,
    GBDeviceModeliPod2,
    GBDeviceModeliPod3,
    GBDeviceModeliPod4,
    GBDeviceModeliPod5,
    GBDeviceModeliPod6,
};

typedef NS_ENUM(NSInteger, GBDeviceDisplay) {
    GBDeviceDisplayUnknown = 0,
    GBDeviceDisplay3p5Inch,
    GBDeviceDisplay4Inch,
    GBDeviceDisplay4p7Inch,
    GBDeviceDisplay5p5Inch,
    GBDeviceDisplay7p9Inch,
    GBDeviceDisplay9p7Inch,
    GBDeviceDisplay12p9Inch,
};

typedef struct {
    /**
     The display of this device.
     
     Returns GBDeviceDisplayUnknown on the simulator.
     */
    GBDeviceDisplay                                     display;
    
    /**
     The display's pixel density in ppi (pixels per inch).
     
     Returns 0 on the simulator.
     */
    CGFloat                                             pixelsPerInch;
} GBDisplayInfo;

/**
 Makes a GBDisplayInfo struct.
 */
inline static GBDisplayInfo GBDisplayInfoMake(GBDeviceDisplay display, CGFloat pixelsPerInch) {
    return (GBDisplayInfo){display, pixelsPerInch};
};
