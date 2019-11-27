//
//  MMJRequest.h
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

#import "MNBaseRequest.h"
#import "MMJusticeConstant.h"

NS_ASSUME_NONNULL_BEGIN

@class MMJAssetConfig;

/// 资源配置请求
@interface MMJConfigRequest : MNBaseRequest

- (instancetype)initWithAppId:(NSString *)appId;

@property (nonatomic, strong) NSDictionary *resourcesConfig;

@property (nonatomic, strong) NSDictionary *sceneListsConfig;

@end

/// 资源下载请求
@interface MMJDownloadRequest : MNBaseRequest

@property (nonatomic, strong, readonly) NSString *md5;

- (instancetype)initWithConfig:(MMJAssetConfig *)config filePath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
