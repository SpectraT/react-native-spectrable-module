//
//  NSData+AES256.m
//  Spectra Mobile Access
//
//  Created by Spectra-mac1 on 06/04/18.
//  Copyright © 2018 Spectra Tech Pvt. Ltd. All rights reserved.
//

#import "NSData+AES256.h"

@implementation NSData (AES256)

- (NSString*)hexRepresentationWithSpaces_AS
{
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
    {
        return [NSString string];
    }
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
    {
        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }
    
    return [NSString stringWithString:hexString];
}



@end
