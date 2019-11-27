//
//  MNRequestOperation.h
//  MMNNetwork
//
//  Created by MOMO on 2019/7/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNRequestOperation : NSOperation

@property (nonatomic, strong, nullable) void(^uploadProgressBlock)(NSProgress *progress);
@property (nonatomic, strong, nullable) void(^downloadProgressBlock)(NSProgress *progress);
@property (nonatomic, strong, nullable) NSURLSessionTask *sessionTask;

@end

NS_ASSUME_NONNULL_END
