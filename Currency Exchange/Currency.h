//
//  Currency.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Currency : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *_Nonnull code;

- (NSString *_Nonnull)symbol;

- (instancetype _Nullable)initWithCode:(NSString *_Nonnull)code;

+ (instancetype _Nullable)eurCurrency;
+ (instancetype _Nullable)usdCurrency;
+ (instancetype _Nullable)gbpCurrency;



@end
