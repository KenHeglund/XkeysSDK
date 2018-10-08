//
//  XkeysServer+Private.h
//  XkeysFramework
//
//  Created by Ken Heglund on 11/10/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XkeysServer.h"
#import "XkeysHIDSystem.h"

@interface XkeysServer (Private)

- (instancetype)initWithHIDSystem:(id <XkeysHIDSystem>)hidSystem;

@end
