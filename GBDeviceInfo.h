//
//  GBDeviceInfo.h
//  VLC Remote
//
//  Created by Luka Mirošević on 15/02/2012.
//  Copyright (c) 2012 Goonbee. All rights reserved.
//
//  This software is licensed under the terms of the GNU General Public License.
//  http://www.gnu.org/licenses/

#import <Foundation/Foundation.h>

@interface GBDeviceInfo : NSObject

//defs
typedef enum {
    GBDeviceModelUnknown = 0,
    GBDeviceModeliPhone,
    GBDeviceModeliPhone3G,
    GBDeviceModeliPhone3GS,
    GBDeviceModeliPhone4,
    GBDeviceModeliPhone4S,
    GBDeviceModeliPhone5,
    GBDeviceModeliPad,
    GBDeviceModeliPad2,
    GBDeviceModeliPad3,
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
} GBDeviceFamily;

typedef struct {
    GBDeviceModel           model;
    GBDeviceFamily          family;
    NSUInteger              bigModel;
    NSUInteger              smallModel;
} GBDeviceDetails;

//public API
+(GBDeviceDetails)deviceDetails;
+(NSString *)rawSystemInfoString;

@end