//
//  XkeysDeviceViewController.m
//  XkeysViewer
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import XkeysKit;

#import "XkeysState.h"
#import "XkeysDeviceView.h"

#import "XK24ViewController.h"
#import "XKE124TBarViewController.h"
#import "XKE124TBarHWModeViewController.h"

#import "XkeysDeviceViewController.h"

static NSString * const XkeysDeviceVC_keyPath_productIDTag = @"productIDTag";
static NSString * const XkeysDeviceVC_keyPath_blueBacklightIntensity = @"blueBacklightIntensity";
static NSString * const XkeysDeviceVC_keyPath_redBacklightIntensity = @"redBacklightIntensity";
static void * XkeysDeviceVC_KVOContext = @"XkeysDeviceVC_KVOContext";

// MARK: -

@interface XkeysDeviceViewController ()

@property (nonatomic) NSInteger productIDTag;
@property (nonatomic) CGFloat blueBacklightIntensity;
@property (nonatomic) CGFloat redBacklightIntensity;

@property (nonatomic, readwrite) IBOutlet NSTextField *unitIDTextField;
@property (nonatomic, readwrite) IBOutlet NSTextField *unitIDRangeLabel;
@property (nonatomic, readwrite) IBOutlet NSButton *setUnitIDButton;

@property (nonatomic) NSNumberFormatter *unitIDFormatter;
@property (nonatomic) BOOL kvoRegistered;

@end

// MARK: -

@implementation XkeysDeviceViewController

+ (NSViewController *)viewControllerForXkeysDevice:(id<XkeysDevice>)xkeysDevice {
    
    XkeysDeviceViewController *viewController = nil;
    
    if ( NO ) {}
    else if ( xkeysDevice.model == XkeysModelXK24 ) {
        viewController = [[XK24ViewController alloc] initWithXkeysDevice:xkeysDevice];
    }
    else if ( xkeysDevice.model == XkeysModelXK24HWMode ) {
        viewController = [[XK24HWModeViewController alloc] initWithXkeysDevice:xkeysDevice];
    }
    else if ( xkeysDevice.model == XkeysModelXKE124Tbar ) {
        viewController = [[XKE124TBarViewController alloc] initWithXkeysDevice:xkeysDevice];
    }
    else if ( xkeysDevice.model == XkeysModelXKE124TbarHWMode ) {
        viewController = [[XKE124TBarHWModeViewController alloc] initWithXkeysDevice:xkeysDevice];
    }
    else {
        // Extend for additional supported devices...
    }
    
    return viewController;
}

- (instancetype)initWithNibName:(NSNibName _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil xkeysDevice:(id<XkeysDevice>)xkeysDevice {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( ! self ) {
        return nil;
    }
    
    _xkeysDevice = xkeysDevice;
    
    XkeysState *deviceState = [self createDeviceState];
    _xkeysState = deviceState;
    
    _productIDTag = xkeysDevice.productID;
    _blueBacklightIntensity = xkeysDevice.defaultBlueBacklightIntensity;
    _redBacklightIntensity = xkeysDevice.defaultRedBacklightIntensity;
    
    _unitIDFormatter = [[NSNumberFormatter alloc] init];
    
    [self addObserver:self forKeyPath:XkeysDeviceVC_keyPath_productIDTag options:0 context:XkeysDeviceVC_KVOContext];
    [self addObserver:self forKeyPath:XkeysDeviceVC_keyPath_blueBacklightIntensity options:0 context:XkeysDeviceVC_KVOContext];
    [self addObserver:self forKeyPath:XkeysDeviceVC_keyPath_redBacklightIntensity options:0 context:XkeysDeviceVC_KVOContext];
    _kvoRegistered = YES;
    
    return self;
}

- (void)dealloc {
    
    if ( _kvoRegistered ) {
        [self removeObserver:self forKeyPath:XkeysDeviceVC_keyPath_productIDTag context:XkeysDeviceVC_KVOContext];
        [self removeObserver:self forKeyPath:XkeysDeviceVC_keyPath_blueBacklightIntensity context:XkeysDeviceVC_KVOContext];
        [self removeObserver:self forKeyPath:XkeysDeviceVC_keyPath_redBacklightIntensity context:XkeysDeviceVC_KVOContext];
    }
}

// MARK: - NSViewController overrides

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.xkeysView.deviceState = self.xkeysState;

    self.unitIDRangeLabel.hidden = YES;
    self.setUnitIDButton.enabled = NO;
    self.unitIDTextField.integerValue = self.xkeysDevice.unitID;

    [self initializeDeviceState];
    [self initializeDeviceCallbacks];
}

// MARK: - NSKeyValueObserving implementation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ( context != XkeysDeviceVC_KVOContext ) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if ( [keyPath isEqualToString:XkeysDeviceVC_keyPath_productIDTag] ) {
        
        self.xkeysDevice.productID = self.productIDTag;
    }
    else if ( [keyPath isEqualToString:XkeysDeviceVC_keyPath_blueBacklightIntensity] ) {
        
        [self.xkeysDevice setCalibratedIntensityOfBacklightsToBlue:self.blueBacklightIntensity red:self.redBacklightIntensity];
    }
    else if ( [keyPath isEqualToString:XkeysDeviceVC_keyPath_redBacklightIntensity] ) {
        
        [self.xkeysDevice setCalibratedIntensityOfBacklightsToBlue:self.blueBacklightIntensity red:self.redBacklightIntensity];
    }
    
}

// MARK: - NSControl delegate notifications

- (void)controlTextDidChange:(NSNotification *)obj {
    
    NSInteger unitID = [self unitIDFromUserInput];
    
    if ( unitID == NSNotFound ) {
        
        self.unitIDRangeLabel.hidden = NO;
        self.setUnitIDButton.enabled = NO;
    }
    else {
        
        self.unitIDRangeLabel.hidden = YES;
        self.setUnitIDButton.enabled = (unitID != self.xkeysDevice.unitID);
    }
}

// MARK: - IBAction implementation

- (IBAction)doSetUnitID:(id)sender {
    
    NSInteger unitID = [self unitIDFromUserInput];
    if ( unitID == NSNotFound ) {
        return;
    }
    if ( unitID == self.xkeysDevice.unitID ) {
        return;
    }
    
    self.xkeysDevice.unitID = (uint8_t)unitID;
    [self.unitIDTextField selectText:nil];
    self.setUnitIDButton.enabled = NO;
}

- (IBAction)doAllBlueBacklightsOn:(id)sender {
    [self.xkeysDevice setAllBacklightsWithColor:XkeysLEDColorBlue toState:XkeysLEDStateOn];
    [self.xkeysState setBlueBacklightOfAllButtonsOn:YES];
    self.xkeysView.needsDisplay = YES;
}

- (IBAction)doAllBlueBacklightsOff:(id)sender {
    [self.xkeysDevice setAllBacklightsWithColor:XkeysLEDColorBlue toState:XkeysLEDStateOff];
    [self.xkeysState setBlueBacklightOfAllButtonsOn:NO];
    self.xkeysView.needsDisplay = YES;
}

- (IBAction)doAllRedBacklightsOn:(id)sender {
    [self.xkeysDevice setAllBacklightsWithColor:XkeysLEDColorRed toState:XkeysLEDStateOn];
    [self.xkeysState setRedBacklightOfAllButtonsOn:YES];
    self.xkeysView.needsDisplay = YES;
}

- (IBAction)doAllRedBacklightsOff:(id)sender {
    [self.xkeysDevice setAllBacklightsWithColor:XkeysLEDColorRed toState:XkeysLEDStateOff];
    [self.xkeysState setRedBacklightOfAllButtonsOn:NO];
    self.xkeysView.needsDisplay = YES;
}

- (IBAction)doRestoreDefaultBacklightSettings:(id)sender {
    [self doAllBlueBacklightsOff:sender];
    [self doAllRedBacklightsOn:sender];
    self.blueBacklightIntensity = self.xkeysDevice.defaultBlueBacklightIntensity;
    self.redBacklightIntensity = self.xkeysDevice.defaultRedBacklightIntensity;
}

- (IBAction)doSaveBacklightSettingsToMemory:(id)sender {
    [self.xkeysDevice writeBacklightStateToEEPROM];
}

// MARK: - XkeysDeviceViewController implementation

- (XkeysState *)createDeviceState {
    return [[XkeysState alloc] initWithButtonCount:1];
}

- (void)initializeDeviceState {
    
    __weak XkeysDeviceViewController *weakSelf = self;
    
    self.xkeysState.onBlueBacklightChange = ^(NSInteger buttonNumber, BOOL backlightState){
        XkeysDeviceViewController *viewController = weakSelf;
        id<XkeysBlueRedButton> button = (id<XkeysBlueRedButton>)[viewController.xkeysDevice buttonWithButtonNumber:buttonNumber];
        NSCAssert([button conformsToProtocol:@protocol(XkeysBlueRedButton)], @"%@", button);
        button.blueLED.state = (backlightState ? XkeysLEDStateOn : XkeysLEDStateOff);
    };
    
    self.xkeysState.onRedBacklightChange = ^(NSInteger buttonNumber, BOOL backlightState){
        XkeysDeviceViewController *viewController = weakSelf;
        id<XkeysBlueRedButton> button = (id<XkeysBlueRedButton>)[viewController.xkeysDevice buttonWithButtonNumber:buttonNumber];
        NSCAssert([button conformsToProtocol:@protocol(XkeysBlueRedButton)], @"%@", button);
        button.redLED.state = (backlightState ? XkeysLEDStateOn : XkeysLEDStateOff);
    };
}

- (void)initializeDeviceCallbacks {
    // Subclasses should override
}

// MARK: - XkeysDeviceViewController internal

- (NSInteger)unitIDFromUserInput {
    
    // Return the NSNotFound token if the current user input is an invalid Unit ID
    
    NSString *stringValue = self.unitIDTextField.stringValue;
    if ( stringValue.length == 0 ) {
        return self.xkeysDevice.unitID;
    }
    
    NSNumber *unitIDObject = [self.unitIDFormatter numberFromString:self.unitIDTextField.stringValue];
    
    if ( unitIDObject == nil ) {
        return NSNotFound;
    }
    
    NSInteger unitIDValue = unitIDObject.integerValue;
    
    if ( unitIDValue < 0 || unitIDValue > 255 ) {
        return NSNotFound;
    }
    
    return unitIDValue;
}

@end
