//
//  CurrencyExchangePageViewCell.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyExchangePageViewCell.h"
#import <Masonry/Masonry.h>

@interface CurrencyExchangePageViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftTrailingConstraint;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightSubtitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *leftSubtitleLabel;

@end

@implementation CurrencyExchangePageViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = nil;
    self.rightSubtitleLabel.text = nil;
    self.textField.text = nil;
    self.leftSubtitleLabel.text = nil;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;

    if (width < 375) {
        [self.rightTrailingConstraint setConstant:18];
        [self.rightTrailingConstraint setConstant:18];
    }
    [self adjustSubtitlesFontSizes];
}

-(void)adjustSubtitlesFontSizes {

    UIFont *rightFont = self.rightSubtitleLabel.font;
    UIFont *leftFont = self.leftSubtitleLabel.font;

    CGFloat fontSize = fmin(rightFont.pointSize, leftFont.pointSize);
    [self.rightSubtitleLabel setFont: [rightFont fontWithSize:fontSize]];
    [self.leftSubtitleLabel setFont: [leftFont fontWithSize:fontSize]];
}

- (IBAction)textFieldChangedEditing:(UITextField *)sender {
    [self.delegate cellTextFieldChanged:self value:sender.text];
}

-(BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

-(BOOL)resignFirstResponder {
    return [self.textField resignFirstResponder];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return [self.delegate shouldBeginEditingCellTextField:self];
}

-(BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {

    if (!string.length)
        return YES;

    NSError *error = nil;

        //Allow only two digits after decimal point
    NSString *expression = @"^[-+]?\\d+([.,]\\d{0,2}){0,1}$";
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:expression
                                              options:0
                                                error:&error];

    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];

    NSUInteger numberOfMatches = [regex numberOfMatchesInString:result
                                                        options:0
                                                          range:NSMakeRange(0, [result length])];
    
    if (numberOfMatches == 0)
        return NO;

    return result.length < 10;

}

-(void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
}

-(void)setLeftSubtitle:(NSString *)subtitle {
    [self.leftSubtitleLabel setText:subtitle];
}

-(void)setRightSubtitle:(NSString *)subtitle {
    [self.rightSubtitleLabel setText:subtitle];
}

-(void)setLeftSubtitleColor:(UIColor *)color {
    [self.leftSubtitleLabel setTextColor:color];
}

-(void)setTextFieldText:(NSString *)text {
    [self.textField setText:text];
}

@end
