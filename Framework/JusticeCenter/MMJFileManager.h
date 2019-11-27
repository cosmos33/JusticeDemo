//
//  MMJFileManager.h
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMJusticeConstant.h"

NS_ASSUME_NONNULL_BEGIN

/// 文件管理类
/// 功能：负责文件的统一操作
@interface MMJFileManager : NSObject

+ (BOOL)creatDirectoryIfNeetAtPath:(NSString *)path;
+ (BOOL)removeFileIfNeetAtPath:(NSString *)path;
+ (BOOL)unzipFileAtPath:(NSString *)path
          toDestination:(NSString *)destination
              overwrite:(BOOL)overwrite
               password:(nullable NSString *)password
                  error:(NSError * *)error;

/// 根据业务类型和资源版本拼接资源文件夹路径
/// @param type 业务类型
/// @param version 资源版本号
+ (NSString *)appendAssetPathWithType:(MMJBusinessType)type version:(NSString *)version;

/// 是否存在对应业务类型的资源
/// @param type 业务类型
+ (BOOL)isExistAssetWithType:(MMJBusinessType)type;

/// 对应业务资源根文件夹路径
/// @param type 业务类型
+ (NSString *)businessDirectoryPathWithType:(MMJBusinessType)type;

/// 本地对应业务资源文件夹路径，当本地资源缺失时，返回结果为nil
/// @param type 业务类型
+ (nullable NSString *)assetPathWithType:(MMJBusinessType)type;

/// 本地对应业务资源版本号，当本地资源缺失时，返回结果为nil
/// @param type 业务类型
+ (nullable NSString *)assetVersionStringWithType:(MMJBusinessType)type;

/// 清除本地所有资源
+ (BOOL)clearAllAssets;

@end

NS_ASSUME_NONNULL_END
