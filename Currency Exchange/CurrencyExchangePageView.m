//
//  CurrencyExchangePageView.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyExchangePageView.h"
#import <Masonry/Masonry.h>

@interface CurrencyExchangePageView () {
    NSUInteger objectsCount;
    NSUInteger currentIdxShowing;
    BOOL isActive;
}

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
        scrollView.clipsToBounds = YES;

        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];

        [self addSubview:scrollView];

        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        self.scrollView = scrollView;

        NSMutableArray *cells = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            UINib *cellNib = [UINib nibWithNibName:@"CurrencyExchangePageViewCell" bundle:nil];
            CurrencyExchangePageViewCell *cell = [cellNib instantiateWithOwner:nil options:nil][0];
            [scrollView addSubview:cell];
            [cells addObject:cell];
            cell.delegate = self;
        }
        self.cellsArray = [NSArray arrayWithArray:cells];

        self.cellPositionArray = [NSMutableArray arrayWithArray:@[@0, @1, @2]];

        currentIdxShowing = 0;
        objectsCount = 0;
        isActive = NO;
    }
    return self;
}


-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    self.scrollView.contentSize = objectsCount == 0 ? CGSizeZero : CGSizeMake(width * 3, height);
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width / 3, 0);
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

-(void)configureVisibleCells {
    if (currentIdxShowing > 0) {
        [self configureCellIdx:0 objectIdx:currentIdxShowing - 1];
    } else {
        [self configureCellIdx:0 objectIdx:objectsCount - 1];
    }
    [self configureCellIdx:1 objectIdx:currentIdxShowing];
    [self configureCellIdx:2 objectIdx:(currentIdxShowing + 1) % objectsCount];
}

-(void)configureCellIdx:(NSUInteger)cellIdx objectIdx:(NSUInteger)objectIdx {

    NSUInteger realIdx = [self.cellPositionArray indexOfObject:[NSNumber numberWithUnsignedInteger:cellIdx]];

    CurrencyExchangePageViewCell *cell = self.cellsArray[realIdx];
    [cell setTitle:[self.dataSource titleForPage:self at:objectIdx]];
    [cell setLeftSubtitle:[self.dataSource leftSubtitleForPage:self at:objectIdx]];
    [cell setRightSubtitle:[self.dataSource rightSubtitleForPage:self at:objectIdx]];
    [cell setTextFieldText:[self.dataSource textFieldTextForPage:self at:objectIdx]];
    [cell setLeftSubtitleColor:[self.dataSource leftSubtitleColorForPage:self at:objectIdx]];

    if (cellIdx == 1 && isActive) {
        [cell becomeFirstResponder];
    }
}

-(void)reloadData {
    objectsCount = [self.dataSource amountOfPages:self];
    isActive = [self.dataSource isEditingActive:self];
    [self configureVisibleCells];
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
        currentIdxShowing = (currentIdxShowing + 1) % objectsCount;
    } else if (idx == 0) {
        self.cellPositionArray[0] = [NSNumber numberWithInt:(currentIdx + 1) % 3];
        self.cellPositionArray[1] = [NSNumber numberWithInt:(currentIdx + 2) % 3];
        self.cellPositionArray[2] = [NSNumber numberWithInt:(currentIdx) % 3];
        currentIdxShowing = (currentIdxShowing + objectsCount - 1) % objectsCount;
    }
    [self.delegate pageView:self didScrollToPageAt:currentIdxShowing];
    [self configureCellsFrames];
    [self configureVisibleCells];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width / 3, 0);
    self.scrollView.scrollEnabled = YES;
}


-(BOOL)shouldBeginEditingCellTextField:(CurrencyExchangePageViewCell *)cell {
    return isActive;
}


-(void)cellTextFieldChanged:(CurrencyExchangePageViewCell *)cell value: (NSString *)value {
    [self.delegate pageView:self didChangeTextFieldTextAt:currentIdxShowing text:value];
}

@end
