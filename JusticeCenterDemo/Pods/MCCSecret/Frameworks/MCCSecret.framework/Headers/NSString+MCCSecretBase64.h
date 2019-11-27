//
//  NSString+MoPushBase64.h
//  Gurpartap Singh
//
//  Created by Gurpartap Singh on 06/05/12.
//  Copyright (c) 2012 Gurpartap Singh. All rights reserved.
//

#import <Foundation/NSString.h>

@interface NSString (MCCSecretPushBase64Additions)

+ (NSString *)mcc_base64StringFromData:(NSData *)data length:(NSUInteger)length;
+ (NSString *)mcc_stringWithFromDict:(NSDictionary *)dict;
- (BOOL)mcc_recordIsIPAddress;
@end
