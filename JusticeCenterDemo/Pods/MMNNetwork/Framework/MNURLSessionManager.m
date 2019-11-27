//
//  MNURLSessionManager.m
//  MMNNetwork
//
//  Created by MOMO on 2019/5/15.
//

#import "MNURLSessionManager.h"
#import "MNRequestOperation.h"

static const NSTimeInterval kMNHTTPTimeout = 30;

@interface MNURLSessionManager () <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *urlSeesion;

@property (nonatomic, strong) NSOperationQueue *requestQueue;

@end

@implementation MNURLSessionManager

- (instancetype)init {
    return [self initWithBaseURL:nil sessionConfiguration:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    return [self initWithBaseURL:url sessionConfiguration:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)url
           sessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (self) {
        
        if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
            url = [url URLByAppendingPathComponent:@""];
        }

        if (!configuration) {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        
        _baseURL = url;
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"com.momonext.networkt.url-seesion-processing";
        if (@available(iOS 8.0, *)) {
            _operationQueue.maxConcurrentOperationCount = 5;
        } else {
            _operationQueue.maxConcurrentOperationCount = 1;
        }
        self.urlSeesion = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:self.operationQueue];
        
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.name = @"com.momonext.networkt.url-seesion-request";
        _requestQueue.maxConcurrentOperationCount = configuration.HTTPMaximumConnectionsPerHost;
        
        _requestSerializer = [MNHTTPRequestSerializer serializer];
        [self.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        self.requestSerializer.timeoutInterval = kMNHTTPTimeout;
        _responseSerializer = [MNJSONResponseSerializer serializer];
    }
    return self;
}

#pragma mark - Create Task
- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters completionHandler:(nullable void (^)(id _Nullable, NSError * _Nullable))completionHandler {
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (completionHandler) {
            dispatch_async(self.completionQueue ? : dispatch_get_main_queue(), ^{
                completionHandler(nil, serializationError);
            });
        }
        return nil;
    }
    
    NSURLSessionDataTask * dataTask = [self.urlSeesion dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self handleTaskResult:data response:response error:error completionHandler:completionHandler];
    }];
    [self addOperationForDataTask:dataTask uploadProgress:nil downloadProgress:nil];
    return dataTask;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<MNMultipartFormData> _Nonnull))block completionHandler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler {
    return [self POST:URLString parameters:parameters progress:nil constructingBodyWithBlock:block completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters progress:(void (^)(NSProgress * _Nonnull))uploadProgress constructingBodyWithBlock:(void (^)(id<MNMultipartFormData> _Nonnull))block completionHandler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler {
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    if (serializationError) {
        if (completionHandler) {
            dispatch_async(self.completionQueue ? : dispatch_get_main_queue(), ^{
                completionHandler(nil, serializationError);
            });
        }
        return nil;
    }
    
    NSURLSessionDataTask *task = [self.urlSeesion uploadTaskWithRequest:request fromData:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self handleTaskResult:data response:response error:error completionHandler:completionHandler];
    }];
    [self addOperationForDataTask:task uploadProgress:uploadProgress downloadProgress:nil];
    return task;
}

- (NSURLSessionDownloadTask *)download:(NSURLRequest *)request destination:(NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination progress:(void (^)(NSProgress * _Nonnull))downloadProgress completionHandler:(void (^)(NSURL * _Nullable, NSError * _Nullable))completionHandler {

    NSURLSessionDownloadTask * dataTask = [self.urlSeesion downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self handleDownload:location response:response error:error destination:destination completionHandler:completionHandler];
    }];
    [self addOperationForDataTask:dataTask uploadProgress:nil downloadProgress:downloadProgress];
    return dataTask;
}

- (void)addOperationForDataTask:(NSURLSessionTask *)dataTask
                uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
              downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
{
    MNRequestOperation *operation = [MNRequestOperation new];
    operation.sessionTask = dataTask;
    operation.uploadProgressBlock = uploadProgressBlock;
    operation.downloadProgressBlock = downloadProgressBlock;
    [self.requestQueue addOperation:operation];
}


#pragma mark - Handle Completion
- (void)handleTaskResult:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error completionHandler:(nullable void (^)(id _Nullable, NSError * _Nullable))completionHandler {
    
    if (error) {
        if (completionHandler) {
            dispatch_async(self.completionQueue ? : dispatch_get_main_queue(), ^{
                completionHandler(data, error);
            });
        }
        return;
    }
    
    data = [self.responseSerializer responseObjectForResponse:response data:data error:&error];
    if (completionHandler) {
        dispatch_async(self.completionQueue ? : dispatch_get_main_queue(), ^{
            completionHandler(data, error);
        });
    }
}

- (void)handleDownload:(NSURL * _Nullable)location
              response:(NSURLResponse *)response
                 error:(NSError *)error
           destination:(NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination
     completionHandler:(nonnull void (^)(NSURL * _Nullable, NSError * _Nullable))completionHandler {
    
    if (error) {
        if (completionHandler) {
            dispatch_async(self.completionQueue ? : dispatch_get_main_queue(), ^{
                completionHandler(location, error);
            });
        }
        return;
    }
    
    [self.responseSerializer responseObjectForResponse:response data:nil error:&error];
    if (!error && destination) {
        NSURL *downloadFileURL = destination(location, response);
        if (downloadFileURL) {
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:downloadFileURL error:&error];
            if (!error) {
                location = downloadFileURL;
            }
        }
    }
    
    if (completionHandler) {
        dispatch_async(self.completionQueue ? : dispatch_get_main_queue(), ^{
            completionHandler(location, error);
        });
    }
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    if (self.urlSessionDelegate && [self.urlSessionDelegate respondsToSelector:@selector(URLSession:didBecomeInvalidWithError:)]) {
        [self.urlSessionDelegate URLSession:session didBecomeInvalidWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    if (self.urlSessionDelegate && [self.urlSessionDelegate respondsToSelector:@selector(URLSession:didReceiveChallenge:completionHandler:)]) {
        [self.urlSessionDelegate URLSession:session didReceiveChallenge:challenge completionHandler:completionHandler];
        return;
    }
    
    if (completionHandler) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.urlSessionDelegate && [self.urlSessionDelegate respondsToSelector:@selector(URLSessionDidFinishEventsForBackgroundURLSession:)]) {
        [self.urlSessionDelegate URLSessionDidFinishEventsForBackgroundURLSession:session];
    }
}

@end
