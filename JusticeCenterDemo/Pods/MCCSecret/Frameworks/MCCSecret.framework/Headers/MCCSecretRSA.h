/*
 @author: ideawu
 @link: https://github.com/ideawu/Objective-C-RSA
*/

#import <Foundation/Foundation.h>

@interface MCCSecretRSA : NSObject

// return base64 encoded string
+ (NSString *)mcc_encryptString:(NSString *)str publicKey:(NSString *)pubKey;
// return raw data
+ (NSData *)mcc_encryptData:(NSData *)data publicKey:(NSString *)pubKey;
// return base64 encoded string
// enc with private key NOT working YET!
//+ (NSString *)mcc_encryptString:(NSString *)str privateKey:(NSString *)privKey;
// return raw data
//+ (NSData *)mcc_encryptData:(NSData *)data privateKey:(NSString *)privKey;

// decrypt base64 encoded string, convert result to string(not base64 encoded)
+ (NSString *)mcc_decryptString:(NSString *)str publicKey:(NSString *)pubKey;
+ (NSData *)mcc_decryptData:(NSData *)data publicKey:(NSString *)pubKey;
+ (NSString *)mcc_decryptString:(NSString *)str privateKey:(NSString *)privKey;
+ (NSData *)mcc_decryptData:(NSData *)data privateKey:(NSString *)privKey;

@end
