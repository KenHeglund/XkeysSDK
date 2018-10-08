//
//  XK24ViewController.m
//  XkeysViewer
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import XkeysKit;

#import "XK24State.h"
#import "XK24View.h"

#import "XK24ViewController.h"

static NSString * const Xkeys24VC_keyPath_greenLEDStateTag = @"greenLEDStateTag";
static NSString * const Xkeys24VC_keyPath_redLEDStateTag = @"redLEDStateTag";
static void * Xkeys24VC_KVOContext = @"Xkeys24VC_KVOContext";

// MARK: -

@interface XK24ViewController ()

@property (nonatomic) NSInteger greenLEDStateTag;
@property (nonatomic) NSInteger redLEDStateTag;

@property (nonatomic) BOOL kvoRegistered;

@end

// MARK: -

@implementation XK24ViewController

- (instancetype)initWithXkeysDevice:(id<XkeysDevice>)xkeysDevice {
    
    self = [super initWithNibName:@"XK24View" bundle:nil xkeysDevice:xkeysDevice];
    if ( ! self ) {
        return nil;
    }
    
    _greenLEDStateTag = self.xkeys24Device.greenLED.state;
    _redLEDStateTag = self.xkeys24Device.redLED.state;
    
    [self addObserver:self forKeyPath:Xkeys24VC_keyPath_greenLEDStateTag options:0 context:Xkeys24VC_KVOContext];
    [self addObserver:self forKeyPath:Xkeys24VC_keyPath_redLEDStateTag options:0 context:Xkeys24VC_KVOContext];
    _kvoRegistered = YES;
    
    return self;
}

- (void)dealloc {
    
    if ( _kvoRegistered ) {
        [self removeObserver:self forKeyPath:Xkeys24VC_keyPath_greenLEDStateTag context:Xkeys24VC_KVOContext];
        [self removeObserver:self forKeyPath:Xkeys24VC_keyPath_redLEDStateTag context:Xkeys24VC_KVOContext];
    }
}

// MARK: - NSKeyValueObserving implementation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ( context != Xkeys24VC_KVOContext ) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if ( [keyPath isEqualToString:Xkeys24VC_keyPath_greenLEDStateTag] ) {
        
        if ( self.xkeys24Device.greenLED.state == self.greenLEDStateTag ) {
            return;
        }
        
        self.xkeys24Device.greenLED.state = self.greenLEDStateTag;
        self.xkeysState.greenLED = self.greenLEDStateTag;
        [self.xkeysView invalidateLEDs];
    }
    else if ( [keyPath isEqualToString:Xkeys24VC_keyPath_redLEDStateTag] ) {
        
        if ( self.xkeys24Device.redLED.state == self.redLEDStateTag ) {
            return;
        }
        
        self.xkeys24Device.redLED.state = self.redLEDStateTag;
        self.xkeysState.redLED = self.redLEDStateTag;
        [self.xkeysView invalidateLEDs];
    }
}

// MARK: - XK24ViewController implementation

- (XkeysState *)createDeviceState {
    return [[XK24State alloc] init];
}

- (void)initializeDeviceState {
    
    [super initializeDeviceState];
    
    XkeysState *deviceState = self.xkeysState;
    
    deviceState.greenLED = self.xkeys24Device.greenLED.state;
    deviceState.redLED = self.xkeys24Device.redLED.state;
    
    __weak XK24ViewController *weakSelf = self;
    
    deviceState.onGreenLEDChange = ^(XkeysLEDState state){
        
        XK24ViewController *viewController = weakSelf;
        
        if ( viewController.xkeys24Device.greenLED.state == state ) {
            return;
        }
        
        viewController.xkeys24Device.greenLED.state = state;
        viewController.greenLEDStateTag = state;
    };
    
    deviceState.onRedLEDChange = ^(XkeysLEDState state){
        
        XK24ViewController *viewController = weakSelf;
        
        if ( viewController.xkeys24Device.redLED.state == state ) {
            return;
        }
        
        viewController.xkeys24Device.redLED.state = state;
        viewController.redLEDStateTag = state;
    };
}

- (void)initializeDeviceCallbacks {
    
    // This contains a few alternatives on how control callbacks can be configured.
    
    __weak XK24ViewController *weakSelf = self;
    
#if 1 // Uses single callback for all buttons
    
    [self.xkeys24Device onAnyButtonValueChangePerform:^BOOL(id<XkeysBlueRedButton> button) {
        
        XK24ViewController *viewController = weakSelf;
        XK24State *deviceState = viewController.xkeys24State;
        XK24View *deviceView = viewController.xkeys24View;
        
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
    
    [self.xkeys24Device onProgramSwitchChangePerform:^BOOL(id<XkeysControl> control) {
        
        XK24ViewController *viewController = weakSelf;
        XK24State *deviceState = viewController.xkeys24State;
        XK24View *deviceView = viewController.xkeys24View;
        
        deviceState.programmingSwitch = (control.currentValue != 0);
        
        [deviceView invalidateProgrammingSwitch];
        
        return YES;
    }];
    
#elif 1 // Uses one callback for all controls
    
    [self.xkeys24Device onAnyControlValueChangePerform:^BOOL(id<XkeysControl> control) {
        
        XK24ViewController *viewController = weakSelf;
        XK24State *deviceState = viewController.xkeys24State;
        XK24View *deviceView = viewController.xkeys24View;
        id<Xkeys24> xkeys24Device = viewController.xkeys24Device;
        
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
        else if ( control == xkeys24Device.programSwitch ) {
            
            deviceState.programmingSwitch = (control.currentValue != 0);
            
            [deviceView invalidateProgrammingSwitch];
        }
        
        return YES;
    }];
    
#elif 1 // Uses one callback for each control
    
    for ( id<XkeysBlueRedButton> button in self.xkeys24Device.buttons ) {
        
        [button onValueChangePerform:^BOOL(id<XkeysControl> control) {
            
            id<XkeysBlueRedButton> button = (id<XkeysBlueRedButton>)control;
            
            XK24ViewController *viewController = weakSelf;
            XK24State *deviceState = viewController.xkeys24State;
            XK24View *deviceView = viewController.xkeys24View;
            
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
    
    [self.xkeys24Device.programSwitch onValueChangePerform:^BOOL(id<XkeysControl> control) {
        
        XK24ViewController *viewController = weakSelf;
        XK24State *deviceState = viewController.xkeys24State;
        XK24View *deviceView = viewController.xkeys24View;
        
        deviceState.programmingSwitch = (control.currentValue != 0);
        
        [deviceView invalidateProgrammingSwitch];
        
        return YES;
    }];

#endif
}

- (id<Xkeys24>)xkeys24Device {
    
    NSAssert([self.xkeysDevice conformsToProtocol:@protocol(Xkeys24)], @"");
    if ( ! [self.xkeysDevice conformsToProtocol:@protocol(Xkeys24)] ) {
        return nil;
    }
    
    return (id<Xkeys24>)self.xkeysDevice;
}

- (XK24State *)xkeys24State {
    
    NSAssert([self.xkeysState isKindOfClass:[XK24State class]], @"");
    if ( ! [self.xkeysState isKindOfClass:[XK24State class]] ) {
        return nil;
    }
    
    return (XK24State *)self.xkeysState;
}

- (XK24View *)xkeys24View {
    
    NSAssert([self.xkeysView isKindOfClass:[XK24View class]], @"");
    if ( ! [self.xkeysView isKindOfClass:[XK24View class]] ) {
        return nil;
    }
    
    return (XK24View *)self.xkeysView;
}

@end

// MARK: - XK24HWModeViewController implementation

@implementation XK24HWModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.unitIDTextField.enabled = NO;
    self.unitIDTextField.stringValue = @"";
}

@end

