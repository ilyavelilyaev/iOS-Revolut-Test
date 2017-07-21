//
//  CurrencyExchangeViewModel.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrencyExchangePageView.h"
#import "CurrencyExchangeViewController.h"
#import "CurrencyRateProvider.h"

@class CurrencyExchangeViewController;

@interface CurrencyExchangeViewModel : NSObject
<CurrencyRateProviderDelegate>

@property (weak, nonatomic) CurrencyExchangeViewController *currencyExchangeViewController;

-(void)load;
-(BOOL)exchange;

-(BOOL)canExchange;

-(NSAttributedString *)textForTopCurrencyView;
-(BOOL)shouldShowTopCurrencyView;
-(NSUInteger)amountOfPages;
-(NSString *)titleForPageAtIdx:(NSUInteger)idx;
-(NSString *)leftSubtitleForPageAtIdx:(NSUInteger)idx;
-(NSString *)rightSubtitleForBottomPageAtIdx:(NSUInteger)idx;
-(UIColor *)leftSubtitleColorForTopPageAtIdx:(NSUInteger)idx;
-(NSString *)textFieldTextForTopPageAtIdx:(NSUInteger)idx;
-(NSString *)textFieldTextForBottomPageAtIdx:(NSUInteger)idx;
-(BOOL)editingActiveForTopPage;
-(BOOL)editingActiveForBottomPage;

-(void)updatedCurrentTopPage:(NSUInteger)idx;
-(void)updatedCurrentBottomPage:(NSUInteger)idx;

-(void)updatedTopTextAt:(NSUInteger)idx text:(NSString *)text;
-(void)updatedBottomTextAt:(NSUInteger)idx text:(NSString *)text;


@end
