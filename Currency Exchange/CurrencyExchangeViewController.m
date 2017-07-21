//
//  CurrencyExchangeViewController.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyExchangeViewController.h"

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

@end

@implementation CurrencyExchangeViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.topCurrencyBoxView.layer.borderWidth = 1.0;
    self.topCurrencyBoxView.layer.cornerRadius = 8.0;
    self.topCurrencyBoxView.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.4] CGColor];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];


    self.viewModel = [[CurrencyExchangeViewModel alloc] init];
    self.viewModel.currencyExchangeViewController = self;

    self.topExchangePageView.dataSource = self;
    self.topExchangePageView.delegate = self;
    self.bottomExchangePageView.dataSource = self;
    self.bottomExchangePageView.delegate = self;

    [self.viewModel load];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self adjustTitlesFontSize];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(IBAction)topCurrencyBoxPressed:(UITapGestureRecognizer *)sender {
    NSLog(@"%s", __FUNCTION__);
}

- (IBAction)exchangeButtonPressed:(UIButton *)sender {
    BOOL success = [self.viewModel exchange];
    if (!success) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error!"
                                              message:@"You do not have enough funds for exchange."
                                              preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    [self reloadPageViews];
    [self reloadExchangeButton];
}

#pragma mark UI Adjustment Methods

-(void)keyboardWillAppear:(NSNotification *)notification {
    NSValue *keyboardFrameValue = [notification userInfo][UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    [self setupBoxHeightsKeyboardFrame:keyboardFrame];
}

-(void)setupBoxHeightsKeyboardFrame:(CGRect)keyboardFrame {
    CGFloat keyboardHeight = keyboardFrame.size.height;

    [self.bottomBoxBottomConstraint setConstant:keyboardHeight];

    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat topElementsHeight = 20 + 60 + 10; // status bar + navigation bar + margin

    CGFloat availableHeight = screenHeight - topElementsHeight - keyboardHeight;
    [self.exchangeBoxHeightConstraint setConstant:availableHeight / 2];
}

-(void)adjustTitlesFontSize {

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    UIFont *exchangeButtonFont = self.exchangeButton.titleLabel.font;

    if (screenWidth < 375) {
        [self.exchangeButton.titleLabel setFont:[exchangeButtonFont fontWithSize:15]];
    }

}


#pragma mark Reload UI methods

-(void)reloadTopCurrencyView {
    self.topCurrencyBoxExchangeRateLabel.attributedText = [self.viewModel textForTopCurrencyView];
}

-(void)reloadPageControl {
    NSUInteger amountOfPages = [self.viewModel amountOfPages];
    [self.topPageControl setNumberOfPages:amountOfPages];
    [self.bottomPageControl setNumberOfPages:amountOfPages];
}

-(void)reloadPageViews {
    [self.topExchangePageView reloadData];
    [self.bottomExchangePageView reloadData];
}

-(void)reloadExchangeButton {
    BOOL enabled = [self.viewModel canExchange];
    [self.exchangeButton setEnabled:enabled];

}

#pragma mark Page View DataSource

-(NSUInteger)amountOfPages:(CurrencyExchangePageView *)pageView {
    return [self.viewModel amountOfPages];
}

-(NSString *)titleForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx {
    return [self.viewModel titleForPageAtIdx:idx];
}

-(NSString *)leftSubtitleForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx {
    return [self.viewModel leftSubtitleForPageAtIdx:idx];
}

-(NSString *)rightSubtitleForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx {
    if (pageView == self.bottomExchangePageView)
        return [self.viewModel rightSubtitleForBottomPageAtIdx:idx];

    return nil;
}

-(UIColor *)leftSubtitleColorForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx {
    if (pageView == self.topExchangePageView)
        return [self.viewModel leftSubtitleColorForTopPageAtIdx:idx];

    return [UIColor whiteColor];
}

-(NSString *)textFieldTextForPage:(CurrencyExchangePageView *)pageView at:(NSUInteger)idx {
    if (pageView == self.topExchangePageView)
        return [self.viewModel textFieldTextForTopPageAtIdx:idx];

    if (pageView == self.bottomExchangePageView)
        return [self.viewModel textFieldTextForBottomPageAtIdx:idx];

    return nil;
}

-(BOOL)isEditingActive:(CurrencyExchangePageView *)pageView {
    if (pageView == self.topExchangePageView)
        return [self.viewModel editingActiveForTopPage];

    if (pageView == self.bottomExchangePageView)
        return [self.viewModel editingActiveForBottomPage];

    return NO;
}


#pragma mark Page View Delegate

-(void)pageView:(CurrencyExchangePageView *)pageView didScrollToPageAt:(NSUInteger)idx {
    if (pageView == self.topExchangePageView) {
        [self.viewModel updatedCurrentTopPage:idx];
        [self.topPageControl setCurrentPage:idx];
    }

    if (pageView == self.bottomExchangePageView) {
        [self.viewModel updatedCurrentBottomPage:idx];
        [self.bottomPageControl setCurrentPage:idx];
    }
}

-(void)pageView:(CurrencyExchangePageView *)pageView
didChangeTextFieldTextAt:(NSUInteger)idx
           text:(NSString *)text {
    if (pageView == self.topExchangePageView)
        [self.viewModel updatedTopTextAt:idx text:text];

    if (pageView == self.bottomExchangePageView)
        [self.viewModel updatedBottomTextAt:idx text:text];
}

@end
