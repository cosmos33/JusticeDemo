//
//  MMJusticeCenter.h
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMJusticeConstant.h"
#import "MMJResultInfo.h"
#import <JusticeKit/JTJustice.h>

NS_ASSUME_NONNULL_BEGIN

/// Justice 资源中心
/// 功能：负责 Justice 的资源的统一管理及 Justice 实例的获取
@interface MMJusticeCenter : NSObject

/// 设置AppId
/// 在使用服务前必须设置，全局只用设置一次即可
/// @param appId appId
+ (void)configureAppId:(NSString *)appId;

/// 获取所有支持的业务类型
/// 必须在拉取资源中心的资源配置后才能获取到
+ (nullable NSArray<MMJBusinessType> *)allSupportedBusinessTypes;

/// 获取所有支持的场景Id
/// 必须在拉取资源中心的资源配置后才能获取到
+ (nullable NSArray<MMJSceneId> *)allSupportedSceneIds;

/// 拉取资源中心的资源配置
/// @param completionBlock 更新结果
+ (void)fetchCenterConfigWithCompletion:(nullable void (^)(BOOL result, NSError * _Nullable error))completionBlock;

/// 资源准备
/// 当没有拉取过资源配置时会先拉取配置
/// @param businessTypes 需要准备的业务类型
/// @param completionBlock 准备结果回调
+ (void)prepareWithBusinessTypes:(NSArray<MMJBusinessType> *)businessTypes
                      completion:(nullable void(^)(NSDictionary<MMJBusinessType, MMJResultInfo *> *resultsDic))completionBlock;

/// 资源准备
/// 当没有拉取过资源配置时会先拉取配置
/// @param sceneIds 需要准备的场景Id
/// @param completionBlock 准备结果回调
+ (void)prepareWithSceneIds:(NSArray<MMJSceneId> *)sceneIds
                 completion:(nullable void(^)(NSDictionary<MMJSceneId, MMJResultInfo *> *resultsDic))completionBlock;

/// 准备所有场景需要的资源
/// 当没有拉取过资源配置时会先拉取配置
/// @param completionBlock 准备结果回调
+ (void)prepareAllSupportedScenesWithCompletion:(nullable void(^)(NSDictionary<MMJSceneId, MMJResultInfo *> *resultsDic))completionBlock;

/// 异步构造检测器
/// @param businessTypes 需要的业务类型
/// @param completionBlock 构造完成回调
+ (void)asyncMakeJusticeWithBusinessTypes:(NSArray<MMJBusinessType> *)businessTypes
                               completion:(nullable void(^)(Justice * _Nullable justice))completionBlock;

/// 异步构造检测器
/// @param sceneId 需要准备的场景Id
/// @param completionBlock 构造完成回调
+ (void)asyncMakeJusticeWithSceneId:(MMJSceneId)sceneId
                         completion:(nullable void(^)(Justice * _Nullable justice))completionBlock;

/// 清空本地资源
+ (BOOL)clearAllAssets;

@end

NS_ASSUME_NONNULL_END
