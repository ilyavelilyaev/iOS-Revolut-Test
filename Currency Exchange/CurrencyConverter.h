//
//  CurrencyConverter.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Currency.h"
#import "CurrencyRateProvider.h"

@interface CurrencyConverter : NSObject

- (NSDecimalNumber *)value:(NSDecimalNumber *)value
                inCurrency:(Currency *)currency
               convertedTo:(Currency *)secondCurrency
              rateProvider:(CurrencyRateProvider *)provider
                roundScale:(NSInteger)scale;


@end
