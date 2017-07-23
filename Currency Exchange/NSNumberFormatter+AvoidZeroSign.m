//
//  NSNumberFormatter+AvoidZeroSign.m
//  Currency Exchange
//
//  Created by Ilya Velilyaev on 23.07.17.
//  Copyright © 2017 1. All rights reserved.
//

#import "NSNumberFormatter+AvoidZeroSign.h"

@implementation NSNumberFormatter (AvoidZeroSign)

- (NSString *)stringFromNumberAvoidingZeroSign:(NSDecimalNumber *)number {

    NSMutableString *string = [[self stringFromNumber: number] mutableCopy];
    if ([number isEqualToNumber:[NSDecimalNumber zero]]) {
        [string replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }
    
    return string;
}

@end

