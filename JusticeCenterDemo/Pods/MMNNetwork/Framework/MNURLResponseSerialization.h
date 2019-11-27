//
//  MNURLResponseSerialization.h
//  MMNNetwork
//
//  Created by MOMO on 2019/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNHTTPResponseSerializer : NSObject

- (instancetype)init;

+ (instancetype)serializer;

@property (nonatomic, copy, nullable) NSIndexSet *acceptableStatusCodes;

@property (nonatomic, copy, nullable) NSSet <NSString *> *acceptableContentTypes;

- (BOOL)validateResponse:(nullable NSHTTPURLResponse *)response
                    data:(nullable NSData *)data
                   error:(NSError * _Nullable __autoreleasing *)error;

- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                                    data:(nullable NSData *)data
                                   error:(NSError * _Nullable __autoreleasing *)error;

@end

@interface MNJSONResponseSerializer : MNHTTPResponseSerializer

- (instancetype)init;

@property (nonatomic, assign) NSJSONReadingOptions readingOptions;

@property (nonatomic, assign) BOOL removesKeysWithNullValues;


+ (instancetype)serializerWithReadingOptions:(NSJSONReadingOptions)readingOptions;

@end

FOUNDATION_EXPORT NSString * const MNURLResponseSerializationErrorDomain;

FOUNDATION_EXPORT NSString * const MNNetworkingOperationFailingURLResponseErrorKey;

FOUNDATION_EXPORT NSString * const MNNetworkingOperationFailingURLResponseDataErrorKey;

NS_ASSUME_NONNULL_END
