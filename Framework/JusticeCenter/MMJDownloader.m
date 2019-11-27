//
//  MMJDownloader.m
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

#import "MMJDownloader.h"
#import "MNURLSessionManager.h"
#import "MMJRequest.h"
#import "MMJFileManager.h"
#import "MMJCenterConfig.h"
#import "MMJCInnerVersion.h"
#import <MMDevice/MMDevice.h>

static NSString * const ServiceBaseURL = @"https://cosmos-video-api.immomo.com/";

@interface MMJDownloader () <MNNetworkProtocol>

@property (nonatomic, strong) MNURLSessionManager *sessionManager;
@property (nonatomic, strong) dispatch_queue_t completionQueue;

@end

@implementation MMJDownloader

- (instancetype)init {
    self = [super init];
    if (self) {
        _completionQueue = dispatch_queue_create("com.mmjusticeCenter.downloader.session.manager.completion", DISPATCH_QUEUE_CONCURRENT);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPMaximumConnectionsPerHost = 8;
        _sessionManager = [[MNURLSessionManager alloc] initWithBaseURL:[NSURL URLWithString:ServiceBaseURL] sessionConfiguration:configuration];
        _sessionManager.completionQueue = self.completionQueue;
        MNJSONResponseSerializer *responseSerializer = [MNJSONResponseSerializer serializer];
        responseSerializer.removesKeysWithNullValues = YES;
        _sessionManager.responseSerializer = responseSerializer;
        
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
        NSString *appVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        UIDevice *device = [UIDevice currentDevice];
        NSString *platformId = [MMDevice deviceName]; //iPad3,1
        NSString *platform = [MMDevice platform]; //iPad 3G
        
        //NSString *deviceName = [device model];
        NSString *OSName = [device systemName];
        NSString *OSVersion = [device systemVersion];
        NSString *locale = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLocale"];
        
        //Sample userAgent
        //AppName/4.2 ios/96 (iPhone 4; iPhone OS 5.1.1; zh_CN; iPhone3,1; APPLE)
        NSString *defaultUserAgent = [[NSString alloc] initWithFormat:@"%@/%@ ios/%ld (%@; %@ %@; %@; %@; %@)",
                                      appName,
                                      appVersion,
                                      (long)MMJCInner_Version,
                                      platform,
                                      OSName,
                                      OSVersion,
                                      locale,
                                      platformId,
                                      @"APPLE"];
        [_sessionManager.requestSerializer setValue:defaultUserAgent forHTTPHeaderField:@"User-Agent"];
    }
    return self;
}

- (void)executeRequest:(__kindof MNBaseRequest *)request {
    MNRequestMethod requestMethod = request.requestMethod;
    NSString *url = request.serviceUrl;
    
    if (requestMethod == MNRequestPost) {
        NSDictionary *parameters = request.requestParameters;
        NSArray<MNUploadData *> *uploadDatas = request.uploadDatas;
        if (uploadDatas.count) {
            request.sessionTask = [_sessionManager POST:url
                                             parameters:parameters
                                               progress:request.progressBlock
                              constructingBodyWithBlock:^(id<MNMultipartFormData>  _Nonnull formData) {
                                  for (MNUploadData * uploadData in uploadDatas) {
                                      [formData appendPartWithFileData:uploadData.data name:uploadData.name fileName:uploadData.fileName mimeType:uploadData.contentType];
                                  }
                              } completionHandler:^(id  _Nullable responseObject, NSError * _Nullable error) {
                                  [request handleResponse:responseObject error:error];
                              }];
        } else {
            request.sessionTask = [_sessionManager POST:url
                                             parameters:parameters
                                      completionHandler:^(id  _Nullable responseObject, NSError * _Nullable error) {
                                          [request handleResponse:responseObject error:error];
                                      }];
        }
    } else if (requestMethod == MNRequestDownload) {
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:60];
        request.sessionTask = [_sessionManager download:urlRequest
                                            destination:request.downloadDestinationBlock
                                               progress:request.progressBlock
                                      completionHandler:^(NSURL * _Nullable filePath, NSError * _Nullable error) {
                                          [request handleDowloadFilePath:filePath error:error];
                                      }];
    }
}

- (void)requestConfigWithAppId:(NSString *)appId completion:(void (^)(NSDictionary * _Nullable, NSDictionary * _Nullable, NSError * _Nullable))completionBlock {
    MMJConfigRequest *requset = [[MMJConfigRequest alloc] initWithAppId:appId];
    requset.networkDelegate = self;
    [requset executeWithCallback:^(MMJConfigRequest * _Nonnull request, NSError * _Nullable error) {
        if (completionBlock) {
            completionBlock(request.resourcesConfig, request.sceneListsConfig, error);
        }
    }];
}

- (void)downloadAssetWithAssetConfig:(MMJAssetConfig *)assetConfig completion:(void (^)(BOOL, NSError * _Nullable))completionBlock {
    NSString *businessDirectoryPath = [MMJFileManager businessDirectoryPathWithType:assetConfig.businessMark];
    // 下载的文件路径
    NSString *dowloadFilePath = [businessDirectoryPath stringByAppendingFormat:@"/%@.%@", assetConfig.guid, assetConfig.suffix];
    MMJDownloadRequest *requset = [[MMJDownloadRequest alloc] initWithConfig:assetConfig filePath:dowloadFilePath];
    requset.networkDelegate = self;
    [requset executeWithCallback:^(MMJDownloadRequest * _Nonnull request, NSError * _Nullable error) {
        if (!error) {
            // 下载的文件路径
            NSString *unzipFileAtPath = request.filePath.relativePath;
            // 解压资源
            if ([unzipFileAtPath hasSuffix:@"zip"]) {
                // 解压至的文件夹路径
                NSString *destination = [businessDirectoryPath stringByAppendingPathComponent:assetConfig.materialVersion];
                CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
                [MMJFileManager unzipFileAtPath:unzipFileAtPath
                                  toDestination:destination
                                      overwrite:YES
                                       password:nil error:&error];
                if (error) {
                    error = [NSError errorWithDomain:MMJusticeCenterDomain code:MMJErrorCodeUnzipFailed userInfo:@{NSLocalizedDescriptionKey: @"failed to unzip file"}];
                }
                CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
                NSLog(@"[MMJusticeCenter] [LOG_LEVEL = NORMAL] unzip %lf", end-start);
            }
        }
        if (completionBlock) {
            completionBlock(!error, error);
        }
    }];
}

@end
