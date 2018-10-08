//
//  XkeysServer.m
//  XkeysFramework
//
//  Created by Ken Heglund on 10/25/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import <XkeysKit/XkeysControl.h>
#import <XkeysKit/XkeysDevice.h>

#import "XkeysHIDMonitor.h"
#import "XkeysIdentifiers.h"
#import "XkeysMacHIDSystem.h"
#import "XkeysUnit.h"
#import "XkeysUnitLibrary.h"

#import "XkeysServer.h"

// MARK: - XkeysServer private interface

static NSString * const XkeysServerAnyControlChangedKey = @"XkeysServerAnyControlChangedKey";

@interface XkeysServer ()

@property (nonatomic) id <XkeysHIDSystem> hidSystem;
@property (nonatomic) XkeysHIDMonitor *hidMonitor;
@property (nonatomic) XkeysUnitLibrary *unitLibrary;
@property (nonatomic) BOOL isOpen;

@property (nonatomic) NSMutableArray<XkeysUnit<XkeysDevice> *> *attachedDevices;
@property (nonatomic) NSMutableArray<XkeysUnit<XkeysDevice> *> *configuredDevices;

@property (nonatomic, copy) XkeysDeviceCallback deviceAttachCallback;
@property (nonatomic, copy) XkeysDeviceCallback deviceDetachCallback;
@property (nonatomic, copy) XkeysControlCallback anyControlChangeCallback;
@property (nonatomic) NSMutableDictionary<XkeysControlIdentifier, XkeysControlCallback> *controlCallbacks;

@end

// MARK: - XkeysServer implementation

@implementation XkeysServer

- (instancetype)initWithHIDSystem:(id <XkeysHIDSystem>)hidSystem {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _hidSystem = hidSystem;
    _attachedDevices = [[NSMutableArray alloc] init];
    _configuredDevices = [[NSMutableArray alloc] init];
    _controlCallbacks = [[NSMutableDictionary alloc] init];
    _unitLibrary = [[XkeysUnitLibrary alloc] initWithHIDSystem:_hidSystem];
    
    __weak XkeysServer *weakSelf = self;
    
    _hidMonitor = [[XkeysHIDMonitor alloc] initWithHIDSystem:_hidSystem];
    _hidMonitor.onDeviceAttached = ^(IOHIDDeviceRef _Nonnull hidDevice) {
        XkeysServer *server = weakSelf;
        [server handleAttachedHIDDevice:hidDevice];
    };
    
    return self;
}

- (instancetype)init {
    return [self initWithHIDSystem:[[XkeysMacHIDSystem alloc] init]];
}

// MARK: - Public

+ (XkeysServer *)shared {
    
    static XkeysServer *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[XkeysServer alloc] init];
    });
    
    return sharedInstance;
}

- (NSArray<id<XkeysDevice>> *)devices {
    return [self.configuredDevices copy];
}

- (id<XkeysDevice> _Nullable)deviceWithIdentifier:(XkeysIdentifier)identifier {
    
    for ( id<XkeysDevice> unit in self.configuredDevices ) {
        if ( [XkeysIdentifiers identifier:identifier matchesUnit:unit] ) {
            return unit;
        }
    }
    
    return nil;
}

- (void)onDeviceAttachPerform:(XkeysDeviceCallback _Nullable)callback {
    self.deviceAttachCallback = callback;
}

- (void)onDeviceDetachPerform:(XkeysDeviceCallback _Nullable)callback {
    self.deviceDetachCallback = callback;
}

- (void)onAnyControlValueChangePerform:(XkeysControlCallback _Nullable)callback {
    self.anyControlChangeCallback = callback;
}

- (void)onControlValueChange:(XkeysIdentifier)controlIdentifier perform:(XkeysControlCallback _Nullable)callback {
    
    if ( callback ) {
        self.controlCallbacks[controlIdentifier] = [callback copy];
    }
    else {
        [self.controlCallbacks removeObjectForKey:controlIdentifier];
    }
}

- (void)open:(XkeysServerOptions)options {
    
    if ( self.isOpen) {
        return;
    }
    
    [XkeysIdentifiers setProductIDMatchRequired:((options & XkeysServerOptionMatchProductID) != 0)];
    [XkeysIdentifiers setUnitIDMatchRequired:((options & XkeysServerOptionMatchUnitID) != 0)];
    
    [self.hidMonitor open];
    
    self.isOpen = YES;
}

- (void)close {
    
    if ( ! self.isOpen ) {
        return;
    }
    
    [self.hidMonitor close];
    
    for ( XkeysUnit<XkeysDevice> *device in self.attachedDevices ) {
        [device close];
    }
    
    self.isOpen = NO;
    
    [self.attachedDevices removeAllObjects];
    [self.configuredDevices removeAllObjects];
}

+ (XkeysDeviceIdentifier _Nullable)deviceIdentifierFromIdentifier:(XkeysIdentifier)identifier {
    return [XkeysIdentifiers deviceIdentifierFromIdentifier:identifier preservingUnitID:YES];
}

+ (XkeysDeviceIdentifier _Nullable)deviceIndependentIdentifierFromIdentifier:(XkeysIdentifier)identifier {
    return [XkeysIdentifiers deviceIdentifierFromIdentifier:identifier preservingUnitID:NO];
}

// MARK: - Internal

- (void)handleAttachedHIDDevice:(IOHIDDeviceRef)hidDevice {
    
    XkeysUnit<XkeysDevice> *newUnit = [self.unitLibrary makeUnitForHIDDevice:hidDevice];
    if ( newUnit == nil ) {
        return;
    }
    
    [self.attachedDevices addObject:newUnit];
    
    __weak XkeysServer *weakSelf = self;
    
    newUnit.onUnitConfigured = ^(XkeysUnit<XkeysDevice> *configuredUnit) {
        
        XkeysServer *server = weakSelf;
        
#if PRINT_DEVICE_DESCRIPTIONS && 0
        [configuredUnit printDebugDescription];
#endif // PRINT_DEVICE_DESCRIPTIONS
        
        if ( ! server.isOpen ) {
            return;
        }
        
        [server.configuredDevices addObject:configuredUnit];
        
        [configuredUnit setValueChangeCallbackForKey:XkeysServerAnyControlChangedKey callback:^BOOL(id<XkeysControl> control) {
            XkeysServer *server = weakSelf;
            [server handleControlValueChange:control];
            return YES;
        }];
        
        XkeysDeviceCallback callback = server.deviceAttachCallback;
        if ( callback == NULL ) {
            return;
        }
        
        callback(configuredUnit);
    };
    
    newUnit.onUnitTerminated = ^(XkeysUnit<XkeysDevice> *terminatedUnit) {
        
        XkeysServer *server = weakSelf;
        
        if ( ! server.isOpen ) {
            return;
        }
        
        BOOL unitConfigured = [server.configuredDevices containsObject:terminatedUnit];
        
        [server.configuredDevices removeObject:terminatedUnit];
        [server.attachedDevices removeObject:terminatedUnit];
        
        [terminatedUnit setValueChangeCallbackForKey:XkeysServerAnyControlChangedKey callback:NULL];
        
        if ( ! unitConfigured ) {
            return;
        }
        
        XkeysDeviceCallback callback = server.deviceDetachCallback;
        if ( callback == NULL ) {
            return;
        }
        
        callback(terminatedUnit);
    };
    
    [newUnit open];
}

- (void)handleControlValueChange:(id<XkeysControl>)control {
    
    XkeysControlCallback anyControlCallback = self.anyControlChangeCallback;
    if ( anyControlCallback ) {
        
        if ( ! anyControlCallback(control) ) {
            self.anyControlChangeCallback = NULL;
        }
    }
    
    for ( XkeysControlIdentifier identifier in self.controlCallbacks.allKeys ) {
        
        if ( [control matchesIdentifier:identifier] ) {
            
            XkeysControlCallback callback = self.controlCallbacks[identifier];
            
            if ( ! callback(control) ) {
                [self.controlCallbacks removeObjectForKey:identifier];
            }
        }
    }
}

@end
