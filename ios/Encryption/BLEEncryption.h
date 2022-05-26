//
//  BLEEncryption.h


#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface BLEEncryption : NSObject

#pragma mark -
#pragma mark - BLE Commands

+ (NSString*)punchCommand;


#pragma mark -
#pragma mark - Encryption/Decryption

+ (NSData*)AES128Encrypt:(NSData *)dataToEncrypt;
+ (NSData*)AES128Decrypt:(NSData *)dataToDecrypt;

#pragma mark -
#pragma mark - Common Methods


+ (void)setEncryptionKey:(NSString* )key;
+ (void)setPeriphearalId:(NSString* )peripheralId;
+ (void)setTagId:(NSString* )tagId;
+ (void)setDeviceType:(NSString* )deviceType;
+ (void)setDeviceData:(NSData* )data;
+ (NSData*)hexToBytes: (NSString*)strKey;
+ (void)setDestinationFloor: (NSString*)floorNumber;
+ (void)setBoardingFloor: (NSString*)floorNumber;
+ (void)setSelectedFloor: (NSString*)floorNumber;




@end
