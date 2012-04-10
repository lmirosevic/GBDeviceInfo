Detects the hardware of the current iOS device.

Use:
    GBDeviceDetails deviceDetails = [GBDeviceInfo currentInfo].deviceDetails;

where deviceDetails is a C struct:

typedef struct {
    GBDeviceSpecificModel specificModel;
    GBDeviceModelFamily modelFamily;
    NSUInteger bigModel;
    NSUInteger smallModel;
} GBDeviceDetails;

Currently knows about:
    iPhone,
    iPhone3G,
    iPhone3GS,
    iPhone4,
    iPhone4S,
    iPad,
    iPad2,
    iPad3,
    iPod,
    iPod2,
    iPod3,
    iPod4,