//
//  MNURLSessionManager.h
//  MMNNetwork
//
//  Created by MOMO on 2019/5/15.
//

#import <Foundation/Foundation.h>
#import "MNURLRequestSerialization.h"
#import "MNURLResponseSerialization.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MNMultipartFormData;
@class MNHTTPRequestSerializer;

@interface MNURLSessionManager : NSObject

@property (nonatomic, strong, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readonly, nullable) NSURL *baseURL;

@property (nonatomic, weak) id <NSURLSessionDelegate> urlSessionDelegate;

@property (nonatomic, strong) MNHTTPRequestSerializer *requestSerializer;
@property (nonatomic, strong) MNHTTPResponseSerializer *responseSerializer;

@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

- (instancetype)initWithBaseURL:(nullable NSURL *)url;

- (instancetype)initWithBaseURL:(nullable NSURL *)url
           sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration;

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                      completionHandler:(nullable void (^)(id _Nullable responseObject, NSError * _Nullable error))completionHandler;

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
              constructingBodyWithBlock:(nullable void (^)(id <MNMultipartFormData> formData))block
                      completionHandler:(nullable void (^)(id _Nullable responseObject, NSError * _Nullable error))completionHandler;

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
              constructingBodyWithBlock:(nullable void (^)(id <MNMultipartFormData> formData))block
                      completionHandler:(nullable void (^)(id _Nullable responseObject, NSError * _Nullable error))completionHandler;

- (nullable NSURLSessionDownloadTask *)download:(NSURLRequest *)request
                                    destination:(nullable NSURL * _Nonnull (^)(NSURL * targetPath, NSURLResponse *response))destination
                                       progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                              completionHandler:(nullable void (^)(NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
