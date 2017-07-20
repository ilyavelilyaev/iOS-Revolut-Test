//
//  Currency_ExchangeTests.m
//  Currency ExchangeTests
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Currency.h"
#import "CurrencyFetcher.h"
#import "User.h"
#import "CurrencyRateProvider.h"


#import <XMLDictionary/XMLDictionary.h>

@interface Currency_ExchangeTests : XCTestCase

@property XCTestExpectation* expectation;



@end

@implementation Currency_ExchangeTests 

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCurrencySymbol {
    Currency *currency = [Currency usdCurrency];
    NSString *symbol = [currency symbol];
    NSString *expectedSymbol = @"$";
    NSLog(@"%@", symbol);
    XCTAssert([symbol isEqualToString:expectedSymbol]);
}

- (void)testUser {
    User *user = [[User alloc] init];
    Currency *usd = [Currency usdCurrency];
    XCTAssert([user.balance[usd] isEqual:@100]);
}


- (void)testCurrenciesFetcher {
    CurrencyFetcher *fetcher = [[CurrencyFetcher alloc] init];
    [fetcher loadCurrenciesWithCompletion:^(NSDictionary * _Nullable currencyRateDictionary) {
        XCTAssert(currencyRateDictionary[@"USD"]);
        XCTAssert(currencyRateDictionary[@"JPY"]);
        XCTAssert(currencyRateDictionary[@"RUB"]);
        [_expectation fulfill];
    }];
    _expectation = [self expectationWithDescription:@"aaa"];
    [self waitForExpectations:@[_expectation] timeout:10];
}



@end
