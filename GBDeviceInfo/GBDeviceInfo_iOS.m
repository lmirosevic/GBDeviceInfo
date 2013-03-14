//
//  GBDeviceInfo_iOS.m
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

#import "GBDeviceInfo_iOS.h"

#import <sys/utsname.h>

@implementation GBDeviceInfo

+(GBDeviceDetails)deviceDetails {
    //NOTE: adjust code when double digit model numbers come out
    GBDeviceDetails details;
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *systemInfoString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //get data
    if ([[systemInfoString substringToIndex:6] isEqualToString:@"iPhone"]) {
        details.family = GBDeviceFamilyiPhone;
        details.bigModel = [[systemInfoString substringWithRange:NSMakeRange(6, 1)] intValue];
        details.smallModel = [[systemInfoString substringWithRange:NSMakeRange(8, 1)] intValue];
        
        if (details.bigModel == 1) {
            if (details.smallModel == 1) {
                details.model = GBDeviceModeliPhone;
            }
            else if (details.smallModel == 2) {
                details.model = GBDeviceModeliPhone3G;
            }
            else {
                details.model = GBDeviceModelUnknown;
            }
        }
        else if (details.bigModel == 2) {
            details.model = GBDeviceModeliPhone3GS;
        }
        else if (details.bigModel == 3) {
            details.model = GBDeviceModeliPhone4;
        }
        else if (details.bigModel == 4) {
            details.model = GBDeviceModeliPhone4S;
        }
        else if (details.bigModel == 5) {
            details.model = GBDeviceModeliPhone5;
        }
        else {
            details.model = GBDeviceModelUnknown;
        }
    }
    else if ([[systemInfoString substringToIndex:4] isEqualToString:@"iPad"]) {
        details.family = GBDeviceFamilyiPad;
        details.bigModel = [[systemInfoString substringWithRange:NSMakeRange(4, 1)] intValue];
        details.smallModel = [[systemInfoString substringWithRange:NSMakeRange(6, 1)] intValue];
        
        if (details.bigModel == 1) {
            details.model = GBDeviceModeliPad;
        }
        else if (details.bigModel == 2) {
            if (details.smallModel <= 4) {
                details.model = GBDeviceModeliPad2;
            }
            else if (details.smallModel <= 7) {
                details.model = GBDeviceModeliPadMini;
            }
        }
        else if (details.bigModel == 3) {
            if (details.smallModel <= 3) {
                details.model = GBDeviceModeliPad3;
            }
            else if (details.smallModel <= 6) {
                details.model = GBDeviceModeliPad4;
            }
            else {
                details.model = GBDeviceModelUnknown;
            }
        }
    }
    else if ([[systemInfoString substringToIndex:4] isEqualToString:@"iPod"]) {
        details.family = GBDeviceFamilyiPod;
        details.bigModel = [[systemInfoString substringWithRange:NSMakeRange(4, 1)] intValue];
        details.smallModel = [[systemInfoString substringWithRange:NSMakeRange(6, 1)] intValue];
        
        switch (details.bigModel) {
            case 1:
                details.model = GBDeviceModeliPod;
                break;
                
            case 2:
                details.model = GBDeviceModeliPod2;
                break;
                
            case 3:
                details.model = GBDeviceModeliPod3;
                break;
                
            case 4:
                details.model = GBDeviceModeliPod4;
                break;
                
            case 5:
                details.model = GBDeviceModeliPod5;
                break;
                
            default:
                details.model = GBDeviceModelUnknown;
                break;
        }
    }
    else {
        details.family = GBDeviceFamilyUnknown;
        details.bigModel = 0;
        details.smallModel = 0;
        details.model = GBDeviceModelUnknown;
    }
    
    //get screen size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //ipad old
    if ((screenWidth == 768) && (screenHeight == 1024)) {
        details.display = GBDeviceDisplayiPad;
    }
    //iphone
    else if ((screenWidth == 320) && (screenHeight == 480)) {
        details.display = GBDeviceDisplayiPhone35Inch;
    }
    //iphone 4 inch
    else if ((screenWidth == 320) && (screenHeight == 568)) {
        details.display = GBDeviceDisplayiPhone4Inch;
    }
    //unknown
    else {
        details.display = GBDeviceDisplayUnknown;
    }
    
    //ios version
    NSArray *versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if (versionCompatibility.count > 0) {
        NSInteger version = [versionCompatibility[0] integerValue];
        details.iOSVersion = version >= 0 ? (NSUInteger)version : 0;
    }
    else {
        details.iOSVersion = 0;
    }
    
    return details;
}

+(NSString *)rawSystemInfoString {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@end