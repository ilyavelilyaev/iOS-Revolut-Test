//
//  CurrencyRateProvider.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyRateProvider.h"
#import "CurrencyFetcher.h"
#import "EXTScope.h"


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
        _ratesLoaded = NO;
    }
    return self;
}

- (NSDecimalNumber *)rateForCurrency:(Currency *)currency {
    if ([currency.code isEqualToString:@"EUR"]) { return [NSDecimalNumber one]; }
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
    @weakify(self)
    [self.fetcher loadCurrenciesWithCompletion:^(NSDictionary * _Nullable currencyRateDictionary) {
        @strongify(self)
        self.cache = currencyRateDictionary;
        [self.delegate rateProviderUpdatedCurrencyRates:self];
        if (currencyRateDictionary && [currencyRateDictionary count] > 0) {
            _ratesLoaded = YES;
        }
    }];
}

@end
