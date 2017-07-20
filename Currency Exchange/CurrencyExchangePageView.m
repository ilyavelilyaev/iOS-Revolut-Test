//
//  CurrencyExchangePageView.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyExchangePageView.h"
#import "CurrencyExchangePageViewCell.h"
#import <Masonry/Masonry.h>

@interface CurrencyExchangePageView ()

@property (weak, nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSArray *cellsArray;
@property (nonatomic) NSMutableArray *cellPositionArray;

@end

@implementation CurrencyExchangePageView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.pagingEnabled = YES;
        scrollView.bounces = YES;
        scrollView.delegate = self;

        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];

        [self addSubview:scrollView];

        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        self.scrollView = scrollView;

        NSMutableArray *cells = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            CurrencyExchangePageViewCell *cell = [[CurrencyExchangePageViewCell alloc] init];
            [scrollView addSubview:cell];
            [cells addObject:cell];

            cell.titleLabel.text = [NSString stringWithFormat:@"%d", i];
        }
        self.cellsArray = [NSArray arrayWithArray:cells];

        self.cellPositionArray = [NSMutableArray arrayWithArray:@[@0, @1, @2]];
    }
    return self;
}


-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    self.scrollView.contentSize = CGSizeMake(width * 3, height);
    [self configureCellsFrames];
}

-(void)configureCellsFrames {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    for (int i = 0; i < 3; i++) {
        CurrencyExchangePageViewCell *cell = self.cellsArray[i];
        NSNumber *cellPosition = self.cellPositionArray[i];
        cell.frame = CGRectMake([cellPosition integerValue] * width, 0, width, height);
    }
}

-(void)reloadData {

}

-(void)reloadDataAt:(NSUInteger)idx {

}

-(void)scrollToPageAt:(NSUInteger)idx {

}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    self.scrollView.scrollEnabled = NO;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat width = self.bounds.size.width;
    CGFloat currentOffsetX = self.scrollView.contentOffset.x;

    int idx = round(currentOffsetX / width);
    int currentIdx = [self.cellPositionArray[idx] intValue];

    if (idx == 2) {
        self.cellPositionArray[0] = [NSNumber numberWithInt:(currentIdx) % 3];
        self.cellPositionArray[1] = [NSNumber numberWithInt:(currentIdx + 1) % 3];
        self.cellPositionArray[2] = [NSNumber numberWithInt:(currentIdx + 2) % 3];
    } else if (idx == 0) {
        self.cellPositionArray[0] = [NSNumber numberWithInt:(currentIdx + 1) % 3];
        self.cellPositionArray[1] = [NSNumber numberWithInt:(currentIdx + 2) % 3];
        self.cellPositionArray[2] = [NSNumber numberWithInt:(currentIdx) % 3];
    }

    [self configureCellsFrames];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width / 3, 0);
    self.scrollView.scrollEnabled = YES;
}

@end
