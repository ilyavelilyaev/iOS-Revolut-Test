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

- (NSString * _Nonnull)symbol {
    NSLocale *locale = [NSLocale currentLocale];
    return [locale displayNameForKey:NSLocaleCurrencySymbol value:self.code];
}

+ (instancetype _Nullable)eurCurrency {
    return [[self alloc] initWithCode: @"EUR"];
}

+ (instancetype _Nullable)usdCurrency {
    return [[Currency alloc] initWithCode: @"USD"];
}

+ (instancetype _Nullable)gbpCurrency {
    return [[Currency alloc] initWithCode: @"GBP"];
}

- (id)copyWithZone:(NSZone *)zone {
    Currency *newCurrency = [[[self class] allocWithZone:zone] init];
    newCurrency->_code = [_code copyWithZone:zone];
    return newCurrency;
}

- (BOOL)isEqual:(id)object {
    Currency *other = (Currency *)object;
    if (!other) { return NO; }
    return [other.code isEqual:self.code];
}


@end
