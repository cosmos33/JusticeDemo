//
//  MMJDownloader.h
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMJusticeConstant.h"

NS_ASSUME_NONNULL_BEGIN

@class MMJAssetConfig;

/// 网络下载类
/// 功能：负责所有网络请求
@interface MMJDownloader : NSObject

/// 业务资源配置请求接口
/// @param appId appId
/// @param completionBlock 结果回调
- (void)requestConfigWithAppId:(NSString *)appId
                    completion:(nullable void(^)(NSDictionary * _Nullable resourcesConfig, NSDictionary * _Nullable sceneListsConfig, NSError * _Nullable error))completionBlock;

/// 下载资源请求接口
/// @param assetConfig 资源配置
/// @param completionBlock 结果回调
- (void)downloadAssetWithAssetConfig:(MMJAssetConfig *)assetConfig
                          completion:(nullable void(^)(BOOL result, NSError * _Nullable error))completionBlock;;

@end

NS_ASSUME_NONNULL_END
