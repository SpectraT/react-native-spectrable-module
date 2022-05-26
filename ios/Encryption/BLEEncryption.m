//
//  BLEEncryption.m

#import "BLEEncryption.h"
#import <UIKit/UIKit.h>

#define CXPReader  @"01"
#define CBioStamp3S @"03"
#define CBioScribe3S @"04"
#define CDefaultEncryptionKey @"36e4f31ccc16914a210f466e0e636f85"


static NSString *strEncryptionKey = nil;
static NSString *strPeripheralId = nil;
static NSString *strTagId = nil;
static NSString *strDeviceType = nil;
static NSData *deviceData = nil;

static NSString *destinationFloor = nil;
static NSString *boardingFloor = nil;
static NSString *selectedFloor = nil;


@implementation BLEEncryption

#pragma mark -
#pragma mark - BLE Commands

+ (NSString*)punchCommand {
    
    unsigned int iTagId = 0;
    unsigned int iDestFloor = 0;
    unsigned int iBoardFloor = 0;
    unsigned int iSelecFloor = 0;
    
    iTagId = [strTagId intValue];
    iDestFloor = [destinationFloor intValue];
    iBoardFloor = [boardingFloor intValue];
    iSelecFloor = [selectedFloor intValue];
    
    
    int8_t tagBytes[7];
    
    tagBytes[0] = iTagId&0xFF;
    tagBytes[1] = (iTagId>>8)&0xFF;
    tagBytes[2] = (iTagId>>16)&0xFF;
    tagBytes[3] = (iTagId>>24)&0xFF;
    tagBytes[4] = iDestFloor;
    tagBytes[5] = iBoardFloor;
    tagBytes[6] = iSelecFloor;
    
    uint8_t arrBytes[32];
    memset(arrBytes, 0, sizeof(arrBytes));
    
    arrBytes[0] = 0xAA;   //write header
    arrBytes[1] = 20;   //total length LSB
    arrBytes[2] = 0;   //total length MSB
    arrBytes[3] = 1;   //Command : 1, Response : 2
    arrBytes[4] = 1; // RFU
    arrBytes[5] = 1; //Read : 0, Write : 1
    arrBytes[6] = 0xB0; // Function Code
    arrBytes[7] = 1; // Response required, Error code
    arrBytes[8] = sizeof(tagBytes); // Payload Length LSB
    arrBytes[9] = (sizeof(tagBytes) >> 8) & 0xFF; // Paylaod Length MSB
    
    int p=10;
    memcpy(&arrBytes[p], tagBytes, sizeof(tagBytes));
    p = p + sizeof(tagBytes);
    
    arrBytes[p] = [self calculateLRC:arrBytes length:p];
    
    p++;
    
    arrBytes[p++] = 0xBB;   // fixed 0xBB footer
    
    NSData *dataToEncrypt = [NSData dataWithBytes:arrBytes length:sizeof(arrBytes)];

    dataToEncrypt = [self AES128Encrypt:dataToEncrypt];
    
    NSString *strResult = @"";
    
    if (dataToEncrypt) {
        strResult = [dataToEncrypt base64EncodedStringWithOptions:kNilOptions];
    }
    
    return strResult;
}

+ (uint8_t)calculateLRC:(uint8_t *)dataPtr length:(uint16_t)length {
    
    uint8_t i=0;
    uint8_t retval;
    
    retval = 0;
    for (i = 0; i<length; i++)
    {
        retval = dataPtr[i] ^ retval; // LRC
    }
    return retval;
}

+ (NSData*)AES128Encrypt:(NSData *)dataToEncrypt {
    
    NSData *keyData = [self hexToBytes: strEncryptionKey];
    
    NSData* manufData = deviceData;
    
    NSUInteger len = [manufData length];
    
    int8_t manufBytes[len];
    memcpy(manufBytes, [manufData bytes], len);
    
    int8_t ivBytes[16];
    memset(ivBytes, 0, sizeof(ivBytes));
    
    ivBytes[0] = manufBytes[2];
    ivBytes[1] = manufBytes[3];
    
    NSData *keyDataBytes;
    
    if (ivBytes[0] == 0 && ivBytes[1] == 0) {
        keyDataBytes = [self hexToBytes: CDefaultEncryptionKey];
    } else {
        keyDataBytes = keyData;
    }
    
    int8_t keyBytes[16];
    memcpy(keyBytes, [keyDataBytes bytes], 16);
    
    NSUInteger dataLength = [dataToEncrypt length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          ccNoPadding,
                                          keyBytes,
                                          kCCBlockSizeAES128,
                                          ivBytes,
                                          [dataToEncrypt bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess)
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    
    free(buffer);
    return nil;
    
}

+ (NSData*)AES128Decrypt:(NSData *)dataToDecrypt {
    
    NSData *keyData = [self hexToBytes: strEncryptionKey];
    
    NSData* manufData = deviceData;
    
    int8_t keyBytes[16];
    memcpy(keyBytes, [keyData bytes], 16);
    
    NSUInteger len = [manufData length];
    
    int8_t manufBytes[len];
    memcpy(manufBytes, [manufData bytes], len);
    
    int8_t ivBytes[16];
    memset(ivBytes, 0, sizeof(ivBytes));
    
    ivBytes[0] = manufBytes[2];
    ivBytes[1] = manufBytes[3];
    
    NSUInteger dataLength = [dataToDecrypt length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          ccNoPadding,
                                          keyBytes,
                                          kCCBlockSizeAES128,
                                          ivBytes,
                                          [dataToDecrypt bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess)
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    
    free(buffer);
    return nil;
}

    
#pragma mark -
#pragma mark - Set device parameters:

+ (void)setEncryptionKey:(NSString* )key {
    strEncryptionKey = key;
}

+ (void)setPeriphearalId:(NSString* )peripheralId {
    strPeripheralId = peripheralId;
}

+ (void)setTagId:(NSString* )tagId {
    strTagId = tagId;
}

+ (void)setDeviceType:(NSString* )deviceType {
    strDeviceType = deviceType;
}

+ (void)setDeviceData:(NSData* )data {
    deviceData = data;
}

+ (void)setDestinationFloor: (NSString*)floorNumber {
    destinationFloor = floorNumber;
}

+ (void)setBoardingFloor: (NSString*)floorNumber {
    boardingFloor = floorNumber;
}

+ (void)setSelectedFloor: (NSString*)floorNumber {
    selectedFloor = floorNumber;
}




#pragma mark -
#pragma mark - Hex to Bytes:


+ (NSData*)hexToBytes:(NSString*) strKey {
    
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= strKey.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [strKey substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}



@end
