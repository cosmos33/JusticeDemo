//
//  MNBaseRequest.h
//  MMNNetwork
//
//  Created by MOMO on 2019/5/7.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MNRequestMethod) {
    MNRequestPost         = 0,
    MNRequestGet          = 1,
    MNRequestDownload     = 2,
};

NS_ASSUME_NONNULL_BEGIN
@class MNBaseRequest;

@protocol MNNetworkProtocol <NSObject>

/**
 方法说明
 MNBaseRequest 中包含了请求类型及请求参数 请根据这些信息发起对应的请求 NSURLSessionTask
 请将创建的Task 赋值回 request.sessionTask
 收到响应结果后从 [MNBaseRequest hanldeResponse: error:] 抛回
 */
- (void)executeRequest:(__kindof MNBaseRequest *)request;

@end

typedef void(^MNRequestProgressBlock)(NSProgress *progress);
typedef void(^MNRequestCompletionBlock)(__kindof MNBaseRequest *request, NSError * _Nullable error);
typedef NSURL * _Nonnull(^MNDownloadDestinationBlock)(NSURL *targetPath, NSURLResponse *response);

@interface MNUploadData : NSObject

@property (nullable, nonatomic, copy) NSData *data;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *fileName;
@property (nullable, nonatomic, copy) NSString *contentType;

@end

@interface MNBaseRequest : NSObject

@property (nonatomic, assign, readonly) BOOL needSecret;
@property (nonatomic, assign, readonly) MNRequestMethod requestMethod;
@property (nonatomic, copy, readonly) NSString *serviceUrl;
@property (nullable, nonatomic, copy, readonly) NSDictionary *requestParameters;
@property (nullable, nonatomic, copy, readonly) NSArray<MNUploadData *> *uploadDatas;

@property (nullable, nonatomic, copy, readonly) MNRequestProgressBlock progressBlock;
@property (nullable, nonatomic, copy, readonly) MNDownloadDestinationBlock downloadDestinationBlock;

@property (nullable, nonatomic, strong, readonly) id responseObject;
@property (nullable, nonatomic, strong, readonly) NSURL *filePath;

#pragma mark - 网络请求类需调用接口
@property (nullable, nonatomic, strong) NSURLSessionTask *sessionTask; //网络请求填充

// 网络请求类将 responseObject 从此接口抛回处理
- (void)handleResponse:(id _Nullable)responseObject error:(NSError * _Nullable)error;

- (void)handleDowloadFilePath:(NSURL * _Nullable)filePath error:(NSError * _Nullable)error;

@end

@interface MNBaseRequest (Operation)

@property (nonatomic, weak) id<MNNetworkProtocol> networkDelegate;

#pragma mark - 业务使用
- (void)execute;

- (void)executeWithCallback:(nullable MNRequestCompletionBlock)block;

- (void)executeWithProgressBlock:(nullable MNRequestProgressBlock)progressBlock
                        callback:(nullable MNRequestCompletionBlock)block;

@end

OBJC_EXTERN NSString * const MNRequestDomain;

NS_ASSUME_NONNULL_END
