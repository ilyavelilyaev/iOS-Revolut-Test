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

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
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

    // Including many tests in one function as it takes long to set up
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

- (void)testShowingNothingInTopCurrencyBoxWhenRatesAreNotLoaded {

    self.viewModel = [[CurrencyExchangeViewModel alloc] init];
    [self.viewModel load];
    [self.viewModel updatedCurrentTopPage:1];
    XCTAssert([self.viewModel textForTopCurrencyView] == nil);
}

    // Including many tests in one function as it takes long to set up
- (void)testRightSubtitleInBottomBox {

        //1: Should not show if same currencies are chosen;
    XCTAssert([self.viewModel rightSubtitleForBottomPageAtIdx:0] == nil);

        //2: Should show rate if different currencies are chosen;
    XCTAssert([self.viewModel rightSubtitleForBottomPageAtIdx:1]);

}

    // Including many tests in one function as it takes long to set up
- (void)testUpdatingTopText {
        //1: Should add "-" automatically
    [self.viewModel updatedTopTextAt:0 text:@"10"];
    XCTAssert([[self.viewModel textFieldTextForTopPageAtIdx:0] isEqualToString:@"-10"]);

        //2: Should remove trailing zero
    [self.viewModel updatedTopTextAt:0 text:@"10.20"];
    XCTAssert([[self.viewModel textFieldTextForTopPageAtIdx:0] isEqualToString:@"-10.2"]);

        //3: Should not delete decimal separator (either comma or full stop)
    [self.viewModel updatedTopTextAt:0 text:@"10."];
    XCTAssert([[self.viewModel textFieldTextForTopPageAtIdx:0] isEqualToString:@"-10."]);

    [self.viewModel updatedTopTextAt:0 text:@"10,"];
    XCTAssert([[self.viewModel textFieldTextForTopPageAtIdx:0] isEqualToString:@"-10,"]);

        //4: Should not delete 0 after decimal separator (if user enters 12.0,
        //                                                it should wait until last character)
    [self.viewModel updatedTopTextAt:0 text:@"12.0"];
    XCTAssert([[self.viewModel textFieldTextForTopPageAtIdx:0] isEqualToString:@"-12.0"]);

    [self.viewModel updatedTopTextAt:0 text:@"12,0"];
    XCTAssert([[self.viewModel textFieldTextForTopPageAtIdx:0] isEqualToString:@"-12,0"]);

        //5: Should remove trailing two zeros
    [self.viewModel updatedTopTextAt:0 text:@"10.00"];
    XCTAssert([[self.viewModel textFieldTextForTopPageAtIdx:0] isEqualToString:@"-10"]);

        //6: Should remove everything if only minus sign left
    [self.viewModel updatedTopTextAt:0 text:@"-"];
    XCTAssert([self.viewModel textFieldTextForTopPageAtIdx:0] == nil);

        //7: Should add zero if user starts with decimal point
    [self.viewModel updatedTopTextAt:0 text:@"."];
    XCTAssert([[self.viewModel textFieldTextForTopPageAtIdx:0] isEqualToString:@"-0."]);

    [self.viewModel updatedTopTextAt:0 text:@","];
    XCTAssert([[self.viewModel textFieldTextForTopPageAtIdx:0] isEqualToString:@"-0,"]);

        //8: Should work well when there is minus in front
    [self.viewModel updatedTopTextAt:0 text:@"-10"];
    XCTAssert([[self.viewModel textFieldTextForTopPageAtIdx:0] isEqualToString:@"-10"]);

        //9: Should show the same value on all pages
    [self.viewModel updatedTopTextAt:0 text:@"-10"];
    for (int i = 0; i < [self.viewModel amountOfPages]; i++) {
        XCTAssert([[self.viewModel textFieldTextForTopPageAtIdx:i] isEqualToString:@"-10"]);
    }



}
    // Including many tests in one function as it takes long to set up
- (void)testBottomTextGeneration {
        //1: Should add "+" automatically and copy top, if same currencies selected
    [self.viewModel updatedTopTextAt:0 text:@"10"];
    XCTAssert([[self.viewModel textFieldTextForBottomPageAtIdx:0] isEqualToString:@"+10"]);

        //2: Should show different value according to rate on another page
    [self.viewModel updatedTopTextAt:0 text:@"-34.12"];
    XCTAssertFalse([[self.viewModel textFieldTextForTopPageAtIdx:1] isEqualToString:@"+34.12"]);

}

    // Including many tests in one function as it takes long to set up
- (void)testCanExchange {
        //1: Should not be able to exchange if same currencies are selected
    [self.viewModel updatedCurrentTopPage:0];
    [self.viewModel updatedCurrentBottomPage:0];
    XCTAssertFalse([self.viewModel canExchange]);

        //2: Should not be able to exchange if value is not entered
    [self.viewModel updatedCurrentBottomPage:1];
    XCTAssertFalse([self.viewModel canExchange]);

        //3: Should not be able to exchange if value is bigger than amount in wallet
    [self.viewModel updatedTopTextAt:0 text:@"101"];
    XCTAssertFalse([self.viewModel canExchange]);

        //4: Should be able to exchange maximum value
    [self.viewModel updatedTopTextAt:0 text:@"100"];
    XCTAssert([self.viewModel canExchange]);

        //5: Should be able to exchange minimum value if it will be more than 0.01 in "To" currency
            // I suggest GBP > USD
            // find GBP & Enter minimum amount in GBP (0.01)
    int count = (int)[self.viewModel amountOfPages];
    for (int i = 0; i < count; i++) {
        if ([[self.viewModel titleForPageAtIdx:i] isEqualToString:@"GBP"]) {
            [self.viewModel updatedCurrentTopPage:i];
            [self.viewModel updatedTopTextAt:i text:@"0.01"];
            break;
        }
    }
            // find USD
    for (int i = 0; i < count; i++) {
        if ([[self.viewModel titleForPageAtIdx:i] isEqualToString:@"USD"]) {
            [self.viewModel updatedCurrentBottomPage:i];
            break;
        }
    }

    XCTAssert([self.viewModel canExchange]);

        //6: Should not be able opposite exchange (when result will be less 0.01)
        //P.S. Just copying here
            // I suggest GBP > USD
            // find USD & Enter minimum amount in USD (0.01)
    for (int i = 0; i < count; i++) {
        if ([[self.viewModel titleForPageAtIdx:i] isEqualToString:@"USD"]) {
            [self.viewModel updatedCurrentTopPage:i];
            [self.viewModel updatedTopTextAt:i text:@"0.01"];
            break;
        }
    }
            // find GBP
    for (int i = 0; i < count; i++) {
        if ([[self.viewModel titleForPageAtIdx:i] isEqualToString:@"GBP"]) {
            [self.viewModel updatedCurrentBottomPage:i];
            break;
        }
    }

    XCTAssertFalse([self.viewModel canExchange]);

}

    //Supposing canExchange was called before exchange, so will not test all same cases
    //Simply testing that if we take 50 from 1st currency and translate to 2nd,
    //Amount in 1st wallet will be 50 and in second it will be larger than it was.
- (void)testExchange {

    NSString *leftSubtitle1 = [self.viewModel leftSubtitleForPageAtIdx:1];
    NSString *strAmount1 = [leftSubtitle1 substringFromIndex:10];

    double amount1Before = [strAmount1 doubleValue];

    [self.viewModel updatedCurrentBottomPage:1];
    [self.viewModel updatedTopTextAt:0 text:@"50"];

    XCTAssert([self.viewModel exchange]);
    NSString *leftSubtitle0 = [self.viewModel leftSubtitleForPageAtIdx:0];
    NSString *strAmount0 = [leftSubtitle0 substringFromIndex:10];

    XCTAssert([strAmount0 isEqualToString:@"50.00"]);

    leftSubtitle1 = [self.viewModel leftSubtitleForPageAtIdx:1];
    strAmount1 = [leftSubtitle1 substringFromIndex:10];

    double amount1After = [strAmount1 doubleValue];

    XCTAssert(amount1After > amount1Before);


}

@end
