//
//  CurrencyExchangePageViewCell.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CurrencyExchangePageViewCellDelegate;

@interface CurrencyExchangePageViewCell : UIView <UITextFieldDelegate>

-(void)setTitle:(NSString *)title;
-(void)setLeftSubtitle:(NSString *)subtitle;
-(void)setRightSubtitle:(NSString *)subtitle;
-(void)setLeftSubtitleColor:(UIColor *)color;
-(void)setTextFieldText:(NSString *)text;

@property (weak, nonatomic) id <CurrencyExchangePageViewCellDelegate> delegate;


@end

@protocol CurrencyExchangePageViewCellDelegate <NSObject>

-(BOOL)shouldBeginEditingCellTextField:(CurrencyExchangePageViewCell *)cell;
-(void)cellTextFieldChanged:(CurrencyExchangePageViewCell *)cell value: (NSString *)value;


@end
