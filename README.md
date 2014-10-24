# GBDeviceInfo ![Version](https://img.shields.io/cocoapods/v/GBDeviceInfo.svg?style=flat)&nbsp;![License](https://img.shields.io/badge/license-Apache_2-green.svg?style=flat)

Detects the hardware, software and display of the current iOS or Mac OS X device at runtime.

Usage: iOS
------------

Simple usage (examples on iPhone 4S running iOS 6.0):

```objective-c
[GBDeviceInfo deviceDetails].majorModelNumber;                          //Returns: 4
[GBDeviceInfo deviceDetails].majoriOSVersion;                           //Returns: 6
[GBDeviceInfo deviceDetails].model == GBDeviceModeliPhone4S;            //Returns: YES
[GBDeviceInfo deviceDetails].family == GBDeviceFamilyiPad;              //Returns: NO
```

You can also reuse the returned object (this used to be a c struct in previous versions) to save some typing. First assign the object to some variable:

```objective-c
GBDeviceDetails *deviceDetails = [GBDeviceInfo deviceDetails];
```

Then get whatever you like from the object:

```objective-c
//Model numbers
NSLog(@"Major model number: %d", deviceDetails.majorModelNumber);       //Major model number: 4
NSLog(@"Minor model number: %d", deviceDetails.minorModelNumber);       //Minor model number: 1

//Specific model
if (deviceDetails.model == GBDeviceModeliPhone4S) {
    NSLog(@"It's a 4S");                                                //It's a 4S
}

//Family of device
if (deviceDetails.family != GBDeviceFamilyiPad) {
    NSLog(@"It's not an iPad");                                         //It's not an iPad
}

//Screen type
if (deviceDetails.display == GBDeviceDisplayiPhone35Inch) {
    NSLog(@"It has an iPhone 3.5 inch display");                        //It has an iPhone 3.5 inch display
}

//iOS Version
if (deviceDetails.majoriOSVersion >= 6) {
    NSLog(@"It's running at least iOS 6");                              //It's running at least iOS 6
}

//Raw systemInfo string
NSLog(@"systemInfo string: %@", deviceDetails.rawSystemInfoString);     //systemInfo string: iPhone4,1
```

Don't forget to import header.

```objective-c
#import "GBDeviceInfo.h"
```

GBDeviceDetails object definition:

```objective-c
@interface GBDeviceDetails : NSObject

@property (strong, atomic, readonly) NSString           *rawSystemInfoString;
@property (strong, atomic, readonly) NSString           *modelString;
@property (assign, atomic, readonly) GBDeviceModel      model;
@property (assign, atomic, readonly) GBDeviceFamily     family;
@property (assign, atomic, readonly) GBDeviceDisplay    display;
@property (assign, atomic, readonly) NSUInteger         majorModelNumber;
@property (assign, atomic, readonly) NSUInteger         minorModelNumber;
@property (assign, atomic, readonly) NSUInteger         majoriOSVersion;
@property (assign, atomic, readonly) NSUInteger         minoriOSVersion;

@end
```

Usage: OS X
------------

Simple usage (examples on a Mac Pro with an Ivy Bridge 3770K processor running 10.8.2):

```objective-c
[GBDeviceInfo deviceDetails].majorOSVersion;                            //Returns: 8
[GBDeviceInfo deviceDetails].minorOSVersion;                            //Returns: 2
[GBDeviceInfo deviceDetails].family == GBDeviceFamilyMacPro;            //Returns: YES
[GBDeviceInfo deviceDetails].isMacAppStoreAvailable;                    //Returns: YES
[GBDeviceInfo deviceDetails].isIAPAvailable;                            //Returns: YES
```

You can also reuse the returned object to save some typing. First assign the object to some variable:

```objective-c
GBDeviceDetails *deviceDetails = [GBDeviceInfo deviceDetails];
```

Then get whatever you like from the object:

```objective-c
GBDeviceDetails *deviceDetails = [GBDeviceInfo deviceDetails];

//OS X Version
if (deviceDetails.majorOSVersion >= 8) {
    NSLog(@"It's running at least OS X 10.8 (Mountain Lion)");          //It's running at least OS X 10.8 (Mountain Lion)
}
if (deviceDetails.minorOSVersion == 2) {
    NSLog(@"Must be running 10.x.2");                                   //Must be running 10.x.2
}

//App Store stuff
if (deviceDetails.isMacAppStoreAvailable) {
    NSLog(@"App store is available.");                                  //App store is available
}
if (deviceDetails.isIAPAvailable) {
    NSLog(@"...and so are IAPs");                                       //...and so are IAPs
}

//Hardware stuff
NSLog(@"SystemInfo string: %@", deviceDetails.rawSystemInfoString);     //SystemInfo string: MacPro3,1
NSLog(@"Major model number: %d", deviceDetails.majorModelNumber);       //Major model number: 3
NSLog(@"Minor model number: %d", deviceDetails.minorModelNumber);       //Minor model number: 1
NSLog(@"Network name: %@", deviceDetails.nodeName);                     //Network name: MyMac.local
NSLog(@"RAM: %.3f GB", deviceDetails.physicalMemory);                   //RAM: 16.000 GB
NSLog(@"CPU frequency: %.3f GHz", deviceDetails.cpuFrequency);          //CPU frequency: 3.262 GHz
NSLog(@"Number of cores: %d", deviceDetails.numberOfCores);             //Number of cores: 8
NSLog(@"L2 Cache size: %.0f KB", deviceDetails.l2CacheSize);            //L2 Cache size: 256 KB

//Endianness
if (deviceDetails.byteOrder == GBByteOrderLittleEndian) {
    NSLog(@"Our machine is Litte Endian");                              //Our machine is Little Endian
}

//Family of device
if (deviceDetails.family != GBDeviceFamilyMacBookAir) {
    NSLog(@"It's not a Macbook air");                                   //It's not a Macbook air
}

//Screen resolution
if (deviceDetails.screenResolution.width == 1920 && deviceDetails.screenResolution.height == 1200) {
    NSLog(@"It has a resolution of 1920x1200");                         //It has a resolution of 1920x1200
}
```

Don't forget to import framework:

```objective-c
#import <GBDeviceInfo/GBDeviceInfo.h>
```

GBDeviceDetails object definition:

```objective-c
@interface GBDeviceDetails : NSObject

@property (strong, atomic, readonly) NSString           *rawSystemInfoString;
@property (strong, atomic, readonly) NSString           *nodeName;
@property (assign, atomic, readonly) GBDeviceFamily     family;
@property (assign, atomic, readonly) NSUInteger         majorModelNumber;
@property (assign, atomic, readonly) NSUInteger         minorModelNumber;
@property (assign, atomic, readonly) CGFloat            physicalMemory;         // GB
@property (assign, atomic, readonly) CGFloat            cpuFrequency;           // GHz
@property (assign, atomic, readonly) NSUInteger         numberOfCores;
@property (assign, atomic, readonly) CGFloat            l2CacheSize;            // KB
@property (assign, atomic, readonly) GBByteOrder        byteOrder;
@property (assign, atomic, readonly) CGSize             screenResolution;
@property (assign, atomic, readonly) NSUInteger         majorOSVersion;
@property (assign, atomic, readonly) NSUInteger         minorOSVersion;
@property (assign, atomic, readonly) BOOL               isMacAppStoreAvailable; //YES if OSX >= 10.6.6
@property (assign, atomic, readonly) BOOL               isIAPAvailable;         //YES if OSX >= 10.7

@end
```

iOS Device support
------------

* iPhone
* iPhone3G
* iPhone3GS
* iPhone4
* iPhone4S
* iPhone5
* iPhone5C
* iPhone5S
* iPhone6
* iPhone6Plus
* iPad
* iPad2
* iPad3
* iPad4
* iPadMini
* iPadMiniRetina
* iPadMini3
* iPadAir
* iPadAir2
* iPod
* iPod2
* iPod3
* iPod4
* iPod5
* iPhone Simulator
* iPad Simulator

OS X Device family support
------------

* iMac
* MacMini
* MacPro
* MacBook
* MacBookAir
* MacBookPro
* Xserve

Changelog
------------

*November 2013 update*
* Added new devices: iPhone 5C, iPhone5S, iPad Mini Retina, iPad Air

*June 2013 update*
* iOS version now has support for simulator detection
* iOS version can now return a human readable string for the device, e.g. "iPhone 4S"

*May 2013 update*
* OSX version now has methods for checking whether the App Store and/or IAP are available on the machine

*March 2013 update*

* iOS version now returns an object instead of a struct, so you should declare your variables as `GBDeviceDetails *deviceDetails` instead of the old static way `GBDeviceDetails deviceDetails`
* Some properties in iOS lib have been renamed:
  * `iOSVersion` -> `majoriOSVersion`
  * `bigModelNumber` -> `majorModelNumber`
  * `smallModelNumber` -> `minorModelNumber`
* New properties have been added in iOS lib:
  * `minoriOSVersion`
  * `rawSystemInfoString`
* `rawSystemInfoString` method has been removed (you get the same string from the returned object now)

Copyright & License
------------

Copyright 2013 Luka Mirosevic

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
