//
//  CurrencyRateProvider.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyRateProvider.h"
#import "CurrencyFetcher.h"


@interface CurrencyRateProvider ()

@property (nonatomic, readonly) CurrencyFetcher *fetcher;
@property (nonatomic) NSDictionary *cache;
@property (weak) NSTimer *timer;

@end

@implementation CurrencyRateProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fetcher = [[CurrencyFetcher alloc] init];
    }
    return self;
}

- (NSNumber *)rateForCurrency:(Currency *)currency {
    if ([currency.code isEqualToString:@"EUR"]) { return @1.0; }
    return self.cache[currency.code];
}

- (void)startUpdatingCurrencyWithInterval:(NSTimeInterval)interval {
    [self.timer invalidate];

    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                      target:self
                                                    selector:@selector(timerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
    [self timerFired:timer];
    self.timer = timer;
}

- (void)stopUpdatingCurrency {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerFired:(NSTimer *)timer {
    [self.fetcher loadCurrenciesWithCompletion:^(NSDictionary * _Nullable currencyRateDictionary) {
        self.cache = currencyRateDictionary;
        [self.delegate rateProviderUpdatedCurrencyRates:self];
    }];
}

@end
