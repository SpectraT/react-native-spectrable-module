//
//  NSData+AES256.h
//  Spectra Mobile Access
//
//  Created by Spectra-mac1 on 06/04/18.
//  Copyright © 2018 Spectra Tech Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

#include "iconv.h"

@interface NSData (AES256)

- (NSString*)hexRepresentationWithSpaces_AS;


@end
