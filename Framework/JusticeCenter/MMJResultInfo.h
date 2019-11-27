//
//  MMJResultInfo.h
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/26.
//

#import <Foundation/Foundation.h>
#import "MMJusticeConstant.h"

NS_ASSUME_NONNULL_BEGIN

/// 结果信息类
/// 功能：记录资源准备的结果
@interface MMJResultInfo : NSObject

@property (nonatomic, assign) BOOL result;

@property (nonatomic, assign) MMJErrorCode errorCode;

+ (instancetype)resultInfoWithResult:(BOOL)result error:(NSError * _Nullable)error defultCode:(MMJErrorCode)defultCode;

@end

NS_ASSUME_NONNULL_END
