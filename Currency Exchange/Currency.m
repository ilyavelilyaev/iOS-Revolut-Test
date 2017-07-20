//
//  Currency.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "Currency.h"
@implementation Currency


- (instancetype _Nullable)initWithCode:(NSString *_Nonnull)code {
    self = [super init];
    if (self) {
        _code = code;
    }
    return self;
}

- (NSString * _Nullable)symbol {
    NSLocale *locale = [NSLocale currentLocale];
    return [locale displayNameForKey:NSLocaleCurrencySymbol value:self.code];
}

- (double)value:(double)value convertedTo:(Currency *_Nonnull)currency {
    double valueInEuro = value * self.rate;
    return valueInEuro / currency.rate;
}


@end
