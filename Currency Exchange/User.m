//
//  User.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "User.h"
#import "CurrencyConverter.h"

@implementation User

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *keys = @[[Currency eurCurrency], [Currency usdCurrency], [Currency gbpCurrency]];
        NSArray *objects = @[@100, @100, @100];
        _balance = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    }
    return self;
}

- (BOOL)performTransactionFromCurrency:(Currency *)fromCurrency
                                    to:(Currency *)toCurrency
                  valueInFirstCurrency:(double)value
                          rateProvider:(CurrencyRateProvider *)provider {

    if ([fromCurrency isEqual:toCurrency]) { return YES; }

    double fromBalance = [self.balance[fromCurrency] doubleValue];
    double toBalance = [self.balance[toCurrency] doubleValue];

    if (fromBalance < value) { return NO; }

    CurrencyConverter *converter = [[CurrencyConverter alloc] init];

    double toCurrencyValue = [converter value:value inCurrency:fromCurrency convertedTo:toCurrency rateProvider:provider];

    fromBalance -= value;
    toBalance += toCurrencyValue;

    NSMutableDictionary *mutableBalance = [self.balance mutableCopy];
    mutableBalance[fromCurrency] = [NSNumber numberWithDouble:fromBalance];
    mutableBalance[toCurrency] = [NSNumber numberWithDouble:toBalance];

    _balance = [NSDictionary dictionaryWithDictionary:mutableBalance];
    return YES;
}

- (BOOL)canPerformTransactionFromCurrency:(Currency *)fromCurrency
                                    to:(Currency *)toCurrency
                  valueInFirstCurrency:(double)value
                          rateProvider:(CurrencyRateProvider *)provider {

    if ([fromCurrency isEqual:toCurrency]) { return NO; }

    double fromBalance = [self.balance[fromCurrency] doubleValue];

    if (fromBalance < value) { return NO; }

    CurrencyConverter *converter = [[CurrencyConverter alloc] init];
    double toCurrencyValue = [converter value:value inCurrency:fromCurrency convertedTo:toCurrency rateProvider:provider];

    if (toCurrencyValue < 0.01 || value < 0.01) { return NO; }

    return YES;
}

@end
