//
//  User.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Currency.h"
#import "CurrencyRateProvider.h"

@interface User : NSObject

@property (nonatomic, readonly) NSDictionary *balance;

/**
 Use to perform transactions between users currencies
 @return YES if success, NO if error.
 */
- (BOOL)performTransactionFromCurrency:(Currency *)fromCurrency
                                    to:(Currency *)toCurrency
                  valueInFirstCurrency:(double)value
                          rateProvider:(CurrencyRateProvider *)provider;

- (BOOL)canPerformTransactionFromCurrency:(Currency *)fromCurrency
                                    to:(Currency *)toCurrency
                  valueInFirstCurrency:(double)value
                          rateProvider:(CurrencyRateProvider *)provider;

@end
