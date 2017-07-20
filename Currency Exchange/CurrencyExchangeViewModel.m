//
//  CurrencyExchangeViewModel.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyExchangeViewModel.h"


@implementation CurrencyExchangeViewModel

-(NSUInteger)amountOfPages:(CurrencyExchangePageView *)pageView {
    return 4;
}
-(NSString *)titleForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx {
    NSArray *temp = @[@"GBP", @"USD", @"RUB", @"EUR"];
    return temp[idx];
}
-(NSString *)leftSubtitleForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx {
    return nil;
}
-(NSString *)rightSubtitleForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx {
    return nil;
}
-(UIColor *)leftSubtitleColorForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx {
    return nil;
}
-(NSString *)textFieldTextForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx {
    return nil;
}
-(BOOL)isEditingActive:(CurrencyExchangePageView *)pageView {
    return YES;
}

-(void)pageView:(CurrencyExchangePageView *)pageView didScrollToPageAt:(NSUInteger)idx {

}
-(void)pageView:(CurrencyExchangePageView *)pageView didChangeTextFieldValueAt:(NSUInteger)idx {

}


@end
