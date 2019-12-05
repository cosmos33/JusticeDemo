//
//  MMJusticeCenter.m
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

#import "MMJusticeCenter.h"
#import "MMJDownloader.h"
#import "MMJCenterConfig.h"
#import "MMJFileManager.h"

static NSString * const kConfigRequestKey = @"Config_Request_Key";

@interface MMJusticeCenter ()

@property (nonatomic, strong) MMJCenterConfig *centerConfig;
@property (nonatomic, strong) MMJDownloader *downloader;

@property (nonatomic, strong) dispatch_semaphore_t lock;
@property (nonatomic, strong) dispatch_queue_t processQueue;

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableSet *> *requestResultCallbacks;
@property (nonatomic, strong) NSMutableSet *requestsSet;

@end

@implementation MMJusticeCenter

+ (instancetype)sharedInstance {
    static MMJusticeCenter *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self class] new];
    });
    return _instance;
}

+ (void)configureAppId:(NSString *)appId {
    [[self sharedInstance] configureAppId:appId];
}

+ (NSArray<MMJBusinessType> *)allSupportedBusinessTypes {
    return [[self sharedInstance] allSupportedBusinessTypes];
}

+ (NSArray<MMJSceneId> *)allSupportedSceneIds {
    return [[self sharedInstance] allSupportedSceneIds];
}

+ (void)fetchCenterConfigWithCompletion:(void (^)(BOOL, NSError * _Nullable))completionBlock {
    [[self sharedInstance] fetchCenterConfigWithCompletion:completionBlock];
}

+ (void)prepareWithBusinessTypes:(NSArray<MMJBusinessType> *)businessTypes completion:(nullable void (^)(NSDictionary<MMJBusinessType,MMJResultInfo *> * _Nonnull))completionBlock {
    [[self sharedInstance] prepareWithBusinessTypes:businessTypes completion:completionBlock];
}

+ (void)prepareWithSceneIds:(NSArray<MMJSceneId> *)sceneIds completion:(void (^)(NSDictionary<MMJSceneId,MMJResultInfo *> * _Nonnull))completionBlock {
    [[self sharedInstance] prepareWithSceneIds:sceneIds completion:completionBlock];
}

+ (void)prepareAllSupportedScenesWithCompletion:(void (^)(NSDictionary<MMJSceneId,MMJResultInfo *> * _Nonnull))completionBlock {
    [[self sharedInstance] prepareAllSupportedScenesWithCompletion:completionBlock];
}

+ (void)asyncMakeJusticeWithBusinessTypes:(NSArray<MMJBusinessType> *)businessTypes completion:(void (^)(Justice * _Nullable))completionBlock {
    [[self sharedInstance] asyncMakeJusticeWithBusinessTypes:businessTypes completion:completionBlock];
}

+ (void)asyncMakeJusticeWithSceneId:(MMJSceneId)sceneId completion:(void (^)(Justice * _Nullable))completionBlock {
    [[self sharedInstance] asyncMakeJusticeWithSceneId:sceneId completion:completionBlock];
}

+ (BOOL)clearAllAssets {
    return [[self sharedInstance] clearAllAssets];
}

- (BOOL)clearAllAssets {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    BOOL ret = [MMJFileManager clearAllAssets];
    dispatch_semaphore_signal(self.lock);
    return ret;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _centerConfig = [MMJCenterConfig new];
        _downloader = [MMJDownloader new];
        
        _processQueue = dispatch_queue_create("com.momo.justiceCenter.processing", DISPATCH_QUEUE_CONCURRENT);
        
        _lock = dispatch_semaphore_create(1);
        _requestResultCallbacks = [NSMutableDictionary dictionary];
        _requestsSet = [NSMutableSet set];
    }
    return self;
}

#pragma mark - 环境准备

- (void)prepareWithBusinessTypes:(NSArray<MMJBusinessType> *)businessTypes completion:(nullable void (^)(NSDictionary<MMJBusinessType, MMJResultInfo *> * _Nonnull))completionBlock {
    dispatch_async(self.processQueue, ^{
        if (![self isExistAssetConfigs]) {
            __weak typeof(self) weak_self = self;
            [self fetchCenterConfigWithCompletion:^(BOOL result, NSError * _Nullable error) {
                typeof(weak_self) strong_self = weak_self;
                [strong_self checkAssetWithBusinessTypes:businessTypes completion:completionBlock];
            }];
            return;
        }
        [self checkAssetWithBusinessTypes:businessTypes completion:completionBlock];
    });
}

- (void)prepareWithSceneIds:(NSArray<MMJSceneId> *)sceneIds completion:(void (^)(NSDictionary<MMJSceneId,MMJResultInfo *> * _Nonnull))completionBlock {
    dispatch_async(self.processQueue, ^{
          if (![self isExistAssetConfigs]) {
              __weak typeof(self) weak_self = self;
              [self fetchCenterConfigWithCompletion:^(BOOL result, NSError * _Nullable error) {
                  typeof(weak_self) strong_self = weak_self;
                  [strong_self checkAssetWithSceneIds:sceneIds completion:completionBlock];
              }];
              return;
          }
          [self checkAssetWithSceneIds:sceneIds completion:completionBlock];
    });
}

- (void)prepareAllSupportedScenesWithCompletion:(void (^)(NSDictionary<MMJSceneId,MMJResultInfo *> * _Nonnull))completionBlock {
    dispatch_async(self.processQueue, ^{
        if (![self isExistAssetConfigs]) {
            __weak typeof(self) weak_self = self;
            [self fetchCenterConfigWithCompletion:^(BOOL result, NSError * _Nullable error) {
                typeof(weak_self) strong_self = weak_self;
                [strong_self checkAssetWithSceneIds:[strong_self allSupportedSceneIds] completion:completionBlock];
            }];
            return;
        }
        [self checkAssetWithSceneIds:[self allSupportedSceneIds] completion:completionBlock];
    });
}

- (void)fetchCenterConfigWithCompletion:(nullable void (^)(BOOL, NSError * _Nullable))completionBlock {
    [self setRequestResultCallback:completionBlock forRequestKey:kConfigRequestKey];
    if ([self isRequestingForRequestKey:kConfigRequestKey]) {
        return;
    }
    NSLog(@"[MMJusticeCenter] [LOG_LEVEL = NORMAL] Fetching Config");
    NSString *appId = [self getAppId];
    __weak typeof(self) weak_self = self;
    [self.downloader requestConfigWithAppId:appId completion:^(NSDictionary * _Nullable resourcesConfig, NSDictionary * _Nullable sceneListsConfig, NSError * _Nullable error) {
        typeof(weak_self) strong_self = weak_self;
        
        if (!error) {
            dispatch_semaphore_wait(strong_self.lock, DISPATCH_TIME_FOREVER);
            strong_self.centerConfig.resourceConfig = resourcesConfig;
            strong_self.centerConfig.sceneListsConfig = sceneListsConfig;
            dispatch_semaphore_signal(strong_self.lock);
        }
        [strong_self handleResult:!error error:error forRequestKey:kConfigRequestKey];
    }];
}

- (void)checkAssetWithBusinessTypes:(NSArray<MMJBusinessType> *)businessTypes completion:(nullable void (^)(NSDictionary<MMJBusinessType, MMJResultInfo *> * _Nonnull))completionBlock {
    
    if (!businessTypes.count) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(@{});
            });
        }
        return;
    }
    
    NSMutableDictionary *resultsDic = [NSMutableDictionary dictionary];
    dispatch_group_t group = dispatch_group_create();
    for (MMJBusinessType type in businessTypes) {
        dispatch_group_enter(group);
        __weak typeof(self) weak_self = self;
        [self checkAssetWithType:type completion:^(BOOL result, NSError * _Nullable error) {
            typeof(weak_self) strong_self = weak_self;
            
            NSString *localVersion = [MMJFileManager assetVersionStringWithType:type];
            BOOL t_result = !!localVersion.length; // 只要本地有缓存就算准备成功
            MMJResultInfo *resultInfo = [MMJResultInfo resultInfoWithResult:t_result error:error defultCode:MMJErrorCodeDownloadFailed];
            dispatch_semaphore_wait(strong_self.lock, DISPATCH_TIME_FOREVER);
            [resultsDic setObject:resultInfo forKey:type];
            dispatch_semaphore_signal(strong_self.lock);
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completionBlock) {
            completionBlock(resultsDic);
        }
    });
}

- (void)checkAssetWithSceneIds:(NSArray<MMJSceneId> *)sceneIds completion:(void (^)(NSDictionary<MMJSceneId,MMJResultInfo *> * _Nonnull))completionBlock {
    
    if (!sceneIds.count) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(@{});
            });
        }
        return;
    }
    
    NSMutableDictionary *resultsDic = [NSMutableDictionary dictionary];
    dispatch_group_t group = dispatch_group_create();
    for (MMJSceneId sceneId in sceneIds) {
        NSArray<MMJBusinessType> *businessTypes = [self businessTypesForScenceId:sceneId];
        
        if (!businessTypes.count) {
            NSLog(@"[MMJusticeCenter] [LOG_LEVEL = ERROR] 场景 %@ 缺少业务配置", sceneId);
            MMJResultInfo *resultInfo = [MMJResultInfo resultInfoWithResult:NO error:nil defultCode:MMJErrorCodeUnsupportedConfiguration];
            dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
            [resultsDic setObject:resultInfo forKey:sceneId];
            dispatch_semaphore_signal(self.lock);
            continue;
        }
        
        dispatch_group_enter(group);
        __weak typeof(self) weak_self = self;
        [self checkAssetWithBusinessTypes:businessTypes completion:^(NSDictionary<MMJBusinessType,MMJResultInfo *> * _Nonnull rDic) {
            typeof(weak_self) strong_self = weak_self;
            __block BOOL t_result = YES;
            __block MMJErrorCode errorCode = 0;
            [rDic enumerateKeysAndObjectsUsingBlock:^(MMJBusinessType  _Nonnull key, MMJResultInfo * _Nonnull obj, BOOL * _Nonnull stop) {
                if (!obj.result) {
                    t_result = NO;
                    errorCode = obj.errorCode;
                    *stop = YES;
                }
            }];
            
            MMJResultInfo *resultInfo = [MMJResultInfo resultInfoWithResult:t_result error:nil defultCode:MMJErrorCodeDownloadFailed];
            dispatch_semaphore_wait(strong_self.lock, DISPATCH_TIME_FOREVER);
            [resultsDic setObject:resultInfo forKey:sceneId];
            dispatch_semaphore_signal(strong_self.lock);
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completionBlock) {
            completionBlock(resultsDic);
        }
    });
}

- (void)checkAssetWithType:(MMJBusinessType)type completion:(void(^)(BOOL result, NSError * _Nullable error))completion {

    MMJAssetConfig *assetConfig = [self assetConfigForKType:type];
    if (!assetConfig) {
        NSString *info = [NSString stringWithFormat:@"业务类型 %@ 缺少更新配置", type];
        NSLog(@"[MMJusticeCenter] [LOG_LEVEL = NORMAL] 业务类型 %@ 缺少更新配置", type);
        NSError *error = [NSError errorWithDomain:MMJusticeCenterDomain code:MMJErrorCodeUnsupportedConfiguration userInfo:@{NSLocalizedDescriptionKey: info}];
        if (completion) {
            completion(NO, error);
        }
        return;
    }
    
    NSString *localVersion = [MMJFileManager assetVersionStringWithType:type];
    NSString *originVersion = assetConfig.materialVersion;
    if (!localVersion.length
        || (originVersion.integerValue > localVersion.integerValue)) {
        NSLog(@"[MMJusticeCenter] [LOG_LEVEL = NORMAL] 业务类型 %@ 需要更新 本地版本 %@ 远端版本 %@", type, localVersion, originVersion);
        [self downLoadAssetWithConfig:assetConfig localVersion:localVersion completion:completion];
        return;
    }
    NSLog(@"[MMJusticeCenter] [LOG_LEVEL = NORMAL] 业务类型 %@ 本地已最新 本地版本 %@ 远端版本 %@", type, localVersion, originVersion);
    if (completion) {
        completion(YES, nil);
    }
}

- (void)downLoadAssetWithConfig:(MMJAssetConfig *)assetConfig localVersion:(NSString *)localVersion completion:(void(^)(BOOL result, NSError * _Nullable error))completion {
    NSString *requestKey = [assetConfig.businessMark stringByAppendingString:@"_downLoad"];
    [self setRequestResultCallback:completion forRequestKey:requestKey];
    // 为保证线程安全，调用 isRequestingForRequestKey 会同时将未请求的类型立即加入请求标识队列
    if ([self isRequestingForRequestKey:requestKey]) {
        return;
    }
    NSLog(@"[MMJusticeCenter] [LOG_LEVEL = NORMAL] downLoad %@", assetConfig.businessMark);
    __weak typeof(self) weak_self = self;
    [self.downloader downloadAssetWithAssetConfig:assetConfig completion:^(BOOL result, NSError * _Nullable error) {
        typeof(weak_self) strong_self = weak_self;
        if (result && localVersion.length) {
            // 下载成功再移除旧版本
            NSString *oldVersionPath = [MMJFileManager appendAssetPathWithType:assetConfig.businessMark version:localVersion];
            [MMJFileManager removeFileIfNeetAtPath:oldVersionPath];
        }
        [strong_self handleResult:result error:error forRequestKey:requestKey];
    }];
}

#pragma mark - 检测器构造方法
- (void)asyncMakeJusticeWithBusinessTypes:(NSArray<MMJBusinessType> *)businessTypes completion:(void (^)(Justice * _Nullable))completionBlock {
    __weak typeof(self) weak_self = self;
    [self prepareWithBusinessTypes:businessTypes completion:^(NSDictionary<MMJBusinessType,MMJResultInfo *> * _Nonnull resultsDic) {
        typeof(weak_self) strong_self = weak_self;
        dispatch_async(strong_self.processQueue, ^{
            
            Justice *jtObject = [strong_self _makeJusticeWithBusinessTypes:businessTypes];
            
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(jtObject);
                });
            }
        });
    }];
}

- (void)asyncMakeJusticeWithSceneId:(MMJSceneId)sceneId completion:(void (^)(Justice * _Nullable))completionBlock {
    if (!sceneId) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil);
            });
        }
        return;
    }
    __weak typeof(self) weak_self = self;
    [self prepareWithSceneIds:@[sceneId] completion:^(NSDictionary<MMJSceneId,MMJResultInfo *> * _Nonnull resultsDic) {
        typeof(weak_self) strong_self = weak_self;
        dispatch_async(strong_self.processQueue, ^{
            NSArray<MMJBusinessType> *businessTypes = [self businessTypesForScenceId:sceneId];
            if (!businessTypes.count) {
                if (completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(nil);
                    });
                }
                return;
            }
         
            Justice *jtObject = [strong_self _makeJusticeWithBusinessTypes:businessTypes];
            
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(jtObject);
                });
            }
        });
    }];
}

- (Justice *)_makeJusticeWithBusinessTypes:(NSArray<MMJBusinessType> *)businessTypes {
    NSMutableArray *businessesWithDirs = [NSMutableArray array];
    for (MMJBusinessType type in businessTypes) {
        NSString *path = [MMJFileManager assetPathWithType:type];
        if (!path.length) {
            NSLog(@"[MMJusticeCenter] [LOG_LEVEL = ERROR] 业务类型 %@ 缺失本地资源", type);
            continue;
        }
        
        [businessesWithDirs addObject:@[type, path]];
    }
    
    NSError *error = nil;
    Justice *jtObject = [Justice justiceWithBusinesses:businessesWithDirs error:&error];
    if (error) {
        NSLog(@"[MMJusticeCenter] [LOG_LEVEL = ERROR] make Justice error: %@", error);
    }
    return jtObject;
}

#pragma mark - Safe Method
- (void)configureAppId:(NSString *)appId {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    self.centerConfig.appId = appId;
    dispatch_semaphore_signal(self.lock);
}

- (NSString *)getAppId {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    NSString *appId = self.centerConfig.appId;
    dispatch_semaphore_signal(self.lock);
    return appId;
}

- (NSArray<MMJBusinessType> *)allSupportedBusinessTypes {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    NSArray<MMJBusinessType> *allTypes = self.centerConfig.resourceConfig.allKeys.copy;
    dispatch_semaphore_signal(self.lock);
    return allTypes;
}

- (NSArray<MMJSceneId> *)allSupportedSceneIds {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    NSArray<MMJSceneId> *allIds = self.centerConfig.sceneListsConfig.allKeys.copy;
    dispatch_semaphore_signal(self.lock);
    return allIds;
}

- (BOOL)isExistAssetConfigs {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    BOOL isExist = !!self.centerConfig.resourceConfig.count;
    dispatch_semaphore_signal(self.lock);
    return isExist;
}

- (MMJAssetConfig *)assetConfigForKType:(MMJBusinessType)type {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    MMJAssetConfig *assetConfig = self.centerConfig.resourceConfig[type];
    dispatch_semaphore_signal(self.lock);
    return assetConfig;
}

- (NSArray<MMJBusinessType> *)businessTypesForScenceId:(MMJSceneId)sceneId {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    NSArray *businessTypes = self.centerConfig.sceneListsConfig[sceneId];
    dispatch_semaphore_signal(self.lock);
    return businessTypes.copy;
}

- (BOOL)isRequestingForRequestKey:(NSString *)requestKey {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    BOOL ret = [self.requestsSet containsObject:requestKey];
    if (!ret) {
        [self.requestsSet addObject:requestKey];
    }
    dispatch_semaphore_signal(self.lock);
    return ret;
}

- (void)setRequestResultCallback:(void(^)(BOOL result, NSError * _Nullable error))callback forRequestKey:(NSString *)requestKey {
    if (!callback) {
        return;
    }
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    NSMutableSet *callbacks = self.requestResultCallbacks[requestKey];
    if (!callbacks) {
        callbacks = [NSMutableSet set];
        self.requestResultCallbacks[requestKey] = callbacks;
    }
    [callbacks addObject:callback];
    dispatch_semaphore_signal(self.lock);
}

- (void)handleResult:(BOOL)result error:(NSError *)error forRequestKey:(NSString *)requestKey {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    NSSet * callbacks = self.requestResultCallbacks[requestKey].copy;
    [self.requestsSet removeObject:requestKey];
    [self.requestResultCallbacks removeObjectForKey:requestKey];
    dispatch_semaphore_signal(self.lock);
    if (callbacks.count) {
        [callbacks enumerateObjectsUsingBlock:^(void(^obj)(BOOL, NSError * _Nullable), BOOL * _Nonnull stop) {
            dispatch_async(self.processQueue, ^{
                obj(result, error);
            });
        }];
    }
}

@end
