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
NSLog(@"Small model number: %d", deviceDetails.smallModel);             //SMall model number: 1

//Specific model
if (deviceDetails.model == GBDeviceModeliPhone4S) {
    NSLog(@"It's a 4S");                                                //It's a 4S
}

//Family of device
if (deviceDetails.family != GBDeviceFamilyiPad) {
    NSLog(@"It's not an iPad");                                         //It's not an iPad
}

//Raw systemInfo string
NSLog(@"systemInfo string: %@", [GBDeviceInfo rawSystemInfoString]);    //systemInfo string: iPhone4,1
```

Don't forget to import header;

```objective-c
#import "GBDeviceInfo.h"
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

* iPod
* iPod2
* iPod3
* iPod4
* iPod5