![GBDeviceInfo logo](https://raw.githubusercontent.com/lmirosevic/GBDeviceInfo/master/logo.png)

Detects the hardware, software and display of the current iOS or Mac OS X device at runtime.

![Version](https://img.shields.io/cocoapods/v/GBDeviceInfo.svg?style=flat)&nbsp;![License](https://img.shields.io/badge/license-Apache_2-green.svg?style=flat)

iOS
------------

Simple usage (examples on iPhone 6 running iOS 8.1.3):

```objective-c
[[GBDeviceInfo deviceInfo] isOperatingSystemAtLeastVersion:@"8.0"]; // #> YES

[GBDeviceInfo deviceInfo].isJailbroken;                             // #> NO

[GBDeviceInfo deviceInfo].model;                                    // #> GBDeviceModeliPhone6
[GBDeviceInfo deviceInfo].family;                                   // #> GBDeviceFamilyiPad

[GBDeviceInfo deviceInfo].modelString;                              // #> @"iPhone 6"
[GBDeviceInfo deviceInfo].osVersion.major;                          // #> 8
[GBDeviceInfo deviceInfo].osVersion.minor;                          // #> 1

[GBDeviceInfo deviceInfo].displayInfo.pixelsPerInch;                // #> 326
```

You can also reuse the returned object to save some typing. First assign the object to some variable:

```objective-c
GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];
```

Then get whatever you like from the object:

```objective-c
//Model numbers
NSLog(@"Major device ver: %d", deviceInfo.deviceVersion.major);     // Major device ver: 7
NSLog(@"Major device ver: %d", deviceInfo.deviceVersion.minor);     // Minor device ver: 2


//Specific model
if (deviceInfo.model == GBDeviceModeliPhone6) {
    NSLog(@"It's a 6");                                             // It's a 6
}

//Family of device
if (deviceInfo.family != GBDeviceFamilyiPad) {
    NSLog(@"It's not an iPad");                                     // It's not an iPad
}

//Screen type
if (deviceInfo.display == GBDeviceDisplayiPhone47Inch) {
    NSLog(@"4.7 Inch display");                                     // 4.7 Inch display
}

//iOS Version
if (deviceInfo.majoriOSVersion >= 6) {
    NSLog(@"We've got iOS 6+");                                     // We've got iOS 6+
}

//Raw systemInfo string
NSLog(@"systemInfo: %@", deviceInfo.rawSystemInfoString);           // systemInfo: iPhone7,2
```

Don't forget to import header.

```objective-c
#import <GBDeviceInfo/GBDeviceInfo.h>
```

If you want to use the `isJailbroken` property, make sure you first add the Jailbreak subspec to your project's Podfile, e.g.:
```ruby
pod 'GBDeviceInfo', '~> 3.5'
pod 'GBDeviceInfo/Jailbreak', '~> 3.5'
```

Missing a property you need? Submit a Pull Request or contact [sales@goonbee.com](mailto:sales@goonbee.com?subject=GBDeviceInfo%20Enterprise)!

OS X
------------

Simple usage (examples on a Mac Pro with an Ivy Bridge 3770K processor running 10.8.2):

```objective-c
[[GBDeviceInfo deviceInfo] isOperatingSystemAtLeastVersion:@"10.8"]; // #> YES

[GBDeviceInfo deviceInfo].osVersion.major;                           // #> 10
[GBDeviceInfo deviceInfo].osVersion.minor;                           // #> 8
[GBDeviceInfo deviceInfo].family == GBDeviceFamilyMacPro;            // #> YES
[GBDeviceInfo deviceInfo].isMacAppStoreAvailable;                    // #> YES
[GBDeviceInfo deviceInfo].isIAPAvailable;                            // #> YES
```

You can also reuse the returned object to save some typing. First assign the object to some variable:

```objective-c
GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];
```

Then get whatever you like from the object:

```objective-c
GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];

//OS X Version
if (deviceInfo.osVersion.minor >= 8) {
    NSLog(@"It's OS X 10.8+ (Mountain Lion)");                     // It's OS X 10.8+ (Mountain Lion)
}
if (deviceInfo.osVersion.patch == 2) {
    NSLog(@"Must be running x.x.2");                               // Must be running x.x.2
}

//App Store stuff
if (deviceInfo.isMacAppStoreAvailable) {
    NSLog(@"App store is available.");                             // App store is available
}
if (deviceInfo.isIAPAvailable) {
    NSLog(@"...and so are IAPs");                                  // ...and so are IAPs
}

//Hardware stuff
NSLog(@"SystemInfo: %@", deviceInfo.rawSystemInfoString);          // SystemInfo: MacPro3,1
NSLog(@"Major device ver: %d", deviceInfo.deviceVersion.major);    // Major device ver: 3
NSLog(@"Minor device ver: %d", deviceInfo.deviceVersion.minor);    // Minor device ver: 1
NSLog(@"Node name: %@", deviceInfo.nodeName);                      // Node name: MyMac.local
NSLog(@"RAM: %.3f GB", deviceInfo.physicalMemory);                 // RAM: 16.000 GB
NSLog(@"CPU freq: %.3f GHz", deviceInfo.cpu.frequency);            // CPU freq: 3.500 GHz
NSLog(@"Number of cores: %d", deviceInfo.cpu.numberOfCores);       // Number of cores: 8
NSLog(@"L2 Cache size: %.0f KB", deviceInfo.cpu.l2CacheSize);      // L2 Cache size: 256 KB

//Endianness
if (deviceInfo.byteOrder == GBByteOrderLittleEndian) {
    NSLog(@"Little Endian");                                       // Little Endian
}

//Family of device
if (deviceInfo.family != GBDeviceFamilyMacBookAir) {
    NSLog(@"It's not a Macbook Air");                              // It's not a Macbook Air
}

//Screen resolution
if (deviceInfo.screenResolution.width == 1920 && deviceInfo.screenResolution.height == 1200) {
    NSLog(@"Resolution: 1920x1200");                              // Resolution: 1920x1200
}
```

Don't forget to import framework:

```objective-c
#import <GBDeviceInfo/GBDeviceInfo.h>
```

Missing a property you need? Submit a Pull Request or contact [sales@goonbee.com](mailto:sales@goonbee.com?subject=GBDeviceInfo%20Enterprise)!

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
* iPhone6S
* iPhone6SPlus
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

Author
------------

[Luka Mirosevic](mailto:luka@goonbee.com) ([@lmirosevic](https://twitter.com/lmirosevic))

Enterprise
------------

Premium support, integration, use-case adaptations and consulting available. Contact [sales@goonbee.com](mailto:sales@goonbee.com?subject=GBDeviceInfo%20Enterprise).

Copyright & License
------------

Copyright 2015 Goonbee

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
