//
//  MMJCenterConfig.h
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMJusticeConstant.h"

NS_ASSUME_NONNULL_BEGIN

/// 资源配置类
@interface MMJAssetConfig : NSObject

@property (nonatomic, strong) NSString *md5;
@property (nonatomic, strong) NSString *guid;
@property (nonatomic, strong) NSString *suffix;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, assign) double size;
@property (nonatomic, strong) NSString *businessMark;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *materialVersion;
@property (nonatomic, strong) NSString *sha1;
@property (nonatomic, strong) NSString *sign;

@end

/// 裁决中心配置类
@interface MMJCenterConfig : NSObject

@property (nonatomic, strong, nullable) NSString *appId;

@property (nonatomic, strong, nullable) NSDictionary<MMJBusinessType, MMJAssetConfig *> *resourceConfig;
@property (nonatomic, strong, nullable) NSDictionary<MMJSceneId, NSArray<MMJBusinessType>*> *sceneListsConfig;

@end

NS_ASSUME_NONNULL_END
