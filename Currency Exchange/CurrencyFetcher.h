//
//  CurrencyFetcher.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrencyFetcher : NSObject

typedef void (^CurrencyFetcherCompletion)(NSDictionary * _Nullable currencyRateDictionary);

- (void)loadCurrenciesWithCompletion:(CurrencyFetcherCompletion _Nonnull)completion;

@end
