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

    double eurToEurCheck = [converter value:1 inCurrency: eur convertedTo:eur rateProvider:self.provider];

    XCTAssert(eurToEurCheck == 1);


    double usdRate = [[self.provider rateForCurrency:usd] doubleValue];

    double expectedresult = usdRate * 3;

    double eurToUsdCheck = [converter value:3 inCurrency:eur convertedTo:usd rateProvider:self.provider];

    XCTAssert(expectedresult == eurToUsdCheck);
}

- (void)testUserTransaction {
    User *user = [[User alloc] init];

    Currency *usd = [Currency usdCurrency];
    Currency *eur = [Currency gbpCurrency];

    BOOL success = [user performTransactionFromCurrency:usd to:eur valueInFirstCurrency:150 rateProvider:self.provider];

    XCTAssert(success == false);

    BOOL success1 = [user performTransactionFromCurrency:usd to:eur valueInFirstCurrency:34 rateProvider:self.provider];

    XCTAssert(success1);

    CurrencyConverter *converter = [[CurrencyConverter alloc] init];
    double eurosFromUsd = [converter value:34 inCurrency:usd convertedTo:eur rateProvider:self.provider];

    XCTAssert([user.balance[usd] doubleValue] == (100.0 - 34.0));
    XCTAssert([user.balance[eur] doubleValue] == (100.0 + eurosFromUsd));

    BOOL success2 = [user performTransactionFromCurrency:usd to:eur valueInFirstCurrency:80 rateProvider:self.provider];

    XCTAssert(success2 == false);

}


@end
