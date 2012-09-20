//
//  GBDeviceInfo.m
//  VLC Remote
//
//  Created by Luka Mirošević on 15/02/2012.
//  Copyright (c) 2012 Goonbee. All rights reserved.
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
    
    return details;
}

+(NSString *)rawSystemInfoString {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@end