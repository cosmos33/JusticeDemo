//
//  MMJResultInfo.m
//  MMJusticeCenter
//
//  Created by MOMO on 2019/11/26.
//

#import "MMJResultInfo.h"

@implementation MMJResultInfo

+ (instancetype)resultInfoWithResult:(BOOL)result error:(NSError *)error defultCode:(MMJErrorCode)defultCode {
    MMJResultInfo *info = [[self class] new];
    info.result = result;
    if (!result) {
        if ([error.domain isEqualToString:MMJusticeCenterDomain]) {
            info.errorCode = error.code;
        } else {
            info.errorCode = defultCode;
        }
    }
    return info;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ result=%d, errorCode=%ld", [self class], self.result, (long)self.errorCode];
}

@end
