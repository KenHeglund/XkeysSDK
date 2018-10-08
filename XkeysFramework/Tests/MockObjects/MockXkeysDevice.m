//
//  MockXkeysDevice.m
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import XkeysKit;

#import "XkeysUnitLibrary.h"

#import "MockXkeysDevice.h"

@implementation MockXkeysDevice

- (instancetype)initWithProductID:(NSInteger)productID {
    return [super initWithVendorID:1523 productID:productID];
}

- (XkeysModel)model {
    return [XkeysUnitLibrary modelFromProductID:self.productID];
}

// MARK: - MockXkeysDevice implementation

+ (BOOL)areZerosInReport:(const uint8_t *)report fromIndex:(size_t)startIndex toIndex:(size_t)endIndex {
    
    NSAssert(report != NULL, @"");
    if ( report == NULL ) {
        return NO;
    }
    
    for ( size_t index = startIndex ; index <= endIndex ; index++ ) {
        if ( report[index] != 0 ) {
            return NO;
        }
    }
    
    return YES;
}

@end
