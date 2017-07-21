//
//  CurrencyExchangeViewModel.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyExchangeViewModel.h"
#import "User.h"
#import "CurrencyConverter.h"

@interface CurrencyExchangeViewModel () {

    CurrencyRateProvider *rateProvider;
    CurrencyConverter *currencyConverter;
    User *user;
    NSArray *currencies;

    NSString *topText;

    NSUInteger currentTopIdx;
    NSUInteger currentBottomIdx;

    NSNumberFormatter *formatter;

}

@end

@implementation CurrencyExchangeViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        rateProvider = [[CurrencyRateProvider alloc] init];
        rateProvider.delegate = self;
        user = [[User alloc] init];
        currencies = user.balance.allKeys;

        formatter = [[NSNumberFormatter alloc] init];
        formatter.maximumFractionDigits = 2;
        formatter.minimumIntegerDigits = 1;
        formatter.positivePrefix = @"+";

        currencyConverter = [[CurrencyConverter alloc] init];
    }
    return self;
}

-(void)load {
    [rateProvider startUpdatingCurrencyWithInterval:30.0];

    [self.currencyExchangeViewController reloadTopCurrencyView];
    [self.currencyExchangeViewController reloadPageControl];
    [self.currencyExchangeViewController reloadPageViews];
}

-(BOOL)exchange {
    return YES;
}


-(NSUInteger)amountOfPages {
    return user.balance.count;
}

-(NSString *)titleForPageAtIdx:(NSUInteger)idx {
    Currency *current = currencies[idx];
    return current.code;
}

-(NSString *)leftSubtitleForPageAtIdx:(NSUInteger)idx {
    Currency *current = currencies[idx];
    NSString *symbol = current.symbol;
    NSString *balance = [user.balance[current] stringValue];
    return [NSString stringWithFormat:@"You have %@%@", symbol, balance];
}

-(NSString *)rightSubtitleForBottomPageAtIdx:(NSUInteger)idx {
    Currency *bottomCurrency = currencies[idx];
    Currency *topCurrency = currencies[currentTopIdx];

    double value = [currencyConverter value:1
                                 inCurrency:bottomCurrency
                                convertedTo:topCurrency
                               rateProvider:rateProvider];

    if (isfinite(value) && value != 0)
        return [NSString stringWithFormat:@"%@1=%@%.2lf", bottomCurrency.symbol, topCurrency.symbol, value];

    return nil;
}

-(UIColor *)leftSubtitleColorForTopPageAtIdx:(NSUInteger)idx {
    Currency *current = currencies[idx];
    double balance = [user.balance[current] doubleValue];

    if (fabs([topText doubleValue]) > balance)
        return [UIColor redColor];

    return [UIColor whiteColor];
}

-(NSString *)textFieldTextForTopPageAtIdx:(NSUInteger)idx {

    double topValue = -fabs([topText doubleValue]);

    return [self processTextForInputField:topText value:topValue];
}

-(NSString *)processTextForInputField:(NSString *)text value:(double)value {

    NSMutableString *stringToReturn = [[formatter
                                        stringFromNumber:[NSNumber numberWithDouble:value]] mutableCopy];

    unichar lastChar = [text characterAtIndex:([text length] - 1)];
    unichar fullStop = 46;
    unichar comma = 44;

    if (lastChar == fullStop || lastChar == comma) {
        [stringToReturn appendString:[NSString stringWithCharacters:&lastChar length:1]];
    }

    return stringToReturn;
}

-(NSString *)textFieldTextForBottomPageAtIdx:(NSUInteger)idx {

    double topValue = fabs([topText doubleValue]);

    double bottomValue = [currencyConverter value:topValue
                                       inCurrency:currencies[currentTopIdx]
                                      convertedTo:currencies[idx]
                                     rateProvider:rateProvider];

    return [self processTextForInputField:nil value:bottomValue];
}

-(BOOL)editingActiveForTopPage {
    return YES;
}

-(BOOL)editingActiveForBottomPage {
    return NO;
}

-(void)updatedCurrentTopPage:(NSUInteger)idx {
    currentTopIdx = idx;
}

-(void)updatedCurrentBottomPage:(NSUInteger)idx {

}

-(void)updatedTopTextAt:(NSUInteger)idx text:(NSString *)text {
    topText = [text copy];
    currentTopIdx = idx;
    [self.currencyExchangeViewController reloadPageViews];
}

-(void)updatedBottomTextAt:(NSUInteger)idx text:(NSString *)text {

}




#pragma mark Rate Provider Delegate

- (void)rateProviderUpdatedCurrencyRates:(CurrencyRateProvider *)provider {
    [self.currencyExchangeViewController reloadTopCurrencyView];
    [self.currencyExchangeViewController reloadPageViews];
}



@end
