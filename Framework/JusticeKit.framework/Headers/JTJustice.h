//
//  JTJustice.h
//  JusticeKit
//
//  Created by MOMO on 2019/8/13.
//  Copyright © 2019 bfj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(9.0)) // ios9.0以上支持
@interface Justice : NSObject 

///**
// 初始化对象
//
// @return Justice对象，未加载模型
// */
//- (instancetype)init;

/**
 初始化对象
 根据业务名称和配置路径
 
 @param business 业务名
 @param directory 模型配置路径
 @return Justice对象
 */
- (instancetype)initWithConfigDirectory:(NSString *)directory
                            andBusiness:(NSString *)business
                                  error:(NSError * _Nullable *)error
    NS_SWIFT_NAME(init(business:configDirectory:error:));


/**
 多业务对象初始化，所有资源放在同一个目录中

 @param directory 模型与配置文件目录，所有业务资源放在同一目录内
 @param businesses 业务列表 NSArray<NSString *> * businesses
 @param error 错误检测
 @return Justice对象
 */
- (instancetype)initWithConfigDirectory:(NSString *)directory
                          andBusinesses:(NSArray<NSString*> *)businesses
                                  error:(NSError *__autoreleasing  _Nullable *)error
    NS_SWIFT_NAME(init(configDirectory:businesses:error:));

/**
 多业务对象初始化，不同业务资源单独存放
 
 @param businessesWithDirs 业务和资源目录数组
 @param error 错误处理
 @return Justice obj
 */
- (instancetype)initWithBusinesses:(NSArray<NSArray<NSString*>*> *) businessesWithDirs
                             error:(NSError *__autoreleasing  _Nullable *)error
    NS_SWIFT_NAME(init(businesses:error:));

#pragma mark - API

/**
 预测结果，预测之前需初始化模型或加载模型
 
 @param uiimage UIImage图像，需要有CGImage属性
 @return 预测结果，格式为json字符串
 */
- (NSString *)predict:(UIImage *)uiimage NS_SWIFT_NAME(predict(uiimage:));
/**
 预测，输入CVPixelBufferRef
 
 @param pixelbuffer CVPixelBufferRef
 @return 预测结果，格式为json字符串
 */
- (NSString *)predictWithPixelbuffer:(CVPixelBufferRef)pixelbuffer
    NS_SWIFT_NAME(predict(pixelbuffer:));


/**
 设置模型运行使用核数

 @param num 需要设置的核心数
 */
- (void)setNumThreads:(NSUInteger)num NS_SWIFT_NAME(setNumThreads(num:));

@end


@interface Justice (JusticeCreation)

/// 初始化对象
/// @param directory 资源目录
/// @param business 业务名称，对应资源目录中的配置x
/// @param error 错误记录
+ (instancetype)justiceWithConfigDirectory:(NSString *)directory
                               andBusiness:(NSString *)business
                                     error:(NSError * _Nullable *)error;

/// 多业务对象初始化，所有资源放在同一个目录
/// @param directory 资源目录
/// @param businesses 业务列表
/// @param error 错误记录
+ (instancetype)justiceWithConfigDirectory:(NSString *)directory
                             andBusinesses:(NSArray<NSString*> *)businesses
                                     error:(NSError * _Nullable *)error;

/// 多业务对象初始化，不同业务资源放在不同目录
/// @param businessesWithDirs 业务和资源目录列表
/// @param error 错误记录
+ (instancetype)justiceWithBusinesses:(NSArray<NSArray<NSString*>*> *) businessesWithDirs
                                error:(NSError *__autoreleasing  _Nullable *)error;

@end


NS_ASSUME_NONNULL_END
