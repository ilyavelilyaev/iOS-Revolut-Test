//
//  CurrencyExchangePageView.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CurrencyExchangePageViewDataSource;
@protocol CurrencyExchangePageViewDelegate;


@interface CurrencyExchangePageView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) id <CurrencyExchangePageViewDataSource> dataSource;
@property (nonatomic, weak) id <CurrencyExchangePageViewDelegate> delegate;

- (void)reloadData;
- (void)reloadDataAt:(NSUInteger)idx;
- (void)scrollToPageAt:(NSUInteger)idx;

@end


@protocol CurrencyExchangePageViewDataSource <NSObject>

- (NSUInteger)amountOfPagesIn:(CurrencyExchangePageView *)pageView;
- (NSString *)titleForPageAt:(NSUInteger)idx;
- (NSString *)leftSubtitleForPageAt:(NSUInteger)idx;
- (NSString *)rightSubtitleForPageAt:(NSUInteger)idx;
- (UIColor *)leftSubtitleColorForPageAt:(NSUInteger)idx;

@end

@protocol CurrencyExchangePageViewDelegate <NSObject>

- (void)pageViewDidScrollToPageAt:(NSUInteger)idx;
- (void)pageViewDidChangeTextFieldValueAt:(NSUInteger)idx;

@end
