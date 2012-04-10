//
//  GBDeviceInfo.h
//  VLC Remote
//
//  Created by Luka Mirošević on 15/02/2012.
//  Copyright (c) 2012 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBDeviceInfo : NSObject

typedef enum {
    GBDeviceModelUnknown = 0,
    GBDeviceModeliPhone,
    GBDeviceModeliPhone3G,
    GBDeviceModeliPhone3GS,
    GBDeviceModeliPhone4,
    GBDeviceModeliPhone4S,
    GBDeviceModeliPad,
    GBDeviceModeliPad2,
    GBDeviceModeliPad3,
    GBDeviceModeliPod,
    GBDeviceModeliPod2,
    GBDeviceModeliPod3,
    GBDeviceModeliPod4,
} GBDeviceSpecificModel;

typedef enum {
    GBDeviceModelFamilyUnknown = 0,
    GBDeviceModelFamilyiPhone,
    GBDeviceModelFamilyiPad,
    GBDeviceModelFamilyiPod,
} GBDeviceModelFamily;

typedef struct {
    GBDeviceSpecificModel specificModel;
    GBDeviceModelFamily modelFamily;
    NSUInteger bigModel;
    NSUInteger smallModel;
} GBDeviceDetails;

//WARNING, only works for single digit model numbers.
@property (readonly, nonatomic) GBDeviceDetails deviceDetails;

+(GBDeviceInfo *)currentInfo;

+(NSString *)rawSystemInfoString;

@end