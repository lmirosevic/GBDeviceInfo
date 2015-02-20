# GBDeviceInfo ![Version](https://img.shields.io/cocoapods/v/GBDeviceInfo.svg?style=flat)&nbsp;![License](https://img.shields.io/badge/license-Apache_2-green.svg?style=flat)

Detects the hardware, software and display of the current iOS or Mac OS X device at runtime.

iOS
------------

Simple usage (examples on iPhone 6 running iOS 8.1.3):

```objective-c
[GBDeviceInfo deviceInfo].modelString;                              //Returns: @"iPhone 6"
[GBDeviceInfo deviceInfo].model == GBDeviceModeliPhone6;            //Returns: YES
[GBDeviceInfo deviceInfo].family == GBDeviceFamilyiPad;             //Returns: NO
[GBDeviceInfo deviceInfo].osVersion.major;                          //Returns: 8
[GBDeviceInfo deviceInfo].osVersion.minor;                          //Returns: 1

```

You can also reuse the returned object (this used to be a c struct in previous versions) to save some typing. First assign the object to some variable:

```objective-c
GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];
```

Then get whatever you like from the object:

```objective-c
//Model numbers
NSLog(@"Major device ver: %d", deviceInfo.deviceVersion.major);     //Major device ver: 7
NSLog(@"Major device ver: %d", deviceInfo.deviceVersion.minor);     //Minor device ver: 2


//Specific model
if (deviceInfo.model == GBDeviceModeliPhone6) {
    NSLog(@"It's a 4S");                                            //It's a 4S
}

//Family of device
if (deviceInfo.family != GBDeviceFamilyiPad) {
    NSLog(@"It's not an iPad");                                     //It's not an iPad
}

//Screen type
if (deviceInfo.display == GBDeviceDisplayiPhone47Inch) {
    NSLog(@"It has an iPhone 4.7 inch display");                    //It has an iPhone 4.7 inch display
}

//iOS Version
if (deviceInfo.majoriOSVersion >= 6) {
    NSLog(@"It's running at least iOS 6");                          //It's running at least iOS 6
}

//Raw systemInfo string
NSLog(@"systemInfo string: %@", deviceInfo.rawSystemInfoString);    //systemInfo string: iPhone7,2
```

Don't forget to import header.

```objective-c
#import <GBDeviceInfo/GBDeviceInfo.h>"
```

GBDeviceInfo object definition:

```objective-c
/**
 The raw system info string, e.g. "iPhone7,2".
 */
@property (strong, atomic, readonly) NSString           *rawSystemInfoString;

/**
 The device version. e.g. {7, 2}.
 */
@property (assign, atomic, readonly) GBDeviceVersion    deviceVersion;

/**
 The human readable name for the device, e.g. "iPhone 6".
 */
@property (strong, atomic, readonly) NSString           *modelString;

/**
 The device family. e.g. GBDeviceFamilyiPhone.
 */
@property (assign, atomic, readonly) GBDeviceFamily     family;

/**
 The specific device model, e.g. GBDeviceModeliPhone6.
 */
@property (assign, atomic, readonly) GBDeviceModel      model;

/**
 The display identifier, e.g. GBDeviceDisplayiPhone47Inch
 */
@property (assign, atomic, readonly) GBDeviceDisplay    display;

/**
 Information about the CPU.
 */
@property (assign, atomic, readonly) GBCPUInfo          cpuInfo;

/**
 Amount of physical memory (RAM) available to the system, in GB.
 */
@property (assign, atomic, readonly) CGFloat            physicalMemory;         // GB (gibi)

/**
 Information about the system's OS. e.g. {10, 8, 2}.
 */
@property (assign, atomic, readonly) GBOSVersion        osVersion;
```

OS X
------------

Simple usage (examples on a Mac Pro with an Ivy Bridge 3770K processor running 10.8.2):

```objective-c
[GBDeviceInfo deviceInfo].osVersion.major;                           //Returns: 10
[GBDeviceInfo deviceInfo].osVersion.minor;                           //Returns: 8
[GBDeviceInfo deviceInfo].family == GBDeviceFamilyMacPro;            //Returns: YES
[GBDeviceInfo deviceInfo].isMacAppStoreAvailable;                    //Returns: YES
[GBDeviceInfo deviceInfo].isIAPAvailable;                            //Returns: YES
```

You can also reuse the returned object to save some typing. First assign the object to some variable:

```objective-c
GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];
```

Then get whatever you like from the object:

```objective-c
GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];

//OS X Version
if (deviceInfo.majorOSVersion >= 8) {
    NSLog(@"It's running at least OS X 10.8 (Mountain Lion)");     //It's running at least OS X 10.8 (Mountain Lion)
}
if (deviceInfo.minorOSVersion == 2) {
    NSLog(@"Must be running 10.x.2");                              //Must be running 10.x.2
}

//App Store stuff
if (deviceInfo.isMacAppStoreAvailable) {
    NSLog(@"App store is available.");                             //App store is available
}
if (deviceInfo.isIAPAvailable) {
    NSLog(@"...and so are IAPs");                                  //...and so are IAPs
}

//Hardware stuff
NSLog(@"SystemInfo string: %@", deviceInfo.rawSystemInfoString);   //SystemInfo string: MacPro3,1
NSLog(@"Major device ver: %d", deviceInfo.deviceVersion.major);    //Major device ver: 3
NSLog(@"Minor device ver: %d", deviceInfo.deviceVersion.minor);    //Minor device ver: 3
NSLog(@"Network name: %@", deviceInfo.nodeName);                   //Network name: MyMac.local
NSLog(@"RAM: %.3f GB", deviceInfo.physicalMemory);                 //RAM: 16.000 GB
NSLog(@"CPU frequency: %.3f GHz", deviceInfo.cpu.frequency);       //CPU frequency: 3.500 GHz
NSLog(@"Number of cores: %d", deviceInfo.cpu.numberOfCores);       //Number of cores: 8
NSLog(@"L2 Cache size: %.0f KB", deviceInfo.cpu.l2CacheSize);      //L2 Cache size: 256 KB

//Endianness
if (deviceInfo.byteOrder == GBByteOrderLittleEndian) {
    NSLog(@"Our machine is Litte Endian");                         //Our machine is Little Endian
}

//Family of device
if (deviceInfo.family != GBDeviceFamilyMacBookAir) {
    NSLog(@"It's not a Macbook air");                              //It's not a Macbook air
}

//Screen resolution
if (deviceInfo.screenResolution.width == 1920 && deviceInfo.screenResolution.height == 1200) {
    NSLog(@"It has a resolution of 1920x1200");                    //It has a resolution of 1920x1200
}
```

Don't forget to import framework:

```objective-c
#import <GBDeviceInfo/GBDeviceInfo.h>
```

GBDeviceInfo object definition:

```objective-c
/**
 The raw system info string, e.g. "iMac13,2".
 */
@property (strong, atomic, readonly) NSString           *rawSystemInfoString;

/**
 The node name on the network, e.g. "MyMachine.local".
 */
@property (strong, atomic, readonly) NSString           *nodeName;

/**
 The device family. e.g. GBDeviceFamilyiMac.
 */
@property (assign, atomic, readonly) GBDeviceFamily     family;

/**
 The device version. e.g. {13, 2}.
 */
@property (assign, atomic, readonly) GBDeviceVersion    deviceVersion;

/**
 Information about the CPU.
 */
@property (assign, atomic, readonly) GBCPUInfo          cpuInfo;

/**
 Amount of physical memory (RAM) available to the system, in GB.
 */
@property (assign, atomic, readonly) CGFloat            physicalMemory;         // GB (gibi)

/**
 System byte order, e.g. GBByteOrderLittleEndian.
 */
@property (assign, atomic, readonly) GBByteOrder        systemByteOrder;

/**
 Information about the display.
 */
@property (assign, atomic, readonly) GBDisplayInfo      displayInfo;

/**
 Information about the system's OS. e.g. {10, 8, 2}.
 */
@property (assign, atomic, readonly) GBOSVersion        osVersion;

/**
 Indicates whether the app store is available on this machine.
 */
@property (assign, atomic, readonly) BOOL               isMacAppStoreAvailable; //YES if OSX >= 10.6.6

/**
 Indicates whether IAP is available on this machine.
 */
@property (assign, atomic, readonly) BOOL               isIAPAvailable;         //YES if OSX >= 10.7
```

iOS Device support
------------

* iPhone1
* iPhone3G
* iPhone3GS
* iPhone4
* iPhone4S
* iPhone5
* iPhone5C
* iPhone5S
* iPhone6
* iPhone6Plus
* iPad1
* iPad2
* iPad3
* iPad4
* iPadMini1
* iPadMini2
* iPadMini3
* iPadAir1
* iPadAir2
* iPod1
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

*February 2015 update*
* Backwards incompatible API changes (bumped major version to 3.x.x)
* Big refactor and cleanup of the public interface
* Internal logic is much cleaner and easier for future maintenance
* Better documentation
* Fixed all known bugs
* Replaced some deprecated API calls, with fallbacks
* Consolidated related values into structs

*November 2013 update*
* Added new devices: iPhone 5C, iPhone5S, iPad Mini Retina, iPad Air

*June 2013 update*
* iOS version now has support for simulator detection
* iOS version can now return a human readable string for the device, e.g. "iPhone 4S"

*May 2013 update*
* OSX version now has methods for checking whether the App Store and/or IAP are available on the machine

*March 2013 update*
* iOS version now returns an object instead of a struct, so you should declare your variables as `GBDeviceInfo *deviceInfo` instead of the old static way `GBDeviceInfo deviceInfo`
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

Copyright 2015 Goonbee

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
