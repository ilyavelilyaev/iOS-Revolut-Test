//
//  CurrencyFetcher.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyFetcher.h"
#import <XMLDictionary/XMLDictionary.h>
#import "EXTScope.h"

NSString *const ratesURL = @"http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml";

@interface CurrencyFetcher ()

@end

@implementation CurrencyFetcher

- (void)loadCurrenciesWithCompletion:(CurrencyFetcherCompletion)completion {
    NSURL *url = [NSURL URLWithString:ratesURL];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        @strongify(self);
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        XMLDictionaryParser *parser = [XMLDictionaryParser sharedInstance];
        NSDictionary *dict = [parser dictionaryWithParser:xmlParser];
        NSDictionary *currencies = [self extractCurrenciesFromECBResponse:dict];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(currencies);
        });
    });
}

- (NSDictionary *)extractCurrenciesFromECBResponse:(NSDictionary *)response {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSArray *currencies = response[@"Cube"][@"Cube"][@"Cube"];
    NSUInteger count = [currencies count];

    for (NSUInteger i = 0; i < count; i++) {
        NSString *currency = currencies[i][@"_currency"];
        NSString *stringRate = currencies[i][@"_rate"];
        NSNumber *rate = [NSNumber numberWithDouble:[stringRate doubleValue]];
        [dictionary setObject:rate forKey:currency];
    }

    return [NSDictionary dictionaryWithDictionary:dictionary];
}



@end
