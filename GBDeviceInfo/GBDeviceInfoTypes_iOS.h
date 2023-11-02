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
    GBDeviceModeliPhoneSE2,
    GBDeviceModeliPhoneSE3,
    GBDeviceModeliPhone6,
    GBDeviceModeliPhone6Plus,
    GBDeviceModeliPhone6s,
    GBDeviceModeliPhone6sPlus,
    GBDeviceModeliPhone7,
    GBDeviceModeliPhone7Plus,
    GBDeviceModeliPhone8,
    GBDeviceModeliPhone8Plus,
    GBDeviceModeliPhoneX,
    GBDeviceModeliPhoneXR,
    GBDeviceModeliPhoneXS,
    GBDeviceModeliPhoneXSMax,
    GBDeviceModeliPhone11,
    GBDeviceModeliPhone11Pro,
    GBDeviceModeliPhone11ProMax,
    GBDeviceModeliPhone12Mini,
    GBDeviceModeliPhone12,
    GBDeviceModeliPhone12Pro,
    GBDeviceModeliPhone12ProMax,
    GBDeviceModeliPhone13Mini,
    GBDeviceModeliPhone13,
    GBDeviceModeliPhone13Pro,
    GBDeviceModeliPhone13ProMax,
    GBDeviceModeliPhone14,
    GBDeviceModeliPhone14Plus,
    GBDeviceModeliPhone14Pro,
    GBDeviceModeliPhone14ProMax,
    GBDeviceModeliPhone15,
    GBDeviceModeliPhone15Plus,
    GBDeviceModeliPhone15Pro,
    GBDeviceModeliPhone15ProMax,
    GBDeviceModeliPad1,
    GBDeviceModeliPad2,
    GBDeviceModeliPad3,
    GBDeviceModeliPad4,
    GBDeviceModeliPad5,
    GBDeviceModeliPad6,
    GBDeviceModeliPad7,
    GBDeviceModeliPad8,
    GBDeviceModeliPad9,
    GBDeviceModeliPad10,
    GBDeviceModeliPadMini1,
    GBDeviceModeliPadMini2,
    GBDeviceModeliPadMini3,
    GBDeviceModeliPadMini4,
    GBDeviceModeliPadMini5,
    GBDeviceModeliPadMini6,
    GBDeviceModeliPadAir1,
    GBDeviceModeliPadAir2,
    GBDeviceModeliPadAir3,
    GBDeviceModeliPadAir4,
    GBDeviceModeliPadAir5,
    GBDeviceModeliPadPro9p7Inch,
    GBDeviceModeliPadPro10p5Inch,
    GBDeviceModeliPadPro12p9Inch,
    GBDeviceModeliPadPro12p9Inch2,
    GBDeviceModeliPadPro11Inch,
    GBDeviceModeliPadPro11Inch2,
    GBDeviceModeliPadPro12p9Inch3,
    GBDeviceModeliPadPro12p9Inch4,
    GBDeviceModeliPadPro11Inch3,
    GBDeviceModeliPadPro12p9Inch5,
    GBDeviceModeliPadPro11Inch4,
    GBDeviceModeliPadPro12p9Inch6,
    GBDeviceModeliPod1,
    GBDeviceModeliPod2,
    GBDeviceModeliPod3,
    GBDeviceModeliPod4,
    GBDeviceModeliPod5,
    GBDeviceModeliPod6,
    GBDeviceModeliPod7
};

typedef NS_ENUM(NSInteger, GBDeviceDisplay) {
    GBDeviceDisplayUnknown = 0,
    GBDeviceDisplay3p5Inch,
    GBDeviceDisplay4Inch,
    GBDeviceDisplay4p7Inch,
    GBDeviceDisplay5p4Inch,
    GBDeviceDisplay5p5Inch,
    GBDeviceDisplay5p8Inch,
    GBDeviceDisplay6p1Inch,
    GBDeviceDisplay6p5Inch,
    GBDeviceDisplay6p7Inch,
    GBDeviceDisplay7p9Inch,
    GBDeviceDisplay8p3Inch,
    GBDeviceDisplay9p7Inch,
    GBDeviceDisplay10p2Inch,
    GBDeviceDisplay10p5Inch,
    GBDeviceDisplay10p9Inch,
    GBDeviceDisplay11Inch,
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
