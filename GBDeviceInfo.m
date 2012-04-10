//
//  GBDeviceInfo.m
//  VLC Remote
//
//  Created by Luka Mirošević on 15/02/2012.
//  Copyright (c) 2012 Goonbee. All rights reserved.
//

#import "GBDeviceInfo.h"

#import <sys/utsname.h>

@implementation GBDeviceInfo

#pragma mark - Singleton

+(GBDeviceInfo *)currentInfo {
    static GBDeviceInfo *currentInfo;
    
    @synchronized(self)
    {
        if (!currentInfo)
            currentInfo = [[GBDeviceInfo alloc] init];
        
        return currentInfo;
    }
}

#pragma mark - Custom accessors

-(GBDeviceDetails)deviceDetails {
    GBDeviceDetails details;
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *systemInfoString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //get data
    if ([[systemInfoString substringToIndex:6] isEqualToString:@"iPhone"]) {
        details.modelFamily = GBDeviceModelFamilyiPhone;
        details.bigModel = [[systemInfoString substringWithRange:NSMakeRange(6, 1)] intValue];
        details.smallModel = [[systemInfoString substringWithRange:NSMakeRange(8, 1)] intValue];
        
        if (details.bigModel == 1) {
            if (details.smallModel == 1) {
                details.specificModel = GBDeviceModeliPhone;
            }
            else if (details.smallModel == 2) {
                details.specificModel = GBDeviceModeliPhone3G;
            }
            else {
                details.specificModel = GBDeviceModelUnknown;
            }
        }
        else if (details.bigModel == 2) {
            details.specificModel = GBDeviceModeliPhone3GS;
        }
        else if (details.bigModel == 3) {
            details.specificModel = GBDeviceModeliPhone4;
        }
        else if (details.bigModel == 4) {
            details.specificModel = GBDeviceModeliPhone4S;
        }
        else {
            details.specificModel = GBDeviceModelUnknown;
        }
    }
    else if ([[systemInfoString substringToIndex:4] isEqualToString:@"iPad"]) {
        details.modelFamily = GBDeviceModelFamilyiPad;
        details.bigModel = [[systemInfoString substringWithRange:NSMakeRange(4, 1)] intValue];
        details.smallModel = [[systemInfoString substringWithRange:NSMakeRange(6, 1)] intValue];
        
        switch (details.bigModel) {
            case 1:
                details.specificModel = GBDeviceModeliPad;
                break;
                
            case 2:
                details.specificModel = GBDeviceModeliPad2;
                break;
                
            case 3:
                details.specificModel = GBDeviceModeliPad3;
                break;
                
            default:
                details.specificModel = GBDeviceModelUnknown;
                break;
        }
    }
    else if ([[systemInfoString substringToIndex:4] isEqualToString:@"iPod"]) {
        details.modelFamily = GBDeviceModelFamilyiPod;
        details.bigModel = [[systemInfoString substringWithRange:NSMakeRange(4, 1)] intValue];
        details.smallModel = [[systemInfoString substringWithRange:NSMakeRange(6, 1)] intValue];
        
        switch (details.bigModel) {
            case 1:
                details.specificModel = GBDeviceModeliPod;
                break;
                
            case 2:
                details.specificModel = GBDeviceModeliPod2;
                break;
                
            case 3:
                details.specificModel = GBDeviceModeliPod3;
                break;
                
            case 4:
                details.specificModel = GBDeviceModeliPod4;
                break;
                
            default:
                details.specificModel = GBDeviceModelUnknown;
                break;
        }
    }
    else {
        details.modelFamily = GBDeviceModelFamilyUnknown;        
        details.bigModel = 0;
        details.smallModel = 0;
        details.specificModel = GBDeviceModelUnknown;
    }
    
    return details;
}

+(NSString *)rawSystemInfoString {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@end