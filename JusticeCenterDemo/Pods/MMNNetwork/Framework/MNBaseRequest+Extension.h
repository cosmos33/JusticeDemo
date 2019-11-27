//
//  MNBaseRequest+Extension.h
//  MMNNetwork
//
//  Created by MOMO on 2019/5/7.
//

#import "MNBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNBaseRequest () {
@protected
    BOOL _needSecret;
    MNRequestMethod _requestMethod;
    id _responseObject;
    NSURL *_filePath;
    NSString *_serviceUrl;
    NSDictionary *_requestParameters;
    NSArray *_uploadDatas;
    NSURLSessionTask *_sessionTask;
    
    MNRequestProgressBlock _progressBlock;
    MNRequestCompletionBlock _completionBlock;
    MNDownloadDestinationBlock _downloadDestinationBlock;
    
    __weak id<MNNetworkProtocol> _networkDelegate;
}

@property (nullable, nonatomic, copy) MNRequestCompletionBlock completionBlock;

/** 子类重写 进一步处理数据 */
- (void)receivedResponse:(id _Nullable)responseObject error:(NSError * _Nullable __autoreleasing *)error;

@end

@interface NSError (MNBaseRequest)

+ (NSError *)mnResponseFormatError;

+ (nullable NSError *)mnBadResponseError:(NSDictionary *)response failedError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
