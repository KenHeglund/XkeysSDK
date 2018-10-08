//
//  XkeysOutput.m
//  XkeysFramework
//
//  Created by Ken Heglund on 3/8/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

#import "XkeysIdentifiers.h"

#import "XkeysOutput.h"

@implementation XkeysOutput

- (instancetype)initWithDevice:(XkeysUnit<XkeysDevice> *)device name:(NSString *)name controlIndex:(NSInteger)controlIndex {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _device = device;
    _name = [name copy];
    _controlIndex = controlIndex;
    
    return self;
}

- (NSString *)identifier {
    return [XkeysIdentifiers identifierForOutput:self];
}

@end
