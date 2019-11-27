//
//  MMJFileManager.m
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

/************************************************************************
                                文件目录结构
*************************************************************************
**  |-- Documents
**     |
**     |-- com.momo.justiceCenter
**         |
**         |-- Business1
**         |   |
**         |   |-- V1（文件夹以资源版本号命名，同时只会存在一个，当有新的版本下载
**         |   |       并解压完立即删除旧版本）
**         |   |
**         |   |-- temp.zip（对应资源的压缩包放这里，解压完立即删除）
**         |
**         |-- Business2
**             |
**             |-- V1
**
*************************************************************************
*/

#import "MMJFileManager.h"
#if __has_include(<MMFoundation/MDZipArchive.h>)
#import <MMFoundation/MDZipArchive.h>
#elif __has_include("SSZipArchive.h")
#import "SSZipArchive.h"
#else
#import "ZipArchive.h"
#endif

/// 全局文件操作锁
static dispatch_semaphore_t file_processing_lock() {
    static dispatch_semaphore_t mm_file_processing_lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mm_file_processing_lock = dispatch_semaphore_create(1);
    });
    return mm_file_processing_lock;
}

static void file_safe_process(void(^block)(void)) {
    dispatch_semaphore_wait(file_processing_lock(), DISPATCH_TIME_FOREVER);
    block();
    dispatch_semaphore_signal(file_processing_lock());
}

static NSString * const kMMJFileDomain = @"com.momo.justiceCenter";

@implementation MMJFileManager

+ (NSString *)rootPath {
    static NSString *_rootPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _rootPath = [path stringByAppendingPathComponent:kMMJFileDomain];
    });
    return _rootPath;
}

+ (BOOL)creatDirectoryIfNeetAtPath:(NSString *)path {
    __block BOOL ret = YES;
    file_safe_process(^{
        ret = [self _creatDirectoryIfNeetAtPath:path];
    });
    return ret;
}

+ (BOOL)removeFileIfNeetAtPath:(NSString *)path {
    __block BOOL ret = YES;
    file_safe_process(^{
        ret = [self _removeFileIfNeetAtPath:path];
    });
    return ret;
}

+ (BOOL)unzipFileAtPath:(NSString *)path
          toDestination:(NSString *)destination
              overwrite:(BOOL)overwrite
               password:(NSString *)password
                  error:(NSError *__autoreleasing  _Nullable *)error {
    __block BOOL ret = NO;
    file_safe_process(^{
        [[self class] _removeFileIfNeetAtPath:destination];
        [[self class] _creatDirectoryIfNeetAtPath:destination];
#if __has_include(<MMFoundation/MDZipArchive.h>)
        MDZipArchive *zipArchive = [MDZipArchive new];
        if ([zipArchive UnzipOpenFile:path Password:password]) {
            ret = [zipArchive UnzipFileTo:destination overWrite:overwrite];
            [zipArchive UnzipCloseFile];
        }
        if (!ret) {
            *error = [NSError errorWithDomain:@"ZipArchiveErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"failed to unzip file"}];
            NSLog(@"[MMJusticeCenter] [LOG_LEVEL = ERROR] unzip file failed");
        }
#elif __has_include("SSZipArchive.h")
        ret = [SSZipArchive unzipFileAtPath:path toDestination:destination overwrite:overwrite password:password error:error];
        if (!ret) {
            NSLog(@"[MMJusticeCenter] [LOG_LEVEL = ERROR] unzip file failed error:%@", *error);
        }
#else
        ZipArchive *zipArchive = [ZipArchive new];
        if ([zipArchive UnzipOpenFile:path Password:password]) {
            ret = [zipArchive UnzipFileTo:destination overWrite:overwrite];
            [zipArchive UnzipCloseFile];
        }
        if (!ret) {
            *error = [NSError errorWithDomain:@"ZipArchiveErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"failed to unzip file"}];
            NSLog(@"[MMJusticeCenter] [LOG_LEVEL = ERROR] unzip file failed");
        }
#endif
        [[self class] _removeFileIfNeetAtPath:path];
    });
    return ret;
}

+ (NSString *)appendAssetPathWithType:(MMJBusinessType)type version:(NSString *)version {
    NSString *path = [self businessDirectoryPathWithType:type];
    return [path stringByAppendingPathComponent:version];
}

+ (BOOL)isExistAssetWithType:(MMJBusinessType)type {
    __block BOOL ret = YES;
    file_safe_process(^{
        ret = !![self _assetVersionStringWithType:type].length;
    });
    return ret;
}

+ (NSString *)businessDirectoryPathWithType:(MMJBusinessType)type {
    return [[self rootPath] stringByAppendingPathComponent:type];
}

+ (NSString *)assetPathWithType:(MMJBusinessType)type {
    __block NSString *path = nil;
    file_safe_process(^{
        path = [self _assetPathWithType:type];
    });
    return path;
}

+ (NSString *)assetVersionStringWithType:(MMJBusinessType)type {
    __block NSString *versionString = nil;
    file_safe_process(^{
        versionString = [self _assetVersionStringWithType:type];
    });
    return versionString;
}

+ (BOOL)clearAllAssets {
    return [self removeFileIfNeetAtPath:[self rootPath]];
}

+ (NSString *)_assetPathWithType:(MMJBusinessType)type {
    NSString *path = [self businessDirectoryPathWithType:type];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        return nil;
    }
    if (isDirectory) {
        NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:nil];
        NSString * fileName = files.lastObject;
        if (fileName.length) {
            NSString *assetPath = [path stringByAppendingPathComponent:fileName];
            if ([self _fileExistsAtPath:assetPath]) {
                return assetPath;
            }
        }
    }
    return nil;
}

+ (NSString *)_assetVersionStringWithType:(MMJBusinessType)type {
    NSString *path = [self businessDirectoryPathWithType:type];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        return nil;
    }
    if (isDirectory) {
        NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:nil];
        NSString * fileName = files.lastObject;
        if (fileName.length && [self _fileExistsAtPath:[path stringByAppendingPathComponent:fileName]]) {
            return fileName;
        }
    }
    return nil;
}

+ (BOOL)_fileExistsAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        return NO;
    }
    if (isDirectory) {
        NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:nil];
        if (files.count) {
            return YES;
        }
        return NO;
    }
    return YES;
}


+ (BOOL)_creatDirectoryIfNeetAtPath:(NSString *)path {
    BOOL ret = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        ret = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"[MMJusticeCenter] [LOG_LEVEL = ERROR] creat directory error %@", error);
        }
    }
    return ret;
}

+ (BOOL)_removeFileIfNeetAtPath:(NSString *)path {
    BOOL ret = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        ret = [fileManager removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"[MMJusticeCenter] [LOG_LEVEL = ERROR] remove file error %@", error);
        }
    }
    return ret;
}

@end
