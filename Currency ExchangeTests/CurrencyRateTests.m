//
//  CurrencyRateTests.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CurrencyRateProvider.h"
#import "User.h"
#import "CurrencyConverter.h"

@interface CurrencyRateTests : XCTestCase <CurrencyRateProviderDelegate>

@property (nonatomic) CurrencyRateProvider *provider;
@property XCTestExpectation *expectation;

@end

@implementation CurrencyRateTests

- (void)setUp {
    [super setUp];
    self.provider = [[CurrencyRateProvider alloc] init];
    [self.provider setDelegate:self];

    self.expectation = [self expectationWithDescription:@"Waiting for rate provider to download"];

    [self.provider startUpdatingCurrencyWithInterval:30];

    [self waitForExpectations:@[self.expectation] timeout:10.0];
    self.expectation = nil;

}

- (void)tearDown {
    [self.provider stopUpdatingCurrency];
    [super tearDown];
}

- (void)testCurrencyRateProvider {
    Currency *eur = [Currency eurCurrency];
    XCTAssert([[self.provider rateForCurrency:eur] doubleValue] == 1);

    Currency *usd = [Currency usdCurrency];
    XCTAssert([self.provider rateForCurrency:usd] != nil);
}

- (void)rateProviderUpdatedCurrencyRates:(CurrencyRateProvider *)provider {
    [self.expectation fulfill];
}

- (void)testCurrencyConverter {
    CurrencyConverter *converter = [[CurrencyConverter alloc] init];

    Currency *eur = [Currency eurCurrency];
    Currency *usd = [Currency usdCurrency];

    NSDecimalNumber *eurToEurCheck = [converter value:[NSDecimalNumber one] inCurrency: eur convertedTo:eur rateProvider:self.provider roundScale:2];

    XCTAssert([eurToEurCheck compare:[NSDecimalNumber one]] == NSOrderedSame);


    NSDecimalNumber *usdRate = [self.provider rateForCurrency:usd];

    NSDecimalNumber *three = [NSDecimalNumber decimalNumberWithMantissa:3 exponent:0 isNegative:NO];
    NSDecimalNumber *expectedresult = [usdRate decimalNumberByMultiplyingBy:three];

    NSDecimalNumber *eurToUsdCheck = [converter value:three inCurrency:eur convertedTo:usd rateProvider:self.provider roundScale:2];

    NSDecimalNumberHandler *behaviour = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                                                                               scale:2
                                                                                    raiseOnExactness:NO
                                                                                     raiseOnOverflow:NO
                                                                                    raiseOnUnderflow:NO
                                                                                 raiseOnDivideByZero:NO];


    XCTAssert([[expectedresult decimalNumberByRoundingAccordingToBehavior:behaviour] isEqualToNumber:eurToUsdCheck]);
}

- (void)testUserTransaction {
    User *user = [[User alloc] init];

    Currency *usd = [Currency usdCurrency];
    Currency *eur = [Currency gbpCurrency];

    NSDecimalNumber *hundredFifty = [NSDecimalNumber decimalNumberWithMantissa:150 exponent:0 isNegative:NO];

    BOOL success = [user performTransactionFromCurrency:usd to:eur valueInFirstCurrency:hundredFifty rateProvider:self.provider];

    XCTAssert(success == false);

    NSDecimalNumber *thirtyFour = [NSDecimalNumber decimalNumberWithMantissa:34 exponent:0 isNegative:NO];

    BOOL success1 = [user performTransactionFromCurrency:usd to:eur valueInFirstCurrency:thirtyFour rateProvider:self.provider];

    XCTAssert(success1);

    CurrencyConverter *converter = [[CurrencyConverter alloc] init];
    NSDecimalNumber *eurosFromUsd = [converter value:thirtyFour inCurrency:usd convertedTo:eur rateProvider:self.provider roundScale:2];

    XCTAssert([user.balance[usd] doubleValue] == (100.0 - 34.0));
    XCTAssert([user.balance[eur] doubleValue] == (100.0 + [eurosFromUsd doubleValue]));


    NSDecimalNumber *eighty = [NSDecimalNumber decimalNumberWithMantissa:80 exponent:0 isNegative:NO];

    BOOL success2 = [user performTransactionFromCurrency:usd to:eur valueInFirstCurrency:eighty rateProvider:self.provider];

    XCTAssert(success2 == false);

}


@end
