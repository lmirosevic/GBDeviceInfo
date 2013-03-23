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


@interface GBDeviceDetails()

@property (strong, atomic, readwrite) NSString           *rawSystemInfoString;
@property (assign, atomic, readwrite) GBDeviceModel      model;
@property (assign, atomic, readwrite) GBDeviceFamily     family;
@property (assign, atomic, readwrite) GBDeviceDisplay    display;
@property (assign, atomic, readwrite) NSUInteger         majorModelNumber;
@property (assign, atomic, readwrite) NSUInteger         minorModelNumber;
@property (assign, atomic, readwrite) NSUInteger         majoriOSVersion;
@property (assign, atomic, readwrite) NSUInteger         minoriOSVersion;

@end

@implementation GBDeviceDetails

-(NSString *)description {
    return [NSString stringWithFormat:@"%@\nrawSystemInfoString: %@\nmodel: %d\nfamily: %d\ndisplay: %d\nmajorModelNumber: %ld\nminorModelNumber: %ld\nmajoriOSVersion: %ld\nminoriOSVersion: %ld", [super description], self.rawSystemInfoString, self.model, self.family, self.display, (unsigned long)self.majorModelNumber, (unsigned long)self.minorModelNumber, (unsigned long)self.majoriOSVersion, (unsigned long)self.minoriOSVersion];
}

@end

@implementation GBDeviceInfo

#pragma mark - convenience

+(NSString *)rawSystemInfoString {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+(NSUInteger)majorModelNumber {
    NSString *systemInfoString = [self rawSystemInfoString];
    
    NSUInteger positionOfFirstInteger = [systemInfoString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location;
    NSUInteger positionOfComma = [systemInfoString rangeOfString:@","].location;
    
    if (positionOfComma != NSNotFound) {
        return [[systemInfoString substringWithRange:NSMakeRange(positionOfFirstInteger, positionOfComma - positionOfFirstInteger)] integerValue];
    }
    else {
        return 0;
    }
}

+(NSUInteger)minorModelNumber {
    NSString *systemInfoString = [self rawSystemInfoString];
    
    NSUInteger positionOfComma = [systemInfoString rangeOfString:@"," options:NSBackwardsSearch].location;
    
    if (positionOfComma != NSNotFound) {
        return [[systemInfoString substringFromIndex:positionOfComma + 1] integerValue];
    }
    else {
        return 0;
    }
}


#pragma mark - public API

+(GBDeviceDetails *)deviceDetails {
    GBDeviceDetails *details = [GBDeviceDetails new];
    
    NSString *systemInfoString = [self rawSystemInfoString];
    
    //system info string
    details.rawSystemInfoString = systemInfoString;
    
    //model numbers
    details.majorModelNumber = [self majorModelNumber];
    details.minorModelNumber = [self minorModelNumber];
    
    //specific device
    if ([[systemInfoString substringToIndex:6] isEqualToString:@"iPhone"]) {
        details.family = GBDeviceFamilyiPhone;
        
        if (details.majorModelNumber == 1) {
            if (details.minorModelNumber == 1) {
                details.model = GBDeviceModeliPhone;
            }
            else if (details.minorModelNumber == 2) {
                details.model = GBDeviceModeliPhone3G;
            }
            else {
                details.model = GBDeviceModelUnknown;
            }
        }
        else if (details.majorModelNumber == 2) {
            details.model = GBDeviceModeliPhone3GS;
        }
        else if (details.majorModelNumber == 3) {
            details.model = GBDeviceModeliPhone4;
        }
        else if (details.majorModelNumber == 4) {
            details.model = GBDeviceModeliPhone4S;
        }
        else if (details.majorModelNumber == 5) {
            details.model = GBDeviceModeliPhone5;
        }
        else {
            details.model = GBDeviceModelUnknown;
        }
    }
    else if ([[systemInfoString substringToIndex:4] isEqualToString:@"iPad"]) {
        details.family = GBDeviceFamilyiPad;
        
        if (details.majorModelNumber == 1) {
            details.model = GBDeviceModeliPad;
        }
        else if (details.majorModelNumber == 2) {
            if (details.minorModelNumber <= 4) {
                details.model = GBDeviceModeliPad2;
            }
            else if (details.minorModelNumber <= 7) {
                details.model = GBDeviceModeliPadMini;
            }
        }
        else if (details.majorModelNumber == 3) {
            if (details.minorModelNumber <= 3) {
                details.model = GBDeviceModeliPad3;
            }
            else if (details.minorModelNumber <= 6) {
                details.model = GBDeviceModeliPad4;
            }
            else {
                details.model = GBDeviceModelUnknown;
            }
        }
    }
    else if ([[systemInfoString substringToIndex:4] isEqualToString:@"iPod"]) {
        details.family = GBDeviceFamilyiPod;
        
        switch (details.majorModelNumber) {
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
        details.model = GBDeviceModelUnknown;
    }
    
    //display
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
    
    //iOS version
    NSArray *decomposedOSVersion = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if (decomposedOSVersion.count >= 2) {
        NSInteger majorVersion = [decomposedOSVersion[0] integerValue];
        NSInteger minorVersion = [decomposedOSVersion[1] integerValue];
        details.majoriOSVersion = majorVersion >= 0 ? (NSUInteger)majorVersion : 0;
        details.minoriOSVersion = minorVersion >= 0 ? (NSUInteger)minorVersion : 0;
    }
    
    return details;
}

@end