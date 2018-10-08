//
//  XkeysRootViewController.m
//  XkeysViewer
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import XkeysKit;

#import "XkeysDeviceViewController.h"
#import "XkeysServerController.h"
#import "XKE124TBarViewController.h"

#import "XkeysRootViewController.h"

static NSString * const XkeysViewController_defaults_leftButtonIdentifier = @"XkeysViewerLeftButton";
static NSString * const XkeysViewController_defaults_centerButtonIdentifier = @"XkeysViewerCenterButton";
static NSString * const XkeysViewController_defaults_rightButtonIdentifier = @"XkeysViewerRightButton";

static NSString * const XkeysViewController_keyPath_selectedDeviceIndexes = @"selectedDeviceIndexes";
void * XkeysViewController_KVOContext = @"XkeysViewController_KVOContext";

@interface XkeysRootViewController ()

@property (nonatomic) XkeysServerController *xkeysController;
@property (nonatomic) NSViewController *currentViewController;
@property (nonatomic) NSViewController *defaultViewController;

@property (nonatomic) IBOutlet NSPopUpButton *devicePopUpButton;
@property (nonatomic) IBOutlet NSView *deviceParentView;

@property (nonatomic) IBOutlet NSButton *leftButton;
@property (nonatomic) IBOutlet NSButton *centerButton;
@property (nonatomic) IBOutlet NSButton *rightButton;

@property (nonatomic) IBOutlet NSBox *leftBox;
@property (nonatomic) IBOutlet NSBox *centerBox;
@property (nonatomic) IBOutlet NSBox *rightBox;

@property (nonatomic) NSIndexSet *selectedDeviceIndexes;

@property (nonatomic) BOOL kvoRegistered;

@end

// MARK: -

@implementation XkeysRootViewController

- (void)dealloc {
    
    if ( _kvoRegistered ) {
        [self removeObserver:self forKeyPath:XkeysViewController_keyPath_selectedDeviceIndexes context:XkeysViewController_KVOContext];
    }
}

// MARK: - NSKeyValueObserving implementation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ( context != XkeysViewController_KVOContext ) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if ( [keyPath isEqualToString:XkeysViewController_keyPath_selectedDeviceIndexes] ) {
        
        if ( self.selectedDeviceIndexes.count == 0 ) {
            
            // There are no selected indexes in the popup menu, take that to mean that there are no devices attached.  Update the popup's title on the next pass through the run loop.  This deferral allows the UI to first update the contents of the popup before the custom placeholder title is applied.
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updatePopUpPlaceholderTitle];
            });
        }
        
        [self updateDeviceViewController];
    }
}

// MARK: - NSViewController overrides

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.selectedDeviceIndexes = [NSIndexSet indexSet];
    self.xkeysController = [[XkeysServerController alloc] init];
    
    [self addObserver:self forKeyPath:XkeysViewController_keyPath_selectedDeviceIndexes options:0 context:XkeysViewController_KVOContext];
    self.kvoRegistered = YES;
    
    [self setupDefaultControls];
    [self updatePopUpPlaceholderTitle];
}

- (void)viewDidAppear {
    
    [super viewDidAppear];
    
    self.defaultViewController = self.childViewControllers.firstObject;
    self.currentViewController = self.defaultViewController;
}

// MARK: - Device-specific child view controller

- (void)updatePopUpPlaceholderTitle {
    
    if ( self.xkeysController.devices.count == 0 ) {
        [self.devicePopUpButton setTitle:@"No Xkeys Devices Attached"];
    }
}

- (void)updateDeviceViewController {
    
    NSUInteger deviceIndex = self.selectedDeviceIndexes.firstIndex;
    if ( deviceIndex == NSNotFound ) {
        return [self showDefaultViewController];
    }
    
    id<XkeysDevice> newDevice = self.xkeysController.devices[deviceIndex];
    if ( newDevice == nil ) {
        return [self showDefaultViewController];
    }
    
    XkeysDeviceViewController *previousViewController = (XkeysDeviceViewController *)self.currentViewController;
    if ( [previousViewController isKindOfClass:[XkeysDeviceViewController class]] ) {
        
        if ( previousViewController.xkeysDevice == newDevice ) {
            return;
        }
    }
    
    NSViewController *newViewController = [XkeysDeviceViewController viewControllerForXkeysDevice:newDevice];
    if ( newViewController == nil ) {
        return [self showDefaultViewController];
    }
    
    [self addChildViewController:newViewController];
    self.currentViewController = newViewController;
    
    [self transitionFromViewController:previousViewController toViewController:newViewController options:NSViewControllerTransitionCrossfade completionHandler:^{
        [previousViewController removeFromParentViewController];
    }];
}

- (void)showDefaultViewController {
    
    if ( self.currentViewController == self.defaultViewController ) {
        return;
    }
    
    [self addChildViewController:self.defaultViewController];
    
    NSViewController *previousViewController = self.currentViewController;
    self.currentViewController = self.defaultViewController;

    [self transitionFromViewController:previousViewController toViewController:self.defaultViewController options:NSViewControllerTransitionCrossfade completionHandler:^{
        [previousViewController removeFromParentViewController];
    }];
}

// MARK: - Preferences

- (IBAction)doSelectButton:(id)sender {
    
    NSButton *clickedButton = (NSButton *)sender;
    
    NSBox *box = nil;
    NSString *defaultKey = nil;
    
    self.leftButton.enabled = NO;
    self.centerButton.enabled = NO;
    self.rightButton.enabled = NO;
    
    clickedButton.enabled = YES;
    clickedButton.title = @"Cancel";
    clickedButton.action = @selector(doCancelButtonSelection:);
    
    if ( clickedButton == self.leftButton ) {
        box = self.leftBox;
        defaultKey = XkeysViewController_defaults_leftButtonIdentifier;
    }
    else if ( clickedButton == self.centerButton ) {
        box = self.centerBox;
        defaultKey = XkeysViewController_defaults_centerButtonIdentifier;
    }
    else if ( clickedButton == self.rightButton ) {
        box = self.rightBox;
        defaultKey = XkeysViewController_defaults_rightButtonIdentifier;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentControlPreference = [userDefaults stringForKey:defaultKey];
    if ( currentControlPreference ) {
        
        NSArray<NSString *> *components = [currentControlPreference componentsSeparatedByString:@" <=> "];
        NSAssert(components.count == 2, @"Failed to parse preference: %@", currentControlPreference);
        NSString *currentIdentifier = components.lastObject;
        
        [[XkeysServer shared] onControlValueChange:currentIdentifier perform:NULL];
        
        [userDefaults removeObjectForKey:defaultKey];
    }
    
    NSTextField *textField = [box viewWithTag:1];
    NSAssert([textField isKindOfClass:[NSTextField class]], @"");
    textField.stringValue = @"Press an Xkeys button…";
    
    __weak XkeysRootViewController *weakSelf = self;
    
    [[XkeysServer shared] onAnyControlValueChangePerform:^BOOL(id<XkeysControl> control) {
        
        if ( control.minimumValue != 0 || control.maximumValue != 1 ) {
            return YES;
        }
        
        XkeysRootViewController *viewController = weakSelf;
        
        viewController.leftButton.enabled = YES;
        viewController.centerButton.enabled = YES;
        viewController.rightButton.enabled = YES;
        
        clickedButton.title = @"Set";
        clickedButton.action = @selector(doSelectButton:);

        NSString *format = @"%@ : %@";
        NSString *description = [NSString stringWithFormat:format, control.device.name, control.name];
        NSString *controlPreference = [@[description, control.identifier] componentsJoinedByString:@" <=> "];
        
        [viewController removeExistingPreference:controlPreference];
        [[NSUserDefaults standardUserDefaults] setObject:controlPreference forKey:defaultKey];
        [viewController assignControlPreference:controlPreference toBox:box];
        
        return NO;
    }];
}

- (IBAction)doCancelButtonSelection:(id)sender {
    
    NSButton *clickedButton = (NSButton *)sender;
    
    self.leftButton.enabled = YES;
    self.centerButton.enabled = YES;
    self.rightButton.enabled = YES;
    
    clickedButton.title = @"Set";
    clickedButton.action = @selector(doSelectButton:);
    
    NSTextField *textField = [clickedButton.superview viewWithTag:1];
    NSAssert([textField isKindOfClass:[NSTextField class]], @"");
    textField.stringValue = @"Unassigned";
    
    [[XkeysServer shared] onAnyControlValueChangePerform:NULL];
}

- (void)assignControlPreference:(NSString *)controlPreference toBox:(NSBox *)box {
    
    NSTextField *textField = [box viewWithTag:1];
    NSAssert([textField isKindOfClass:[NSTextField class]], @"");
    
    if ( controlPreference == nil ) {
        textField.stringValue = @"Unassigned";
        return;
    }
    
    NSArray<NSString *> *components = [controlPreference componentsSeparatedByString:@" <=> "];
    NSAssert(components.count == 2, @"Failed to parse preference: %@", controlPreference);
    NSString *description = components.firstObject;
    NSString *identifier = components.lastObject;
    
    textField.stringValue = description;
    
    [[XkeysServer shared] onControlValueChange:identifier perform:^BOOL(id<XkeysControl> control) {
        
        if ( control.currentValue ) {
            box.fillColor = [NSColor colorWithDeviceWhite:0.75 alpha:1.0];
        }
        else {
            box.fillColor = [NSColor clearColor];
        }
        
        return YES;
    }];
}

- (void)setupDefaultControls {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *controlPreference = nil;
    
    controlPreference = [userDefaults stringForKey:XkeysViewController_defaults_leftButtonIdentifier];
    [self assignControlPreference:controlPreference toBox:self.leftBox];
    
    controlPreference = [userDefaults stringForKey:XkeysViewController_defaults_centerButtonIdentifier];
    [self assignControlPreference:controlPreference toBox:self.centerBox];
    
    controlPreference = [userDefaults stringForKey:XkeysViewController_defaults_rightButtonIdentifier];
    [self assignControlPreference:controlPreference toBox:self.rightBox];
}

- (void)removeExistingPreference:(NSString *)controlPreference {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ( [controlPreference isEqualToString:[userDefaults stringForKey:XkeysViewController_defaults_leftButtonIdentifier]] ) {
        [userDefaults removeObjectForKey:XkeysViewController_defaults_leftButtonIdentifier];
        [self assignControlPreference:nil toBox:self.leftBox];
    }
    
    if ( [controlPreference isEqualToString:[userDefaults stringForKey:XkeysViewController_defaults_centerButtonIdentifier]] ) {
        [userDefaults removeObjectForKey:XkeysViewController_defaults_centerButtonIdentifier];
        [self assignControlPreference:nil toBox:self.centerBox];
    }
    
    if ( [controlPreference isEqualToString:[userDefaults stringForKey:XkeysViewController_defaults_rightButtonIdentifier]] ) {
        [userDefaults removeObjectForKey:XkeysViewController_defaults_rightButtonIdentifier];
        [self assignControlPreference:nil toBox:self.rightBox];
    }
}

@end
