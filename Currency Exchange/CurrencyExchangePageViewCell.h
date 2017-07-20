//
//  CurrencyExchangePageViewCell.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyExchangePageViewCell : UIView

@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *leftSubtitleLabel;
@property (weak, nonatomic) UILabel *rightSubtitleLabel;
@property (weak, nonatomic) UITextField *inputTextField;

@end
