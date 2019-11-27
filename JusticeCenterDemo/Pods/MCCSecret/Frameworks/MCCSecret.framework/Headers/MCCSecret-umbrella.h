#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MCCSecretAESCrypt.h"
#import "MCCSecretRSA.h"
#import "NSData+MCCSecretBase64.h"
#import "NSData+MCCSecretCommonCrypto.h"
#import "NSString+MCCSecretBase64.h"

FOUNDATION_EXPORT double MCCSecretVersionNumber;
FOUNDATION_EXPORT const unsigned char MCCSecretVersionString[];

