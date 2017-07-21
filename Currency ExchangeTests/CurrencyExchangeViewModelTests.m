//
//  CurrencyExchangeViewModelTests.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 21.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CurrencyExchangeViewModel.h"

@interface CurrencyExchangeViewModelTests : XCTestCase

@property (nonatomic) CurrencyExchangeViewModel *viewModel;

@end

@implementation CurrencyExchangeViewModelTests

- (void)setUp {
    [super setUp];
    self.viewModel = [[CurrencyExchangeViewModel alloc] init];
    [self.viewModel load];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait to download rates"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"something");
        [expectation fulfill];
    });

    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAmountOfPages {
    XCTAssert([self.viewModel amountOfPages] == 3);
}

- (void)testPageTitles {
    NSMutableArray *expectedTitles = [@[@"EUR", @"GBP", @"USD"] mutableCopy];
    for (int i = 0; i < 3; i++) {
        NSString *title = [self.viewModel titleForPageAtIdx:i];
        [expectedTitles removeObject:title];
    }
    XCTAssert([expectedTitles count] == 0);
}

- (void)testShowingTopCurrencyView {
    XCTAssertFalse([self.viewModel shouldShowTopCurrencyView]);

    [self.viewModel updatedCurrentTopPage:1];
    XCTAssert([self.viewModel shouldShowTopCurrencyView]);

    [self.viewModel updatedCurrentBottomPage:1];
    XCTAssertFalse([self.viewModel shouldShowTopCurrencyView]);
}

- (void)testInitialLeftSubtitles {
    int count = (int)[self.viewModel amountOfPages];

    for (int i = 0; i < count; i++) {
        NSString *subtitle = [self.viewModel leftSubtitleForPageAtIdx:i];
        XCTAssert([subtitle containsString:@"You have"]);
        XCTAssert([subtitle containsString:@"100"]);
    }
}

- (void)testAppearanceOfRightSubtitle {
    int count = (int)[self.viewModel amountOfPages];

    for (int i = 0; i < count; i++) {
        [self.viewModel updatedCurrentTopPage:i];
        for (int j = 0; j < count; j++) {
            if (i == j) {
                XCTAssertFalse([self.viewModel rightSubtitleForBottomPageAtIdx:j]);
            } else {
                XCTAssert([self.viewModel rightSubtitleForBottomPageAtIdx:j]);
            }
        }
    }
}

- (void)testLeftSubtitleChangeColor {

    UIColor *white = [UIColor whiteColor];
    UIColor *red = [UIColor redColor];

    XCTAssert([[self.viewModel leftSubtitleColorForTopPageAtIdx:0] isEqual:white]);

    [self.viewModel updatedCurrentBottomPage:1];
    [self.viewModel updatedTopTextAt:0 text:@"101"];

    XCTAssert([[self.viewModel leftSubtitleColorForTopPageAtIdx:0] isEqual:red]);
}

- (void)testLeftSubtitleChangeValue {

    NSString *leftSubtitle = [self.viewModel leftSubtitleForPageAtIdx:0];
    XCTAssert([leftSubtitle containsString:@"100"]);

    [self.viewModel updatedCurrentBottomPage:1];
    [self.viewModel updatedTopTextAt:0 text:@"50"];

    [self.viewModel exchange];

    leftSubtitle = [self.viewModel leftSubtitleForPageAtIdx:0];
    XCTAssert([leftSubtitle containsString:@"50"]);

}

- (void)testLeftSubtitleSmallBalance {

        // 1: Transfer all money from 1st currency to 3rd;
    [self.viewModel updatedCurrentBottomPage:2];
    [self.viewModel updatedTopTextAt:0 text:@"100"];

    XCTAssert([self.viewModel exchange]);

        // 2: Transfer all money from 2nd currency to 3rd;
    [self.viewModel updatedCurrentTopPage:1];
    [self.viewModel updatedTopTextAt:1 text:@"100"];

    XCTAssert([self.viewModel exchange]);

        // 3: Make 3rd page on the top, read balance;
    [self.viewModel updatedCurrentTopPage:2];
    NSString *leftSubtitle = [self.viewModel leftSubtitleForPageAtIdx:2];
    NSString *amount = [leftSubtitle substringFromIndex:10];

        // 3: Transfer all shown money from 3rd currency to 1st;
    [self.viewModel updatedCurrentBottomPage:0];
    [self.viewModel updatedTopTextAt:2 text:amount];

    XCTAssert([self.viewModel exchange]);

        // 4: Because of currency rates there should less than 0.01 left on 3rd currency.
    leftSubtitle = [self.viewModel leftSubtitleForPageAtIdx:2];
    XCTAssert([leftSubtitle containsString:@"<"]);
}



@end
