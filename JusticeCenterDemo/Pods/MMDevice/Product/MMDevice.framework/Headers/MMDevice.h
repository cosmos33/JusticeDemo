//
//  MMDevice.h
//  pushsdk-ios
//
//  Created by wangduanqing on 2018/12/4.
//  Copyright © 2018年 cosmos33. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * const MMPlatformName NS_EXTENSIBLE_STRING_ENUM;

extern MMPlatformName MM_IPHONE_1G_NAMESTRING; //            @"iPhone 1G"
extern MMPlatformName MM_IPHONE_3G_NAMESTRING; //            @"iPhone 3G"
extern MMPlatformName MM_IPHONE_3GS_NAMESTRING; //           @"iPhone 3GS"
extern MMPlatformName MM_IPHONE_4_NAMESTRING; //             @"iPhone 4"
extern MMPlatformName MM_IPHONE_4S_NAMESTRING; //            @"iPhone 4S"
extern MMPlatformName MM_IPHONE_5_NAMESTRING; //             @"iPhone 5"
extern MMPlatformName MM_IPHONE_5C_NAMESTRING; //            @"iPhone 5C"
extern MMPlatformName MM_IPHONE_5S_NAMESTRING; //            @"iPhone 5S"
extern MMPlatformName MM_IPHONE_6_NAMESTRING; //             @"iPhone 6"
extern MMPlatformName MM_IPHONE_6PLUS_NAMESTRING; //         @"iPhone 6 Plus"
extern MMPlatformName MM_IPHONE_6S_NAMESTRING; //            @"iPhone 6S"
extern MMPlatformName MM_IPHONE_6SPLUS_NAMESTRING; //        @"iPhone 6S Plus"
extern MMPlatformName MM_IPHONE_SE_NAMESTRING; //            @"iPhone SE"
extern MMPlatformName MM_IPHONE_7_NAMESTRING; //             @"iPhone 7"
extern MMPlatformName MM_IPHONE_7PLUS_NAMESTRING; //         @"iPhone 7 Plus"
extern MMPlatformName MM_IPHONE_8_NAMESTRING; //             @"iPhone 8"
extern MMPlatformName MM_IPHONE_8PLUS_NAMESTRING; //         @"iPhone 8 Plus"
extern MMPlatformName MM_IPHONE_X_NAMESTRING; //             @"iPhone X"
extern MMPlatformName MM_IPHONE_XS_NAMESTRING; //            @"iPhone XS"
extern MMPlatformName MM_IPHONE_XSMAX_NAMESTRING; //         @"iPhone XS Max"
extern MMPlatformName MM_IPHONE_XR_NAMESTRING; //            @"iPhone XR"
extern MMPlatformName MM_IPHONE_11_NAMESTRING; //            @"iPhone 11"
extern MMPlatformName MM_IPHONE_11PRO_NAMESTRING; //         @"iPhone 11 Pro"
extern MMPlatformName MM_IPHONE_11PROMAX_NAMESTRING; //      @"iPhone 11 Pro Max"
extern MMPlatformName MM_IPHONE_UNKNOWN_NAMESTRING; //       @"Unknown iPhone"

extern MMPlatformName MM_IPOD_1G_NAMESTRING; //              @"iPod touch 1G"
extern MMPlatformName MM_IPOD_2G_NAMESTRING; //              @"iPod touch 2G"
extern MMPlatformName MM_IPOD_3G_NAMESTRING; //              @"iPod touch 3G"
extern MMPlatformName MM_IPOD_4G_NAMESTRING; //              @"iPod touch 4G"
extern MMPlatformName MM_IPOD_5G_NAMESTRING; //              @"iPod touch 5G"
extern MMPlatformName MM_IPOD_6G_NAMESTRING; //              @"iPod touch 6G"
extern MMPlatformName MM_IPOD_UNKNOWN_NAMESTRING; //         @"Unknown iPod"

extern MMPlatformName MM_IPAD_1G_NAMESTRING; //              @"iPad 1G"
extern MMPlatformName MM_IPAD_2G_NAMESTRING; //              @"iPad 2G"
extern MMPlatformName MM_IPAD_3G_NAMESTRING; //              @"iPad 3G"
extern MMPlatformName MM_IPAD_4G_NAMESTRING; //              @"iPad 4G"
extern MMPlatformName MM_IPAD_AIR_NAMESTRING; //             @"iPad Air"
extern MMPlatformName MM_IPAD_AIR2_NAMESTRING; //            @"iPad Air 2"
extern MMPlatformName MM_IPAD_PRO9P7INCH_NAMESTRING; //      @"iPad Pro 9.7-inch"
extern MMPlatformName MM_IPAD_PRO12P9INCH_NAMESTRING; //     @"iPad Pro 12.9-inch"
extern MMPlatformName MM_IPAD_5G_NAMESTRING; //              @"iPad 5G"
extern MMPlatformName MM_IPAD_PRO10P5INCH_NAMESTRING; //     @"iPad Pro 10.5-inch"
extern MMPlatformName MM_IPAD_PRO12P9INCH2G_NAMESTRING; //   @"iPad Pro 12.9-inch 2G"
extern MMPlatformName MM_IPAD_MINI_NAMESTRING; //            @"iPad mini"
extern MMPlatformName MM_IPAD_MINI_RETINA_NAMESTRING; //     @"iPad mini Retina"
extern MMPlatformName MM_IPAD_MINI3_NAMESTRING; //           @"iPad mini 3"
extern MMPlatformName MM_IPAD_MINI4_NAMESTRING; //           @"iPad mini 4"
extern MMPlatformName MM_IPAD_UNKNOWN_NAMESTRING; //         @"Unknown iPad"

extern MMPlatformName MM_APPLETV_2G_NAMESTRING; //           @"Apple TV 2G"
extern MMPlatformName MM_APPLETV_3G_NAMESTRING; //           @"Apple TV 3G"
extern MMPlatformName MM_APPLETV_4G_NAMESTRING; //           @"Apple TV 4G"
extern MMPlatformName MM_APPLETV_4K_NAMESTRING; //           @"Apple TV 4K"
extern MMPlatformName MM_APPLETV_UNKNOWN_NAMESTRING; //      @"Unknown Apple TV"

extern MMPlatformName MM_IOS_FAMILY_UNKNOWN_DEVICE; //       @"Unknown iOS device"

extern MMPlatformName MM_IPHONE_SIMULATOR_NAMESTRING; //         @"iPhone Simulator"
extern MMPlatformName MM_IPHONE_SIMULATOR_IPHONE_NAMESTRING; //  @"iPhone Simulator"
extern MMPlatformName MM_IPHONE_SIMULATOR_IPAD_NAMESTRING; //    @"iPad Simulator"

typedef enum {
    MMDeviceUnknown,
    
    MMDeviceiPhoneSimulator,
    MMDeviceiPhoneSimulatoriPhone, // both regular and iPhone 4 devices
    MMDeviceiPhoneSimulatoriPad,
    
    MMDevice1GiPhone,
    MMDevice3GiPhone,
    MMDevice3GSiPhone,
    MMDevice4iPhone,
    MMDevice4SiPhone,
    MMDevice5iPhone,
    MMDevice5CiPhone,
    MMDevice5SiPhone,
    MMDevice6iPhone,
    MMDevice6PlusiPhone,
    MMDevice6SiPhone,
    MMDevice6SPlusiPhone,
    MMDeviceSEiPhone,
    MMDevice7iPhone,
    MMDevice7PlusiPhone,
    MMDevice8iPhone,
    MMDevice8PlusiPhone,
    MMDeviceXiPhone,
    MMDeviceXSiPhone,
    MMDeviceXSMaxiPhone,
    MMDeviceXRiPhone,
    MMDevice11iPhone,
    MMDevice11ProiPhone,
    MMDevice11ProMaxiPhone,
    
    MMDevice1GiPod,
    MMDevice2GiPod,
    MMDevice3GiPod,
    MMDevice4GiPod,
    MMDevice5GiPod,
    MMDevice6GiPod,
    
    MMDevice1GiPad,
    MMDevice2GiPad,
    MMDevice3GiPad,
    MMDevice4GiPad,
    MMDeviceAiriPad,
    MMDeviceAir2iPad,
    MMDevicePro9p7InchiPad,
    MMDevicePro12p9InchiPad,
    MMDevice5GiPad,
    MMDevicePro10p5InchiPad,
    MMDevicePro12p9Inch2GiPad,
    
    MMDeviceiPadmini,
    MMDeviceiPadminiRetina,
    MMDeviceiPadmini3,
    MMDeviceiPadmini4,
    
    MMDeviceAppleTV2,
    MMDeviceAppleTV3,
    MMDeviceAppleTV4,
    MMDeviceAppleTV4K,
    MMDeviceUnknownAppleTV,
    
    MMDeviceUnknowniPhone,
    MMDeviceUnknowniPod,
    MMDeviceUnknowniPad,
    MMDeviceIFPGA,
    
} MMDevicePlatform;

@interface MMDevice : NSObject

+ (MMPlatformName)platform;
+ (MMDevicePlatform)platformType;

+ (NSString *)hwmodel;

+ (NSUInteger)cpuFrequency;
+ (NSUInteger)busFrequency;
+ (NSUInteger)totalMemory;
+ (NSUInteger)userMemory;

+ (NSNumber *)totalDiskSpace;
+ (NSNumber *)freeDiskSpace;

+ (NSString *)macaddress;
+ (NSString *)osLanguageAndCountry;

// @param: typeSpecifier: CTL_HW identifiers
+ (NSUInteger)getSysInfo:(uint)typeSpecifier;

// 返回设备原始model name。 如 iPhone12,5
+ (NSString *)deviceName;

@end

NS_ASSUME_NONNULL_END
