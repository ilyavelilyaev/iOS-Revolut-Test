//
//  Currency.h
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 20.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Currency : NSObject

@property (nonatomic, copy, readonly) NSString *_Nonnull code;
@property (nonatomic, assign) double rate;

- (NSString *_Nullable)symbol;
- (double)value:(double)value convertedTo:(Currency *_Nonnull)currency;

- (instancetype _Nullable)initWithCode:(NSString *_Nonnull)code;

@end
