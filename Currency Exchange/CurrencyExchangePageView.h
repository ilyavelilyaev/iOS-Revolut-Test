//
//  CurrencyExchangePageView.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrencyExchangePageViewCell.h"

@protocol CurrencyExchangePageViewDataSource;
@protocol CurrencyExchangePageViewDelegate;


@interface CurrencyExchangePageView : UIView <UIScrollViewDelegate, CurrencyExchangePageViewCellDelegate>

@property (nonatomic, weak) id <CurrencyExchangePageViewDataSource> dataSource;
@property (nonatomic, weak) id <CurrencyExchangePageViewDelegate> delegate;

-(void)reloadData;

@end


@protocol CurrencyExchangePageViewDataSource <NSObject>

-(NSUInteger)amountOfPages:(CurrencyExchangePageView *)pageView;
-(NSString *)titleForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx;
-(NSString *)leftSubtitleForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx;
-(NSString *)rightSubtitleForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx;
-(UIColor *)leftSubtitleColorForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx;
-(NSString *)textFieldTextForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx;
-(BOOL)isEditingActive:(CurrencyExchangePageView *)pageView;

@end

@protocol CurrencyExchangePageViewDelegate <NSObject>

-(void)pageView:(CurrencyExchangePageView *)pageView didScrollToPageAt:(NSUInteger)idx;
-(void)pageView:(CurrencyExchangePageView *)pageView
didChangeTextFieldTextAt:(NSUInteger)idx
           text:(NSString *)text;

@end
