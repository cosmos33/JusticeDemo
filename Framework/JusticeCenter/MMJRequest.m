//
//  MMJRequest.m
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

#import "MMJRequest.h"
#import "NSDictionary+MMJSafe.h"
#import "NSData+MMJHash.h"
#import "MNBaseRequest+Extension.h"
#import "MMJCenterConfig.h"
#import "MMJFileManager.h"
#import <MCCSecret/MCCSecret-umbrella.h>

#define PUBLIC_KEY @"MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKbj7WvmhEVXZbeqvMGXdMDvGlD6/Aa/MRxkhtUzdMBtB1FzUGOs77Yo7Es3cxt4HQGrioAaPXCyNC4KX1L8qdcCAwEAAQ=="

static NSString *mn_letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
static NSString *randomString(int len) {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [mn_letters characterAtIndex: arc4random_uniform(62)]];
    }
    return randomString;
}

@interface MMJConfigRequest ()

@property (nonatomic, strong) NSString *aesKey;

@end

@implementation MMJConfigRequest

- (instancetype)initWithAppId:(NSString *)appId {
    self = [super init];
    if (self) {
        _serviceUrl = @"video/index/spamResource";
        [self secretParameters:@{@"resourceMark": @"spam",
                                 @"appId": appId ? : @""}
                         error:nil];
    }
    return self;
}

- (void)receivedResponse:(NSDictionary *)responseObject error:(NSError * _Nullable __autoreleasing *)error {
    if (![responseObject isKindOfClass:NSDictionary.class]) {
        if (error) {
            *error = [NSError mnResponseFormatError];
        }
        return;
    }
    
    NSError *ec = [self errorWithResponse:responseObject];
    if (error) {
        *error = ec;
    }
    if (ec) {
        return;
    }
    
    [self subHandleResponse:responseObject[@"data"] error:error];
}

- (NSError *)errorWithResponse:(NSDictionary *)response {
    NSInteger errorCode = [response mmj_integerForKey:@"ec" defaultValue:NSURLErrorCannotDecodeContentData];
    if (!errorCode) {
        return nil;
    }
    return [NSError errorWithDomain:MNRequestDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: response[@"em"] ? : response.description}];
}

- (void)subHandleResponse:(NSDictionary *)responseObject error:(NSError * _Nullable __autoreleasing *)error {
    if (![responseObject isKindOfClass:NSDictionary.class]) {
        if (error) {
            *error = [NSError mnResponseFormatError];
        }
        return;
    }
    
    NSDictionary *dataDictionary = [self warpperDataDictionary:responseObject andAesKey:self.aesKey];
    
    NSDictionary *resources = [dataDictionary mmj_dictionaryForKey:@"resources" defaultValue:@{}];
    NSMutableDictionary *resourcesDic = [NSMutableDictionary dictionaryWithCapacity:resources.count];
    [resources enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:NSArray.class]) {
            return;
        }
        NSDictionary *first = obj.firstObject;
        if (!first) {
            return;
        }
        
        MMJAssetConfig *assetConfig = [MMJAssetConfig new];
        assetConfig.md5 = [first mmj_stringForKey:@"md5" defaultValue:@""];
        assetConfig.guid = [first mmj_stringForKey:@"guid" defaultValue:@""];
        assetConfig.suffix = [first mmj_stringForKey:@"suffix" defaultValue:@""];
        assetConfig.version = [first mmj_stringForKey:@"version" defaultValue:@""];
        assetConfig.size = [first mmj_doubleForKey:@"size" defaultValue:0];
        assetConfig.businessMark = [first mmj_stringForKey:@"businessMark" defaultValue:@""];
        assetConfig.url = [first mmj_stringForKey:@"url" defaultValue:@""];
        assetConfig.materialVersion = [first mmj_stringForKey:@"materialVersion" defaultValue:@""];
        assetConfig.sha1 = [first mmj_stringForKey:@"sha1" defaultValue:@""];
        assetConfig.sign = [first mmj_stringForKey:@"sign" defaultValue:@""];
        
        [resourcesDic setObject:assetConfig forKey:key];
    }];
    
    NSArray *sceneLists = [dataDictionary mmj_arrayForKey:@"sceneLists" defaultValue:@[]];
    NSMutableDictionary *sceneListsDic = [NSMutableDictionary dictionaryWithCapacity:sceneLists.count];
    [sceneLists enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [obj mmj_stringForKey:@"name" defaultValue:@""];
        NSArray *list = [obj mmj_arrayForKey:@"scene" defaultValue:@[]];
        if (name.length && list.count) {
            [sceneListsDic setObject:list forKey:name];
        }
    }];
    
    self.resourcesConfig = resourcesDic.copy;
    self.sceneListsConfig = sceneListsDic.copy;
}

#pragma mark - 加解密
// 加密请求参数
- (void)secretParameters:(NSDictionary *)parameters error:(NSError *__autoreleasing  _Nullable *)error {
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:error];
    if (!data) {
        return;
    }
    
    NSString *aesKey = randomString(8);
    NSString *base64Data = [NSString mcc_base64StringFromData:data length:[data length]];
    NSString *mscStr = [MCCSecretRSA mcc_encryptString:aesKey publicKey:PUBLIC_KEY];
    NSString *mzipStr = [MCCSecretAESCrypt mcc_encrypt:base64Data password:aesKey];
    
    _aesKey = aesKey;
    _requestParameters = @{@"msc" : mscStr ? : @"",
                           @"mzip" : mzipStr ? : @""};
}

// 解密响应结果
- (NSDictionary *)warpperDataDictionary:(NSDictionary *)dict andAesKey:(NSString *)aesKey {
    NSString *dataStr = [dict mmj_stringForKey:@"mzip" defaultValue:@""];
    NSString *desStr = [MCCSecretAESCrypt mcc_decrypt:dataStr password:aesKey];
    return desStr.length ? [NSJSONSerialization JSONObjectWithData:[desStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil] : nil;
}

@end

@implementation MMJDownloadRequest

- (instancetype)initWithConfig:(MMJAssetConfig *)config filePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _requestMethod = MNRequestDownload;
        _serviceUrl = config.url;
        _md5 = config.md5;
        _downloadDestinationBlock = ^(NSURL *targetPath, NSURLResponse *response) {
            NSString *directory = [filePath stringByDeletingLastPathComponent];
            [MMJFileManager removeFileIfNeetAtPath:filePath];
            [MMJFileManager creatDirectoryIfNeetAtPath:directory];
            return [NSURL fileURLWithPath:filePath];;
        };
    }
    return self;
}

- (void)handleDowloadFilePath:(NSURL *)filePath error:(NSError *)error {
    _filePath = filePath;
    if (error) {
        NSLog(@"[MMJusticeCenter] [LOG_LEVEL = ERROR] Service Url: %@ \n %@", self.serviceUrl, error);
        if (self.completionBlock) {
            self.completionBlock(self, error);
        }
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfURL:filePath];
    NSString *md5 = data.mmj_MD5;
    if (![md5 isEqualToString:self.md5]) {
        error = [NSError errorWithDomain:MMJusticeCenterDomain code:MMJErrorCodeFileException userInfo:@{NSLocalizedDescriptionKey: @"文件问题可能被篡改"}];;
        [MMJFileManager removeFileIfNeetAtPath:filePath.relativePath];
        NSLog(@"[MMJusticeCenter] [LOG_LEVEL = ERROR] md5 error, url: %@ serviceMd5: %@ localMd5: %@", _serviceUrl, _md5, md5);
    }
    
    if (self.completionBlock) {
        self.completionBlock(self, error);
    }
}

@end
