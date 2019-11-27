/*
 *  NSData+MoPushCommonCrypto.h
 *  AQToolkit
 *
 *  Created by Jim Dovey on 31/8/2008.
 *
 *  Copyright (c) 2008-2009, Jim Dovey
 *  All rights reserved.
 *  
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  Redistributions of source code must retain the above copyright notice,
 *  this list of conditions and the following disclaimer.
 *  
 *  Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *  
 *  Neither the name of this project's author nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
 *  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 *  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

extern NSString * const kMCCSecretCommonCryptoErrorDomain;

@interface NSError (MCCSecretCommonCryptoErrorDomain)
+ (NSError *) mcc_errorWithCCCryptorStatus: (CCCryptorStatus) status;
@end

@interface NSData (MCCSecretCommonDigest)

- (NSData *) mcc_MD2Sum;
- (NSData *) mcc_MD4Sum;
- (NSData *) mcc_MD5Sum;

- (NSData *) mcc_SHA1Hash;
- (NSData *) mcc_SHA224Hash;
- (NSData *) mcc_SHA256Hash;
- (NSData *) mcc_SHA384Hash;
- (NSData *) mcc_SHA512Hash;

@end

@interface NSData (MCCSecretCommonCryptor)

- (NSData *) mcc_AES256EncryptedDataUsingKey: (id) key error: (NSError **) error;
- (NSData *) mcc_decryptedAES256DataUsingKey: (id) key error: (NSError **) error;

- (NSData *) mcc_DESEncryptedDataUsingKey: (id) key error: (NSError **) error;
- (NSData *) mcc_decryptedDESDataUsingKey: (id) key error: (NSError **) error;

- (NSData *) mcc_CASTEncryptedDataUsingKey: (id) key error: (NSError **) error;
- (NSData *) mcc_decryptedCASTDataUsingKey: (id) key error: (NSError **) error;

@end

@interface NSData (MCCSecretLowLevelCommonCryptor)

- (NSData *) mcc_dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                                   error: (CCCryptorStatus *) error;
- (NSData *) mcc_dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                                 options: (CCOptions) options
                                   error: (CCCryptorStatus *) error;
- (NSData *) mcc_dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                    initializationVector: (id) iv		// data or string
                                 options: (CCOptions) options
                                   error: (CCCryptorStatus *) error;

- (NSData *) mcc_decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                                   error: (CCCryptorStatus *) error;
- (NSData *) mcc_decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                                 options: (CCOptions) options
                                   error: (CCCryptorStatus *) error;
- (NSData *) mcc_decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                    initializationVector: (id) iv		// data or string
                                 options: (CCOptions) options
                                   error: (CCCryptorStatus *) error;

@end

@interface NSData (MCCSecretCommonHMAC)

- (NSData *) mcc_HMACWithAlgorithm: (CCHmacAlgorithm) algorithm;
- (NSData *) mcc_HMACWithAlgorithm: (CCHmacAlgorithm) algorithm key: (id) key;

@end
