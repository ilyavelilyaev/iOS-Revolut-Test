//
//  CurrencyExchangeViewController.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyExchangeViewController.h"
#import "CurrencyExchangePageView.h"
#import "CurrencyExchangeViewModel.h"

@interface CurrencyExchangeViewController ()

@property (weak, nonatomic) IBOutlet UIView *topCurrencyBoxView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBoxBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exchangeBoxHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *exchangeButton;
@property (weak, nonatomic) IBOutlet UILabel *topCurrencyBoxExchangeRateLabel;

@property (weak, nonatomic) IBOutlet UIPageControl *topPageControl;
@property (weak, nonatomic) IBOutlet UIPageControl *bottomPageControl;

@property (weak, nonatomic) IBOutlet CurrencyExchangePageView *topExchangePageView;
@property (weak, nonatomic) IBOutlet CurrencyExchangePageView *bottomExchangePageView;

@property (nonatomic) CurrencyExchangeViewModel *viewModel;

@end

@implementation CurrencyExchangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topCurrencyBoxView.layer.borderWidth = 1.0;
    self.topCurrencyBoxView.layer.cornerRadius = 8.0;
    self.topCurrencyBoxView.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.4] CGColor];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    self.viewModel = [[CurrencyExchangeViewModel alloc] init];
    self.topExchangePageView.dataSource = self.viewModel;
    [self.topExchangePageView reloadData];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self adjustTitlesFontSize];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)topCurrencyBoxPressed:(UITapGestureRecognizer *)sender {
    NSLog(@"%s", __FUNCTION__);
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    NSValue *keyboardFrameValue = [notification userInfo][UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    [self setupBoxHeightsKeyboardFrame:keyboardFrame];
}

- (void)setupBoxHeightsKeyboardFrame:(CGRect)keyboardFrame {
    CGFloat keyboardHeight = keyboardFrame.size.height;

    [self.bottomBoxBottomConstraint setConstant:keyboardHeight];

    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat topElementsHeight = 20 + 60 + 10; // status bar + navigation bar + margin

    CGFloat availableHeight = screenHeight - topElementsHeight - keyboardHeight;
    [self.exchangeBoxHeightConstraint setConstant:availableHeight / 2];
}

- (void)adjustTitlesFontSize {

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    UIFont *exchangeButtonFont = self.exchangeButton.titleLabel.font;

    if (screenWidth < 375) {
        [self.exchangeButton.titleLabel setFont:[exchangeButtonFont fontWithSize:15]];
    }

}


@end
