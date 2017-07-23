//
//  NSDecimalNumber+absoluteValue.m
//  
//
//  Created by Ilya Velilyaev on 23.07.17.
//
//

#import "NSDecimalNumber+absoluteValue.h"

@implementation NSDecimalNumber (absoluteValue)

-(NSDecimalNumber *)absoluteValue {

    if (!([self compare:[NSDecimalNumber zero]] == NSOrderedDescending)) {

        NSDecimalNumber * negativeOne = [NSDecimalNumber decimalNumberWithMantissa:1
                                                                          exponent:0
                                                                        isNegative:YES];
        return [self decimalNumberByMultiplyingBy:negativeOne];
    }

    return self;
}

-(NSDecimalNumber *)negativeAbsoluteValue {

    if (!([self compare:[NSDecimalNumber zero]] == NSOrderedAscending)) {

        NSDecimalNumber * negativeOne = [NSDecimalNumber decimalNumberWithMantissa:1
                                                                          exponent:0
                                                                        isNegative:YES];
        return [self decimalNumberByMultiplyingBy:negativeOne];
    }

    return self;
}

@end
