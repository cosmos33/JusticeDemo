//
//  NSDictionary+MMJSafe.m
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

#import "NSDictionary+MMJSafe.h"

@implementation NSDictionary (MMJSafe)

#pragma mark - Wrap for objectForKey:aKey
- (id)mmj_objectForKey:(NSString *)aKey defaultValue:(id)value
{
    id obj = [self objectForKey:aKey];
    return (obj && obj != [NSNull null]) ? obj : value;
}

- (void)mmj_printCurrentCallStack
{
    NSArray *callArray = [NSThread callStackSymbols];
    NSLog(@"\n -----------------------------------------call stack----------------------------------------------\n");
    for (NSString *string in callArray) {
        NSLog(@"  %@  ", string);
    }
    NSLog(@"\n -------------------------------------------------------------------------------------------------\n");
}

// [[NSNull null] isKindOfClass:[NSString class]] 不会崩溃，调用结果是返回0
- (NSString *)mmj_stringForKey:(NSString *)aKey defaultValue:(NSString *)value
{
    id obj = [self mmj_objectForKey:aKey defaultValue:value];
    if ([obj isKindOfClass:[NSNumber class]]) {
         obj = [(NSNumber *)obj stringValue];
     }
    if (![obj isKindOfClass:[NSString class]]) {
        #if DEBUG
        if (obj) {
            NSLog(@"Error, %s obj is not kind of Class NSString, The key is:%@", __func__, aKey);
            [self mmj_printCurrentCallStack];
            
            NSString *reason = [NSString stringWithFormat:@"The key is %@, the value is :%@", aKey, value];
            NSException *exception = [NSException exceptionWithName:@"IllegalType" reason:reason userInfo:(NSDictionary *)self];
            @throw exception;
        }
        #endif
        return value;
    }
    
    return (NSString *)obj;
}

- (NSArray *)mmj_arrayForKey:(NSString *)aKey defaultValue:(NSArray *)value
{
    id obj = [self mmj_objectForKey:aKey defaultValue:value];
    if (![obj isKindOfClass:[NSArray class]]) {
       #if DEBUG
        if (obj) {
            NSLog(@"Error, %s obj is not kind of Class NSArray, The key is:%@", __func__, aKey);
            [self mmj_printCurrentCallStack];
            
            NSString *reason = [NSString stringWithFormat:@"The key is %@, the value is :%@", aKey, value];
            NSException *exception = [NSException exceptionWithName:@"IllegalType" reason:reason userInfo:(NSDictionary *)self];
            @throw exception;
        }
        #endif
        return value;
    }
    
    return (NSArray *)obj;
}

- (NSDictionary *)mmj_dictionaryForKey:(NSString *)aKey defaultValue:(NSDictionary *)value
{
    id obj = [self mmj_objectForKey:aKey defaultValue:value];
    if (![obj isKindOfClass:[NSDictionary class]]) {
        #if DEBUG
        if (obj) {
            NSLog(@"Error, %s obj is not kind of Class NSDictionary, The key is:%@", __func__, aKey);
            [self mmj_printCurrentCallStack];
            
            NSString *reason = [NSString stringWithFormat:@"The key is %@, the value is :%@", aKey, value];
            NSException *exception = [NSException exceptionWithName:@"IllegalType" reason:reason userInfo:(NSDictionary *)self];
            @throw exception;
        }
        #endif
        return value;
    }
    
    return (NSDictionary *)obj;
}

- (NSData *)mmj_dataForKey:(NSString *)aKey defaultValue:(NSData *)value
{
    id obj = [self mmj_objectForKey:aKey defaultValue:value];
    if (![obj isKindOfClass:[NSData class]]) {
         #if DEBUG
        if (obj) {
            NSLog(@"Error, %s obj is not kind of Class NSData, The key is:%@", __func__, aKey);
            [self mmj_printCurrentCallStack];
            
            NSString *reason = [NSString stringWithFormat:@"The key is %@, the value is :%@", aKey, value];
            NSException *exception = [NSException exceptionWithName:@"IllegalType" reason:reason userInfo:(NSDictionary *)self];
            @throw exception;
        }
        #endif
        return value;
    }
    
    return (NSData *)obj;
}

- (NSDate *)mmj_dateForKey:(NSString *)aKey defaultValue:(NSDate *)value
{
    id obj = [self mmj_objectForKey:aKey defaultValue:value];
    if (![obj isKindOfClass:[NSDate class]]) {
         #if DEBUG
        if (obj) {
            NSLog(@"Error, %s obj is not kind of Class NSDate, The key is:%@", __func__, aKey);
            [self mmj_printCurrentCallStack];
            
            NSString *reason = [NSString stringWithFormat:@"The key is %@, the value is :%@", aKey, value];
            NSException *exception = [NSException exceptionWithName:@"IllegalType" reason:reason userInfo:(NSDictionary *)self];
            @throw exception;
        }
        #endif
        return value;
    }
    
    return (NSDate *)obj;
}

- (NSNumber *)mmj_numberForKey:(NSString *)aKey defaultValue:(NSNumber *)value
{
    id obj = [self mmj_objectForKey:aKey defaultValue:value];
    if (![obj isKindOfClass:[NSNumber class]]) {
        #if DEBUG
        if (obj) {
            NSLog(@"Error, %s obj is not kind of Class NSNumber, The key is:%@", __func__, aKey);
            [self mmj_printCurrentCallStack];
            
            NSString *reason = [NSString stringWithFormat:@"The key is %@, the value is :%@", aKey, value];
            NSException *exception = [NSException exceptionWithName:@"IllegalType" reason:reason userInfo:(NSDictionary *)self];
            @throw exception;
        }
        #endif
        return value;
    }
    
    return (NSNumber *)obj;
}

- (NSUInteger)mmj_unsignedIntegerForKey:(NSString *)aKey defaultValue:(NSUInteger)value
{
    id obj = [self objectForKey:aKey];
    if ([obj respondsToSelector:@selector(unsignedIntegerValue)]) {
        return [obj unsignedIntegerValue];
    }
    
    return value;
}

- (int)mmj_intForKey:(NSString *)aKey defaultValue:(int)value
{
    id obj = [self objectForKey:aKey];
    if ([obj respondsToSelector:@selector(intValue)]) {
        return [obj intValue];
    }
    
    return value;
}

- (NSInteger)mmj_integerForKey:(NSString *)aKey defaultValue:(NSInteger)value
{
    id obj = [self objectForKey:aKey];
    if ([obj respondsToSelector:@selector(integerValue)]) {
        return [obj integerValue];
    }
    
    return value;
}

- (float)mmj_floatForKey:(NSString *)aKey defaultValue:(float)value
{
    id obj = [self objectForKey:aKey];
    if ([obj respondsToSelector:@selector(floatValue)]) {
        return [obj floatValue];
    }
    
    return value;
}

- (double)mmj_doubleForKey:(NSString *)aKey defaultValue:(double)value
{
    id obj = [self objectForKey:aKey];
    if ([obj respondsToSelector:@selector(doubleValue)]) {
        return [obj doubleValue];
    }
    
    return value;
}

- (long long)mmj_longLongValueForKey:(NSString *)aKey defaultValue:(long long)value
{
    id obj = [self objectForKey:aKey];
    if ([obj respondsToSelector:@selector(longLongValue)]) {
        return [obj longLongValue];
    }
    
    return value;
}

- (BOOL)mmj_boolForKey:(NSString *)aKey defaultValue:(BOOL)value
{
    id obj = [self objectForKey:aKey];
    if ([obj respondsToSelector:@selector(boolValue)]) {
        return [obj boolValue];
    }
    
    return value;
}

@end
