//
//  XKE124TBarViewController.m
//  XkeysViewer
//
//  Created by Ken Heglund on 10/24/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import XkeysKit;

#import "XKE124TBarState.h"
#import "XKE124TBarView.h"

#import "XKE124TBarViewController.h"

static NSString * const Xkeys124VC_keyPath_greenLEDStateTag = @"greenLEDStateTag";
static NSString * const Xkeys124VC_keyPath_redLEDStateTag = @"redLEDStateTag";
static void * Xkeys124VC_KVOContext = @"Xkeys124VC_KVOContext";

@interface XKE124TBarViewController ()

@property (nonatomic) NSInteger greenLEDStateTag;
@property (nonatomic) NSInteger redLEDStateTag;

@property (nonatomic) BOOL kvoRegistered;

@end

// MARK: -

@implementation XKE124TBarViewController

- (instancetype)initWithXkeysDevice:(id<XkeysDevice>)xkeysDevice {
    
    self = [super initWithNibName:@"XKE124TbarView" bundle:nil xkeysDevice:xkeysDevice];
    if ( ! self ) {
        return nil;
    }
    
    _greenLEDStateTag = self.xkeys124Device.greenLED.state;
    _redLEDStateTag = self.xkeys124Device.redLED.state;
    
    [self addObserver:self forKeyPath:Xkeys124VC_keyPath_greenLEDStateTag options:0 context:Xkeys124VC_KVOContext];
    [self addObserver:self forKeyPath:Xkeys124VC_keyPath_redLEDStateTag options:0 context:Xkeys124VC_KVOContext];
    _kvoRegistered = YES;
    
    return self;
}

- (void)dealloc {
    
    if ( _kvoRegistered ) {
        [self removeObserver:self forKeyPath:Xkeys124VC_keyPath_greenLEDStateTag context:Xkeys124VC_KVOContext];
        [self removeObserver:self forKeyPath:Xkeys124VC_keyPath_redLEDStateTag context:Xkeys124VC_KVOContext];
    }
}

// MARK: - NSKeyValueObserving implementation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ( context != Xkeys124VC_KVOContext ) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if ( [keyPath isEqualToString:Xkeys124VC_keyPath_greenLEDStateTag] ) {
        
        if ( self.xkeys124Device.greenLED.state == self.greenLEDStateTag ) {
            return;
        }
        
        self.xkeys124Device.greenLED.state = self.greenLEDStateTag;
        self.xkeysState.greenLED = self.greenLEDStateTag;
        [self.xkeysView invalidateLEDs];
    }
    else if ( [keyPath isEqualToString:Xkeys124VC_keyPath_redLEDStateTag] ) {
        
        if ( self.xkeys124Device.redLED.state == self.redLEDStateTag ) {
            return;
        }
        
        self.xkeys124Device.redLED.state = self.redLEDStateTag;
        self.xkeysState.redLED = self.redLEDStateTag;
        [self.xkeysView invalidateLEDs];
    }
}

// MARK: - XKE124TBarViewController implementation

- (XkeysState *)createDeviceState {
    return [[XKE124TBarState alloc] init];
}

- (void)initializeDeviceState {
    
    [super initializeDeviceState];
    
    XkeysState *deviceState = self.xkeysState;
    
    deviceState.greenLED = self.xkeys124Device.greenLED.state;
    deviceState.redLED = self.xkeys124Device.redLED.state;
    
    __weak XKE124TBarViewController *weakSelf = self;
    
    deviceState.onGreenLEDChange = ^(XkeysLEDState state){
        
        XKE124TBarViewController *viewController = weakSelf;
        
        if ( viewController.xkeys124Device.greenLED.state == state ) {
            return;
        }
        
        viewController.xkeys124Device.greenLED.state = state;
        viewController.greenLEDStateTag = state;
    };
    
    deviceState.onRedLEDChange = ^(XkeysLEDState state){
        
        XKE124TBarViewController *viewController = weakSelf;
        
        if ( viewController.xkeys124Device.redLED.state == state ) {
            return;
        }
        
        viewController.xkeys124Device.redLED.state = state;
        viewController.redLEDStateTag = state;
    };
    
    self.xkeys124State.currentTbarPosition = self.xkeys124Device.tbar.currentValue;
}

- (void)initializeDeviceCallbacks {
    
    // This contains a few alternatives on how control callbacks can be configured.
    
    __weak XKE124TBarViewController *weakSelf = self;
    
#if 1 // Uses separate callbacks for buttons and t-bar
    
    [self.xkeys124Device onAnyButtonValueChangePerform:^BOOL(id<XkeysBlueRedButton> button) {
        
        XKE124TBarViewController *viewController = weakSelf;
        XKE124TBarState *deviceState = viewController.xkeys124State;
        XKE124TBarView *deviceView = viewController.xkeys124View;
        
        NSInteger buttonNumber = button.buttonNumber;
        
        if ( button.currentValue ) {
            [deviceState pressButtonNumber:buttonNumber];
        }
        else {
            [deviceState releaseButtonNumber:buttonNumber];
        }
        
        [deviceView invalidateButtonNumber:buttonNumber];
        
        return YES;
    }];
    
    [self.xkeys124Device onTbarValueChangePerform:^BOOL(id<XkeysControl> control) {
        
        XKE124TBarViewController *viewController = weakSelf;
        XKE124TBarState *deviceState = viewController.xkeys124State;
        XKE124TBarView *deviceView = viewController.xkeys124View;
        
        deviceState.currentTbarPosition = control.currentValue;
        [deviceView invalidateTbar];
        
        return YES;
    }];
    
#elif 1 // Uses one callback for all controls
    
    [self.xkeys124Device onAnyControlValueChangePerform:^BOOL(id<XkeysControl> control) {
        
        XKE124TBarViewController *viewController = weakSelf;
        XKE124TBarState *deviceState = viewController.xkeys124State;
        XKE124TBarView *deviceView = viewController.xkeys124View;
        
        if ( [control conformsToProtocol:@protocol(XkeysBlueRedButton)] ) {
            
            id<XkeysBlueRedButton> button = (id<XkeysBlueRedButton>)control;
            
            NSInteger buttonNumber = button.buttonNumber;
            
            if ( button.currentValue ) {
                [deviceState pressButtonNumber:buttonNumber];
            }
            else {
                [deviceState releaseButtonNumber:buttonNumber];
            }
            
            [deviceView invalidateButtonNumber:buttonNumber];
        }
        else if ( control.maximumValue == 255 ) {
            
            deviceState.currentTbarPosition = control.currentValue;
            [deviceView invalidateTbar];
        }
        
        return YES;
    }];
    
#elif 1 // Uses one callback for each control
    
    for ( id<XkeysBlueRedButton> button in self.xkeys124Device.buttons ) {
        
        [button onValueChangePerform:^BOOL(id<XkeysControl> control) {
            
            id<XkeysBlueRedButton> button = (id<XkeysBlueRedButton>)control;
            
            XKE124TBarViewController *viewController = weakSelf;
            XKE124TBarState *deviceState = viewController.xkeys124State;
            XKE124TBarView *deviceView = viewController.xkeys124View;
            
            NSInteger buttonNumber = button.buttonNumber;
            
            if ( button.currentValue ) {
                [deviceState pressButtonNumber:buttonNumber];
            }
            else {
                [deviceState releaseButtonNumber:buttonNumber];
            }
            
            [deviceView invalidateButtonNumber:buttonNumber];
            
            return YES;
        }];
    }
    
    [self.xkeys124Device.tbar onValueChangePerform:^BOOL(id<XkeysControl> control) {
        
        XKE124TBarViewController *viewController = weakSelf;
        XKE124TBarState *deviceState = viewController.xkeys124State;
        XKE124TBarView *deviceView = viewController.xkeys124View;
        
        deviceState.currentTbarPosition = control.currentValue;
        [deviceView invalidateTbar];
        
        return YES;
    }];

#endif
}

- (id<Xkeys124Tbar>)xkeys124Device {
    
    NSAssert([self.xkeysDevice conformsToProtocol:@protocol(Xkeys124Tbar)], @"");
    if ( ! [self.xkeysDevice conformsToProtocol:@protocol(Xkeys124Tbar)] ) {
        return nil;
    }
    
    return (id<Xkeys124Tbar>)self.xkeysDevice;
}

- (XKE124TBarState *)xkeys124State {
    
    NSAssert([self.xkeysState isKindOfClass:[XKE124TBarState class]], @"");
    if ( ! [self.xkeysState isKindOfClass:[XKE124TBarState class]] ) {
        return nil;
    }
    
    return (XKE124TBarState *)self.xkeysState;
}

- (XKE124TBarView *)xkeys124View {
    
    NSAssert([self.xkeysView isKindOfClass:[XKE124TBarView class]], @"");
    if ( ! [self.xkeysView isKindOfClass:[XKE124TBarView class]] ) {
        return nil;
    }
    
    return (XKE124TBarView *)self.xkeysView;
}

@end
