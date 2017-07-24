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

        NSDecimalNumber  *hundred = [NSDecimalNumber decimalNumberWithString:@"100"];
        NSArray *objects = @[hundred, [hundred copy], [hundred copy]];

        _balance = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    }
    return self;
}

- (BOOL)performTransactionFromCurrency:(Currency *)fromCurrency
                                    to:(Currency *)toCurrency
                  valueInFirstCurrency:(NSDecimalNumber *)value
                          rateProvider:(CurrencyRateProvider *)provider {

    if ([fromCurrency isEqual:toCurrency]) { return YES; }

    NSDecimalNumber *fromBalance = self.balance[fromCurrency];
    NSDecimalNumber *toBalance = self.balance[toCurrency];

    if ([fromBalance compare:value] == NSOrderedAscending) { return NO; }

    CurrencyConverter *converter = [[CurrencyConverter alloc] init];

    NSDecimalNumber *toCurrencyValue = [converter value:value inCurrency:fromCurrency convertedTo:toCurrency rateProvider:provider roundScale:2];

    fromBalance = [fromBalance decimalNumberBySubtracting:value];
    toBalance = [toBalance decimalNumberByAdding:toCurrencyValue];

    NSMutableDictionary *mutableBalance = [self.balance mutableCopy];
    mutableBalance[fromCurrency] = fromBalance;
    mutableBalance[toCurrency] = toBalance;

    _balance = [NSDictionary dictionaryWithDictionary:mutableBalance];
    return YES;
}

- (BOOL)canPerformTransactionFromCurrency:(Currency *)fromCurrency
                                    to:(Currency *)toCurrency
                  valueInFirstCurrency:(NSDecimalNumber *)value
                          rateProvider:(CurrencyRateProvider *)provider {

    if ([fromCurrency isEqual:toCurrency]) { return NO; }

    NSDecimalNumber *fromBalance = self.balance[fromCurrency];

    if ([fromBalance compare:value] == NSOrderedAscending) { return NO; }

    CurrencyConverter *converter = [[CurrencyConverter alloc] init];
    NSDecimalNumber *fromValueInUSD = [converter value:value
                                            inCurrency:fromCurrency
                                           convertedTo:[Currency usdCurrency]
                                          rateProvider:provider
                                            roundScale:2];

    NSDecimalNumber *zeroPointOne = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:-1 isNegative:NO];
    if ([fromValueInUSD compare:zeroPointOne] == NSOrderedAscending) {
        return NO;
    }

    return YES;
}

@end
