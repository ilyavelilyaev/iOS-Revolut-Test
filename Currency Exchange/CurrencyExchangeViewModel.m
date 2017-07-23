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
#import "NSDecimalNumber+absoluteValue.h"
#import "NSNumberFormatter+AvoidZeroSign.h"

typedef NS_ENUM(NSUInteger, ActivePage) {
    ActivePageTop,
    ActivePageBottom
};

@interface CurrencyExchangeViewModel () {

    CurrencyRateProvider *rateProvider;
    CurrencyConverter *currencyConverter;
    User *user;
    NSArray *currencies;

    NSString *topText;
    NSString *bottomText;

    NSUInteger currentTopIdx;
    NSUInteger currentBottomIdx;

    NSNumberFormatter *formatter;

    ActivePage activePage;
}

@property (nonatomic, readonly, getter=topCurrency) Currency *topCurrency;
@property (nonatomic, readonly, getter=bottomCurrency) Currency *bottomCurrency;


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

        activePage = ActivePageTop;
    }
    return self;
}

-(Currency *)topCurrency {
    return currencies[currentTopIdx];
}

-(Currency *)bottomCurrency {
    return currencies[currentBottomIdx];
}


-(void)load {
    [rateProvider startUpdatingCurrencyWithInterval:30.0];

    [self.currencyExchangeViewController reloadExchangeButton];
    [self.currencyExchangeViewController reloadTopCurrencyView];
    [self.currencyExchangeViewController reloadPageControl];
    [self.currencyExchangeViewController reloadPageViews];
}

-(BOOL)canExchange {
    if (!rateProvider.ratesLoaded) return NO;
    if (!topText || [topText length] == 0) return NO;
    
    NSDecimalNumber *value = [[NSDecimalNumber decimalNumberWithString:topText] absoluteValue];

    return [user canPerformTransactionFromCurrency:self.topCurrency
                                                to:self.bottomCurrency
                              valueInFirstCurrency:value
                                      rateProvider:rateProvider];
}

-(BOOL)exchange {

    NSDecimalNumber *value = [[NSDecimalNumber decimalNumberWithString:topText] absoluteValue];

    BOOL success = [user performTransactionFromCurrency:self.topCurrency
                                                     to:self.bottomCurrency
                                   valueInFirstCurrency:value
                                           rateProvider:rateProvider];
    
    return success;
}

-(NSAttributedString *)textForTopCurrencyView {

    NSDecimalNumber *value = [currencyConverter value:[NSDecimalNumber one]
                                           inCurrency:self.topCurrency
                                          convertedTo:self.bottomCurrency
                                         rateProvider:rateProvider
                                           roundScale:4];

    if (!([value compare:[NSDecimalNumber zero]] == NSOrderedSame)) {

        NSString *valueString = [value stringValue];
        NSString *stringToShow = [NSString stringWithFormat:@"%@1=%@%@", self.topCurrency.symbol,
                                  self.bottomCurrency.symbol, valueString];

        NSMutableAttributedString *attributedStringToShow = [[NSMutableAttributedString alloc]
                                                             initWithString:stringToShow];

        UIFont *largeFont = [UIFont systemFontOfSize:18.0 weight: UIFontWeightLight];
        UIFont *smallFont = [largeFont fontWithSize:13.0];

        NSDecimalNumber *integerPart = [NSDecimalNumber decimalNumberWithMantissa:[value integerValue]
                                                                         exponent:0
                                                                       isNegative:([value integerValue] < 0)];
        NSDecimalNumber *fractionalPart = [value decimalNumberBySubtracting:integerPart];

        NSInteger smallDigitsCount = [[fractionalPart stringValue] length] - 4;
        if (smallDigitsCount < 0) smallDigitsCount = 0;

        [attributedStringToShow addAttribute:NSFontAttributeName
                                       value:largeFont
                                       range:NSMakeRange(0, [stringToShow length] - smallDigitsCount)];

        [attributedStringToShow addAttribute:NSFontAttributeName
                                       value:smallFont
                                       range:NSMakeRange([stringToShow length] - smallDigitsCount, smallDigitsCount)];

        [attributedStringToShow addAttribute:NSForegroundColorAttributeName
                                       value:[UIColor whiteColor]
                                       range:NSMakeRange(0, [stringToShow length])];

        return attributedStringToShow;
    }

    return nil;
}

-(BOOL)shouldShowTopCurrencyView {
    return (![self.topCurrency isEqual:self.bottomCurrency]) && rateProvider.ratesLoaded;
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
    NSDecimalNumber *balance = user.balance[current];

    return [NSString stringWithFormat:@"You have %@%@", symbol, [balance stringValue]];
}

-(NSString *)rightSubtitleForBottomPageAtIdx:(NSUInteger)idx {
    Currency *bottomCurrency = currencies[idx];
    if ([bottomCurrency isEqual:self.topCurrency])
        return nil;

    NSDecimalNumber *value = [currencyConverter value:[NSDecimalNumber one]
                                 inCurrency:bottomCurrency
                                convertedTo:self.topCurrency
                               rateProvider:rateProvider
                                 roundScale:2];

    if (!([value compare:[NSDecimalNumber zero]] == NSOrderedSame))
        return [NSString stringWithFormat:@"%@1=%@%@", bottomCurrency.symbol, self.topCurrency.symbol, value];

    return nil;
}

-(UIColor *)leftSubtitleColorForTopPageAtIdx:(NSUInteger)idx {
    if (!topText || [topText length] == 0) return [UIColor whiteColor];

    Currency *current = currencies[idx];
    NSDecimalNumber *balance = user.balance[current];
    NSDecimalNumber *topValue = [[NSDecimalNumber decimalNumberWithString:topText] absoluteValue];

    if ([topValue compare:balance] == NSOrderedDescending)
        return [UIColor redColor];

    return [UIColor whiteColor];
}

-(NSString *)textFieldTextForTopPageAtIdx:(NSUInteger)idx {
    if (activePage == ActivePageTop) {
        if (!topText || [topText length] == 0) return nil;

        NSDecimalNumber *topValue = [[NSDecimalNumber decimalNumberWithString:topText] negativeAbsoluteValue];

        return [self processTextForInputField:topText value:topValue];
    }

    if (!bottomText || [bottomText length] == 0) return nil;

    NSDecimalNumber *bottomValue = [[NSDecimalNumber decimalNumberWithString:bottomText] absoluteValue];

    NSDecimalNumber *topValue = [[currencyConverter value:bottomValue
                                               inCurrency:self.bottomCurrency
                                              convertedTo:currencies[idx]
                                             rateProvider:rateProvider
                                               roundScale:2] negativeAbsoluteValue];

    NSString *text = [self processTextForInputField:nil value:topValue];
    if (currentTopIdx == idx) topText = text;
    return text;
}

-(NSString *)textFieldTextForBottomPageAtIdx:(NSUInteger)idx {
    if (activePage == ActivePageTop) {
        if (!topText || [topText length] == 0) return nil;

        NSDecimalNumber *topValue = [[NSDecimalNumber decimalNumberWithString:topText] absoluteValue];

        NSDecimalNumber *bottomValue = [currencyConverter value:topValue
                                                     inCurrency:self.topCurrency
                                                    convertedTo:currencies[idx]
                                                   rateProvider:rateProvider
                                                     roundScale:2];

        NSString *text = [self processTextForInputField:nil value:bottomValue];
        if (currentBottomIdx == idx) bottomText = text;
        return text;
    }

    if (!bottomText || [bottomText length] == 0) return nil;
    NSDecimalNumber *bottomValue = [[NSDecimalNumber decimalNumberWithString:bottomText] absoluteValue];

    return [self processTextForInputField:bottomText value:bottomValue];
}

-(NSString *)processTextForInputField:(NSString *)text value:(NSDecimalNumber *)value {
    if (text == nil && ([value compare:[NSDecimalNumber zero]] == NSOrderedSame))
        return nil;

    NSMutableString *stringToReturn = [[formatter stringFromNumberAvoidingZeroSign:value] mutableCopy];

    unichar lastChar = [text characterAtIndex:([text length] - 1)];
    unichar fullStop = 46;
    unichar comma = 44;
    unichar zero = 48;

        // So the user can enter characters after decimal point;
    if (lastChar == fullStop || lastChar == comma) {
        [stringToReturn appendString:[NSString stringWithCharacters:&lastChar length:1]];
    }

    if ([text length] < 2)
        return stringToReturn;

    unichar lastButOneChar = [text characterAtIndex:([text length] - 2)];
    unichar *characters = (unichar *)malloc(sizeof(unichar) * 2);
    characters[0] = lastButOneChar;
    characters[1] = lastChar;

        // So the user can enter characters after decimal point and 0 e.g. 0.03
    if ((lastButOneChar == fullStop || lastButOneChar == comma) && lastChar == zero) {
        [stringToReturn appendString:[NSString stringWithCharacters:characters length:2]];
    }

    return stringToReturn;
}

-(BOOL)editingActiveForTopPage {
    return activePage == ActivePageTop;
}

-(BOOL)editingActiveForBottomPage {
    return activePage == ActivePageBottom;
}

-(void)updatedCurrentTopPage:(NSUInteger)idx {
    currentTopIdx = idx;
    [self.currencyExchangeViewController reloadPageViews];
    [self.currencyExchangeViewController reloadExchangeButton];
    [self.currencyExchangeViewController reloadTopCurrencyView];
}

-(void)updatedCurrentBottomPage:(NSUInteger)idx {
    currentBottomIdx = idx;
    [self.currencyExchangeViewController reloadPageViews];
    [self.currencyExchangeViewController reloadExchangeButton];
    [self.currencyExchangeViewController reloadTopCurrencyView];
}

-(void)updatedTopTextAt:(NSUInteger)idx text:(NSString *)text {
    if ([text isEqualToString:@"-"] || [text isEqualToString:@""])
        topText = nil;
    else
        topText = [text copy];

    currentTopIdx = idx;
    [self.currencyExchangeViewController reloadPageViews];
    [self.currencyExchangeViewController reloadExchangeButton];
}

-(void)updatedBottomTextAt:(NSUInteger)idx text:(NSString *)text {
    if ([text isEqualToString:@"+"] || [text isEqualToString:@""])
        bottomText = nil;
    else
        bottomText = [text copy];

    currentBottomIdx = idx;
    [self.currencyExchangeViewController reloadPageViews];
    [self.currencyExchangeViewController reloadExchangeButton];
}

-(void)tappedOnTopPageView {
    activePage = ActivePageTop;
    [self.currencyExchangeViewController reloadPageViews];
    [self.currencyExchangeViewController reloadExchangeButton];
}

-(void)tappedOnBottomPageView {
    activePage = ActivePageBottom;
    [self.currencyExchangeViewController reloadPageViews];
    [self.currencyExchangeViewController reloadExchangeButton];
}


#pragma mark Rate Provider Delegate

- (void)rateProviderUpdatedCurrencyRates:(CurrencyRateProvider *)provider {
    [self.currencyExchangeViewController reloadPageViews];
    [self.currencyExchangeViewController reloadExchangeButton];
    [self.currencyExchangeViewController reloadTopCurrencyView];
}



@end
