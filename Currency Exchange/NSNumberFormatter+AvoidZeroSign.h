//
//  NSNumberFormatter+AvoidZeroSign.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 23.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumberFormatter (AvoidZeroSign)

- (NSString *)stringFromNumberAvoidingZeroSign:(NSDecimalNumber *)number;

@end
