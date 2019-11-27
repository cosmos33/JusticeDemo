//
//  MMJusticeConstant.h
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString* MMJBusinessType;
typedef NSString* MMJSceneId;

OBJC_EXTERN NSString * const MMJusticeCenterDomain;

typedef NS_ERROR_ENUM(MMJusticeCenterDomain, MMJErrorCode) {
    MMJErrorCodeUnsupportedConfiguration = -1, // config解析出错
    MMJErrorCodeDownloadFailed = -2,           // 下载失败
    MMJErrorCodeFileException = -3,            // 文件异常
    MMJErrorCodeUnzipFailed = -4,              // 解压失败
};

NS_ASSUME_NONNULL_END
