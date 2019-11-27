//
//  NSDictionary+MMJSafe.h
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (MMJSafe)

- (id)mmj_objectForKey:(NSString *)aKey defaultValue:(id)value;
- (NSString *)mmj_stringForKey:(NSString *)aKey defaultValue:(NSString *)value;
- (NSArray *)mmj_arrayForKey:(NSString *)aKey defaultValue:(NSArray *)value;
- (NSDictionary *)mmj_dictionaryForKey:(NSString *)aKey defaultValue:(NSDictionary *)value;
- (NSData *)mmj_dataForKey:(NSString *)aKey defaultValue:(NSData *)value;
- (NSUInteger)mmj_unsignedIntegerForKey:(NSString *)aKey defaultValue:(NSUInteger)value;
- (NSInteger)mmj_integerForKey:(NSString *)aKey defaultValue:(NSInteger)value;
- (float)mmj_floatForKey:(NSString *)aKey defaultValue:(float)value;
- (double)mmj_doubleForKey:(NSString *)aKey defaultValue:(double)value;
- (long long)mmj_longLongValueForKey:(NSString *)aKey defaultValue:(long long)value;
- (BOOL)mmj_boolForKey:(NSString *)aKey defaultValue:(BOOL)value;
- (NSDate *)mmj_dateForKey:(NSString *)aKey defaultValue:(NSDate *)value;
- (NSNumber *)mmj_numberForKey:(NSString *)aKey defaultValue:(NSNumber *)value;
- (int)mmj_intForKey:(NSString *)aKey defaultValue:(int)value;

@end

NS_ASSUME_NONNULL_END
