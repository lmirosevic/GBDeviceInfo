GBDeviceInfo
============

Detects the hardware, software and display of the current iOS device at runtime.

Usage
------------

First get a struct with the hardware info.

```objective-c
GBDeviceDetails deviceDetails = [GBDeviceInfo deviceDetails];
```

To get the model numbers. e.g. when running on an iPhone 4S

```objective-c
//Model numbers
NSLog(@"Big model number: %d", deviceDetails.bigModel);                 //Big model number: 4
NSLog(@"Small model number: %d", deviceDetails.smallModel);             //Small model number: 1

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
	NSLog(@"It has an iPhone 3.5 inch display");						//It has an iPhone 3.5 inch display
}

//iOS Version
if (deviceDetails.iOSVersion >= 6) {
	NSLog(@"It's running at least iOS 6");								//It's running at least iOS 6
}

//Raw systemInfo string
NSLog(@"systemInfo string: %@", [GBDeviceInfo rawSystemInfoString]);    //systemInfo string: iPhone4,1
```

Don't forget to import header.

```objective-c
#import "GBDeviceInfo.h"
```

GBDeviceDetails definition:

```objective-c
typedef struct {
    GBDeviceModel           model;
    GBDeviceFamily          family;
    GBDeviceDisplay         display;
    NSUInteger              bigModel;
    NSUInteger              smallModel;
    NSUInteger              iOSVersion;
} GBDeviceDetails;
```

Device support
------------

* iPhone
* iPhone3G
* iPhone3GS
* iPhone4
* iPhone4S
* iPhone5
* iPad
* iPad2
* iPad3
* iPad4
* iPadMini
* iPod
* iPod2
* iPod3
* iPod4
* iPod5

Copyright & License
------------

Copyright 2012 Luka Mirosevic

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.