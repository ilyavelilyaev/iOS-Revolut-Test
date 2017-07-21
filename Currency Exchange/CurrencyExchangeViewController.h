//
//  CurrencyExchangeViewController.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrencyExchangePageView.h"
#import "CurrencyExchangeViewModel.h"

@class CurrencyExchangeViewModel;

@interface CurrencyExchangeViewController : UIViewController
<CurrencyExchangePageViewDataSource, CurrencyExchangePageViewDelegate>

@property (nonatomic) CurrencyExchangeViewModel *viewModel;


-(void)reloadTopCurrencyView;
-(void)reloadPageControl;
-(void)reloadPageViews;


@end
