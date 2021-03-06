//
//  CurrencyRateProvider.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Currency.h"

@protocol CurrencyRateProviderDelegate;


@interface CurrencyRateProvider : NSObject

@property (readonly) BOOL ratesLoaded;
@property (nonatomic, weak) id <CurrencyRateProviderDelegate> delegate;

- (NSDecimalNumber *)rateForCurrency:(Currency *)currency;
- (void)startUpdatingCurrencyWithInterval:(NSTimeInterval)interval;
- (void)stopUpdatingCurrency;

@end


@protocol CurrencyRateProviderDelegate <NSObject>

- (void)rateProviderUpdatedCurrencyRates:(CurrencyRateProvider *)provider;

@end
