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

    double value = fabs([topText doubleValue]);

    return [user canPerformTransactionFromCurrency:self.topCurrency
                                                to:self.bottomCurrency
                              valueInFirstCurrency:value
                                      rateProvider:rateProvider];
}

-(BOOL)exchange {
    double value = fabs([topText doubleValue]);

    BOOL success = [user performTransactionFromCurrency:self.topCurrency
                                                     to:self.bottomCurrency
                                   valueInFirstCurrency:value
                                           rateProvider:rateProvider];
    
    return success;
}

-(NSAttributedString *)textForTopCurrencyView {

    double value = [currencyConverter value:1
                                 inCurrency:self.topCurrency
                                convertedTo:self.bottomCurrency
                               rateProvider:rateProvider];

    if (isfinite(value) && value != 0) {
        NSString *stringToShow = [NSString stringWithFormat:@"%@1=%@%.4f", self.topCurrency.symbol,
                                  self.bottomCurrency.symbol, value];
        NSMutableAttributedString *attributedStringToShow = [[NSMutableAttributedString alloc]
                                                             initWithString:stringToShow];
        UIFont *largeFont = [UIFont systemFontOfSize:18.0 weight: UIFontWeightLight];
        UIFont *smallFont = [largeFont fontWithSize:13.0];

        [attributedStringToShow addAttribute:NSFontAttributeName
                                       value:largeFont
                                       range:NSMakeRange(0, [stringToShow length] - 2)];

        [attributedStringToShow addAttribute:NSFontAttributeName
                                       value:smallFont
                                       range:NSMakeRange([stringToShow length] - 2, 2)];

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
    double balance = [user.balance[current] doubleValue];

    if (balance < 0.01 && balance > 0)
        return [NSString stringWithFormat:@"You have <%@0.01", symbol];

    balance = 0.01 * (floor(balance * 100));
    return [NSString stringWithFormat:@"You have %@%.2lf", symbol, balance];
}

-(NSString *)rightSubtitleForBottomPageAtIdx:(NSUInteger)idx {
    Currency *bottomCurrency = currencies[idx];
    if ([bottomCurrency isEqual:self.topCurrency])
        return nil;

    double value = [currencyConverter value:1
                                 inCurrency:bottomCurrency
                                convertedTo:self.topCurrency
                               rateProvider:rateProvider];

    if (isfinite(value) && value != 0)
        return [NSString stringWithFormat:@"%@1=%@%.2lf", bottomCurrency.symbol, self.topCurrency.symbol, value];

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

-(NSString *)textFieldTextForBottomPageAtIdx:(NSUInteger)idx {

    double topValue = fabs([topText doubleValue]);

    double bottomValue = [currencyConverter value:topValue
                                       inCurrency:self.topCurrency
                                      convertedTo:currencies[idx]
                                     rateProvider:rateProvider];
    if (isfinite(bottomValue))
        return [self processTextForInputField:nil value:bottomValue];

    return nil;
}

-(NSString *)processTextForInputField:(NSString *)text value:(double)value {
    if (text == nil && fabs(value) < 0.005)
        return nil;

    NSMutableString *stringToReturn = [[formatter
                                        stringFromNumber:[NSNumber numberWithDouble:value]] mutableCopy];

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
    return YES;
}

-(BOOL)editingActiveForBottomPage {
    return NO;
}

-(void)updatedCurrentTopPage:(NSUInteger)idx {
    currentTopIdx = idx;
    [self.currencyExchangeViewController reloadExchangeButton];
    [self.currencyExchangeViewController reloadTopCurrencyView];
    [self.currencyExchangeViewController reloadPageViews];
}

-(void)updatedCurrentBottomPage:(NSUInteger)idx {
    currentBottomIdx = idx;
    [self.currencyExchangeViewController reloadExchangeButton];
    [self.currencyExchangeViewController reloadTopCurrencyView];
    [self.currencyExchangeViewController reloadPageViews];
}

-(void)updatedTopTextAt:(NSUInteger)idx text:(NSString *)text {
    if ([text isEqualToString:@"-"])
        topText = nil;
    else
        topText = [text copy];

    currentTopIdx = idx;
    [self.currencyExchangeViewController reloadExchangeButton];
    [self.currencyExchangeViewController reloadPageViews];
}

-(void)updatedBottomTextAt:(NSUInteger)idx text:(NSString *)text {

}




#pragma mark Rate Provider Delegate

- (void)rateProviderUpdatedCurrencyRates:(CurrencyRateProvider *)provider {
    [self.currencyExchangeViewController reloadExchangeButton];
    [self.currencyExchangeViewController reloadTopCurrencyView];
    [self.currencyExchangeViewController reloadPageViews];
}



@end
