//
//  MNBaseRequest.m
//  MMNNetwork
//
//  Created by MOMO on 2019/5/7.
//

#import "MNBaseRequest+Extension.h"

NSString * const MNRequestDomain = @"com.momonext.error.baseRequest.response";

@implementation NSError (MNBaseRequest)

+ (NSError *)mnResponseFormatError {
    return [NSError errorWithDomain:MNRequestDomain
                               code:NSURLErrorCannotDecodeContentData
                           userInfo:@{NSLocalizedDescriptionKey: @"response 格式错误"}];
}

+ (NSError *)mnBadResponseError:(NSDictionary *)response failedError:(NSError *)error {
    NSInteger errorCode = [response[@"status"] integerValue];
    
    if (errorCode) {
        NSString *failingURL = error.userInfo[NSURLErrorFailingURLStringErrorKey];
        NSString *message = response[@"error"] ? : response.description;
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if (failingURL) {
            [userInfo setObject:failingURL forKey:NSURLErrorFailingURLStringErrorKey];
        }
        if (message) {
            [userInfo setObject:message forKey:NSLocalizedDescriptionKey];
        }
        [userInfo setObject:response forKey:NSLocalizedFailureReasonErrorKey];
        error = [NSError errorWithDomain:error.domain
                                    code:errorCode
                                userInfo:userInfo];
    }
    return error;
}

@end

@implementation MNUploadData
@end

@implementation MNBaseRequest

- (void)handleResponse:(id)responseObject error:(NSError *)error {
    if ([responseObject isKindOfClass:NSData.class]) {
        responseObject = [self JSONObjectWithData:responseObject];
    }
    _responseObject = responseObject;
    
    if (error) {
        if ([responseObject isKindOfClass:NSDictionary.class]) {
            error = [NSError mnBadResponseError:responseObject failedError:error];
        }
    } else {
        [self receivedResponse:responseObject error:&error];
    }
    
    if (error) {
        NSLog(@"[MNBaseRequest] [LOG_LEVEL = ERROR] Service Url: %@ \n %@", self.serviceUrl, error);
    }
    
    if (self.completionBlock) {
        self.completionBlock(self, error);
    }
}

- (void)handleDowloadFilePath:(NSURL *)filePath error:(NSError *)error {
    _filePath = filePath;
    if (error) {
        NSLog(@"[MNBaseRequest] [LOG_LEVEL = ERROR] Service Url: %@ \n %@", self.serviceUrl, error);
    }
    if (self.completionBlock) {
        self.completionBlock(self, error);
    }
}

- (id)JSONObjectWithData:(NSData *)data {
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingMutableContainers
                                                      error:&jsonError];
    if (jsonError) {
        NSLog(@"[MNBaseRequest] [LOG_LEVEL = ERROR] Json Error %@", jsonError);
    }
    if (jsonObject) {
        return jsonObject;
    }
    return data;
}

- (void)receivedResponse:(id)responseObject error:(NSError * _Nullable __autoreleasing *)error {
    
}

@end

@implementation MNBaseRequest (Operation)

- (id<MNNetworkProtocol>)networkDelegate {
    return _networkDelegate;
}

- (void)setNetworkDelegate:(id<MNNetworkProtocol>)networkDelegate {
    _networkDelegate = networkDelegate;
}

- (void)execute {
    [self executeWithCallback:nil];
}

- (void)executeWithCallback:(MNRequestCompletionBlock)block {
    [self executeWithProgressBlock:nil callback:block];
}

- (void)executeWithProgressBlock:(MNRequestProgressBlock)progressBlock callback:(nullable MNRequestCompletionBlock)block {
    _progressBlock = progressBlock;
    _completionBlock = block;
    if (self.networkDelegate && [self.networkDelegate respondsToSelector:@selector(executeRequest:)]) {
        [self.networkDelegate executeRequest:self];
    }
}

@end
