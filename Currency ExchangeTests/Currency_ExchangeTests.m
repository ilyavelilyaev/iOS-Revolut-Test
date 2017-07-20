//
//  Currency_ExchangeTests.m
//  Currency ExchangeTests
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Currency.h"

@interface Currency_ExchangeTests : XCTestCase

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
    Currency *currency = [[Currency alloc] initWithCode: @"USD"];
    NSString *symbol = [currency symbol];
    NSString *expectedSymbol = @"$";
    NSLog(@"%@", symbol);
    XCTAssert([symbol isEqualToString:expectedSymbol]);
}

- (void)testCurrencyConversion {
    Currency *usd = [[Currency alloc] initWithCode: @"USD"];
    usd.rate = 1.1533;

    Currency *rub = [[Currency alloc] initWithCode: @"RUB"];
    rub.rate = 68.0915;

    double expected = 59.0406;
    double usdRubRate = [usd value:1 convertedTo:rub];

    XCTAssert((usdRubRate - expected) < 0.0001);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
