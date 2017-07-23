//
//  CurrencyConverter.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyConverter.h"

@implementation CurrencyConverter

- (NSDecimalNumber *)value:(NSDecimalNumber *)value
                inCurrency:(Currency *)currency
               convertedTo:(Currency *)secondCurrency
              rateProvider:(CurrencyRateProvider *)provider
                roundScale:(NSInteger)scale {

    if ([currency isEqual:secondCurrency])
        return value;

    NSDecimalNumber *firstRate = [provider rateForCurrency:currency];
    NSDecimalNumber *secondRate = [provider rateForCurrency:secondCurrency];

    if (!firstRate || !secondRate) return nil;

    NSDecimalNumber *result = [[value decimalNumberByDividingBy:firstRate] decimalNumberByMultiplyingBy:secondRate];

    NSDecimal decimalBeforeRounding = [result decimalValue];
    NSDecimal decimalAfterRounding;

    NSDecimalRound(&decimalAfterRounding, &decimalBeforeRounding, scale, NSRoundBankers);

    return [NSDecimalNumber decimalNumberWithDecimal:decimalAfterRounding];
}


@end
