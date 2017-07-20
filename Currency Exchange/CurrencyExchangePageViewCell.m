//
//  CurrencyExchangePageViewCell.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "CurrencyExchangePageViewCell.h"
#import <Masonry/Masonry.h>

@implementation CurrencyExchangePageViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        UILabel *title = [[UILabel alloc] init];
        [self addSubview:title];

        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];

        self.titleLabel = title;
    }
    return self;
}

@end
