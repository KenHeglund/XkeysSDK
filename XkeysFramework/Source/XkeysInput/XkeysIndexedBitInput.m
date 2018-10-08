//
//  XkeysIndexedBitInput.m
//  XkeysFramework
//
//  Created by Ken Heglund on 3/8/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

#import "XkeysIndexedBitInput.h"

@interface XkeysIndexedBitInput ()

@property (nonatomic) NSInteger bitIndex;

@end

// MARK: -

@implementation XkeysIndexedBitInput

- (instancetype)initWithDevice:(id<XkeysDevice>)device cookie:(IOHIDElementCookie)cookie bitIndex:(NSInteger)bitIndex controlIndex:(NSInteger)controlIndex {
    
    self = [super initWithDevice:device cookie:cookie controlIndex:controlIndex];
    if ( ! self  ){
        return nil;
    }
    
    const NSInteger sizeOfValueInBits = sizeof(CFIndex) * 8;
    NSAssert(bitIndex < sizeOfValueInBits, @"");
    if ( bitIndex >= sizeOfValueInBits ) {
        return nil;
    }
    
    _bitIndex = bitIndex;
    
    return self;
}

// MARK: - XkeysInput overrides

- (BOOL)handleInputValue:(CFIndex)value {
    NSInteger mask = (1 << self.bitIndex);
    NSInteger controlValue = ((value & mask) == mask ? 1 : 0);
    return [super handleInputValue:controlValue];
}

@end
