//
//  GBDeviceInfo.m
//  GBDeviceInfo
//
//  Created by Luka Mirosevic on 16/10/2012.
//  Copyright (c) 2012 Luka Mirosevic. All rights reserved.
//
//
//  This software is licensed under the terms of the GNU General Public License.
//  http://www.gnu.org/licenses/

//NOTE, adjust code when double digit model numbers come out

#import "GBDeviceInfo.h"

#import <sys/utsname.h>

@implementation GBDeviceInfo

+(GBDeviceDetails)deviceDetails {
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
        
        switch (details.bigModel) {
            case 1:
                details.model = GBDeviceModeliPad;
                break;
                
            case 2:
                details.model = GBDeviceModeliPad2;
                break;
                
            case 3:
                details.model = GBDeviceModeliPad3;
                break;
                
            default:
                details.model = GBDeviceModelUnknown;
                break;
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