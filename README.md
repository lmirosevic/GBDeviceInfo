GBDeviceInfo
============

Detects the hardware of the current iOS device.

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