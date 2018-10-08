//
//  XkeysServerController.m
//  XkeysViewer
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XkeysServerController.h"

static NSString * const XkeysServerController_key_devices = @"devices";

@implementation XkeysServerController

- (instancetype)init {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _devices = [[NSMutableArray alloc] init];
    
    XkeysServer *xkeysServer = [XkeysServer shared];
    
    __weak XkeysServerController *weakSelf = self;

    [xkeysServer onDeviceAttachPerform:^(id<XkeysDevice> device) {
        
        XkeysServerController *controller = weakSelf;
        [[controller mutableArrayValueForKey:XkeysServerController_key_devices] addObject:device];
        
        NSLog(@"XkeysServerController sees attachment of: %@ Unit #%u (%@)", device.name, device.unitID, device.identifier);
    }];
    
    [xkeysServer onDeviceDetachPerform:^(id<XkeysDevice> device) {
        
        XkeysServerController *controller = weakSelf;
        [[controller mutableArrayValueForKey:XkeysServerController_key_devices] removeObject:device];
        
        NSLog(@"XkeysServerController sees detachment of: %@ Unit #%u (%@)", device.name, device.unitID, device.identifier);
    }];
    
    [xkeysServer open:XkeysServerOptionNone];
    
    return self;
}

- (void)dealloc {
    [[XkeysServer shared] close];
}

@end
