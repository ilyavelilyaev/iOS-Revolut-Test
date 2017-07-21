//
//  CurrencyConverter.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyConverter.h"

@implementation CurrencyConverter

- (double)value:(double)value
     inCurrency:(Currency *)currency
    convertedTo:(Currency *)secondCurrency
   rateProvider:(CurrencyRateProvider *)provider {

    if ([currency isEqual:secondCurrency])
        return value;

    double firstRate = [[provider rateForCurrency:currency] doubleValue];
    double secondRate = [[provider rateForCurrency:secondCurrency] doubleValue];

    return value / firstRate * secondRate;
}


@end
