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
@property (strong, atomic, readwrite) NSString           *modelString;
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
    
    //default value
    details.model = GBDeviceModelUnknown;
    details.modelString = details.rawSystemInfoString;
    
    //specific device
    if (systemInfoString.length >=6 && [[systemInfoString substringToIndex:6] isEqualToString:@"iPhone"]) {
        details.family = GBDeviceFamilyiPhone;
        
        if (details.majorModelNumber == 1) {
            if (details.minorModelNumber == 1) {
                details.model = GBDeviceModeliPhone;
                details.modelString = @"iPhone 1";
            }
            else if (details.minorModelNumber == 2) {
                details.model = GBDeviceModeliPhone3G;
                details.modelString = @"iPhone 3G";
            }
            else {
                details.model = GBDeviceModelUnknown;
                details.modelString = details.rawSystemInfoString;
            }
        }
        else if (details.majorModelNumber == 2) {
            details.model = GBDeviceModeliPhone3GS;
            details.modelString = @"iPhone 3GS";
        }
        else if (details.majorModelNumber == 3) {
            details.model = GBDeviceModeliPhone4;
            details.modelString = @"iPhone 4";
        }
        else if (details.majorModelNumber == 4) {
            details.model = GBDeviceModeliPhone4S;
            details.modelString = @"iPhone 4S";
        }
        else if (details.majorModelNumber == 5) {
            if (details.minorModelNumber <= 2) {
                details.model = GBDeviceModeliPhone5;
                details.modelString = @"iPhone 5";
            }
            else if (details.minorModelNumber <= 4) {
                details.model = GBDeviceModeliPhone5C;
                details.modelString = @"iPhone 5C";
            }
        }
        else if (details.majorModelNumber == 6) {
            details.model = GBDeviceModeliPhone5S;
            details.modelString = @"iPhone 5S";
        }
        else if (details.majorModelNumber == 7) {
            if (details.minorModelNumber == 1) {
                details.model = GBDeviceModeliPhone6Plus;
                details.modelString = @"iPhone 6 Plus";
            }
            else if (details.minorModelNumber == 2) {
                details.model = GBDeviceModeliPhone6;
                details.modelString = @"iPhone 6";
            }
        }
        else {
            details.model = GBDeviceModelUnknown;
            details.modelString = details.rawSystemInfoString;
        }
    }
    else if (systemInfoString.length >=4 && [[systemInfoString substringToIndex:4] isEqualToString:@"iPad"]) {
        details.family = GBDeviceFamilyiPad;
        
        if (details.majorModelNumber == 1) {
            details.model = GBDeviceModeliPad;
            details.modelString = @"iPad 1";
        }
        else if (details.majorModelNumber == 2) {
            if (details.minorModelNumber <= 4) {
                details.model = GBDeviceModeliPad2;
                details.modelString = @"iPad 2";
            }
            else if (details.minorModelNumber <= 7) {
                details.model = GBDeviceModeliPadMini;
                details.modelString = @"iPad Mini";
            }
        }
        else if (details.majorModelNumber == 3) {
            if (details.minorModelNumber <= 3) {
                details.model = GBDeviceModeliPad3;
                details.modelString = @"iPad 3";
            }
            else if (details.minorModelNumber <= 6) {
                details.model = GBDeviceModeliPad4;
                details.modelString = @"iPad 4";
            }
            else {
                details.model = GBDeviceModelUnknown;
                details.modelString = details.rawSystemInfoString;
            }
        }
        else if (details.majorModelNumber == 4) {
            if (details.minorModelNumber <= 2) {
                details.model = GBDeviceModeliPadAir;
                details.modelString = @"iPad Air";
            }
            else if (details.minorModelNumber >= 4 || details.minorModelNumber <= 6) {
                details.model = GBDeviceModeliPadMiniRetina;
                details.modelString = @"iPad Mini Retina";
            }
            else if (details.minorModelNumber >= 7 || details.minorModelNumber <= 9) {
                details.model = GBDeviceModeliPadMini3;
                details.modelString = @"iPad Mini 3";
            }
            else {
                details.model = GBDeviceModelUnknown;
                details.modelString = details.rawSystemInfoString;
            }
        }
        else if (details.majorModelNumber == 5){
            if (details.minoriOSVersion == 3 || details.minoriOSVersion == 4) {
                details.model = GBDeviceModeliPadAir2;
                details.modelString = @"iPad Air 2";
            }
            else {
                details.model = GBDeviceModelUnknown;
                details.modelString = details.rawSystemInfoString;
            }
        }
        else {
            details.model = GBDeviceModelUnknown;
            details.modelString = details.rawSystemInfoString;
        }
    }
    else if (systemInfoString.length >=4 && [[systemInfoString substringToIndex:4] isEqualToString:@"iPod"]) {
        details.family = GBDeviceFamilyiPod;
        
        switch (details.majorModelNumber) {
            case 1:
                details.model = GBDeviceModeliPod;
                details.modelString = @"iPod Touch 1";
                break;
                
            case 2:
                details.model = GBDeviceModeliPod2;
                details.modelString = @"iPod Touch 2";
                break;
                
            case 3:
                details.model = GBDeviceModeliPod3;
                details.modelString = @"iPod Touch 3";
                break;
                
            case 4:
                details.model = GBDeviceModeliPod4;
                details.modelString = @"iPod Touch 4";
                break;
                
            case 5:
                details.model = GBDeviceModeliPod5;
                details.modelString = @"iPod Touch 5";
                break;
                
            default:
                details.model = GBDeviceModelUnknown;
                details.modelString = details.rawSystemInfoString;
                break;
        }
    }
    else if (TARGET_IPHONE_SIMULATOR) {
        details.family = GBDeviceFamilySimulator;
        
        BOOL iPadScreen = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        details.model = iPadScreen ? GBDeviceModeliPadSimulator : GBDeviceModeliPhoneSimulator;
        details.modelString = iPadScreen ? @"iPad Simulator": @"iPhone Simulator";
    }
    else {
        details.family = GBDeviceFamilyUnknown;
        details.model = GBDeviceModelUnknown;
        details.modelString = @"Unknown Device";
    }
    
    //display
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // iPad
    if (((screenWidth == 768) && (screenHeight == 1024)) ||
        ((screenWidth == 1024) && (screenHeight == 768))) {
        details.display = GBDeviceDisplayiPad;
    }
    // iPhone 3.5 inch
    else if (((screenWidth == 320) && (screenHeight == 480)) ||
             ((screenWidth == 480) && (screenHeight == 320))) {
        details.display = GBDeviceDisplayiPhone35Inch;
    }
    // iPhone 4 inch
    else if (((screenWidth == 320) && (screenHeight == 568)) ||
             ((screenWidth == 568) && (screenHeight == 320))) {
        details.display = GBDeviceDisplayiPhone4Inch;
    }
    // iPhone 4.7 inch
    else if (((screenWidth == 375) && (screenHeight == 667)) ||
             ((screenWidth == 667) && (screenHeight == 375))) {
        details.display = GBDeviceDisplayiPhone47Inch;
    }
    // iPhone 5.5 inch
    else if (((screenWidth == 414) && (screenHeight == 736)) ||
             ((screenWidth == 736) && (screenHeight == 414))) {
        details.display = GBDeviceDisplayiPhone55Inch;
    }
    // unknown
    else {
        details.display = GBDeviceDisplayUnknown;
    }
    
    // iOS version
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
