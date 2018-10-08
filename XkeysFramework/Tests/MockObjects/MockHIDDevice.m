//
//  MockHIDDevice.m
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import IOKit.hid;

#import "MockHIDOutputReport.h"
#import "MockHIDValue.h"

#import "MockHIDDevice.h"

@interface MockHIDDevice ()

@property (nonatomic, readwrite) NSInteger vendorID;

@property (nonatomic, readwrite) uint8_t *inputReportBuffer;
@property (nonatomic, readwrite) CFIndex inputReportBufferLength;
@property (nonatomic, readwrite) IOHIDReportCallback inputReportCallback;
@property (nonatomic, readwrite) void *inputReportContext;

@property (nonatomic, readwrite) NSMutableArray *outputReports;

@property (nonatomic, readwrite) NSArray<NSDictionary *> *inputValueMatchingCriteria;
@property (nonatomic, readwrite) IOHIDValueCallback inputValueCallback;
@property (nonatomic, readwrite) void *inputValueCallbackContext;

@property (nonatomic, readwrite) IOHIDCallback removalCallback;
@property (nonatomic, readwrite) void *removalCallbackContext;

@property (nonatomic, readwrite) CFRunLoopRef scheduledRunLoop;
@property (nonatomic, readwrite) CFRunLoopMode scheduledRunLoopMode;

@end

@implementation MockHIDDevice

- (instancetype)initWithVendorID:(NSInteger)vendorID productID:(NSInteger)productID {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _outputReports = [[NSMutableArray alloc] init];
    _vendorID = vendorID;
    _productID = productID;
    
    return self;
}

// MARK: - Mock system functions

- (BOOL)conformsToUsagePage:(uint32_t)usagePage usage:(uint32_t)usage {
    return ( self.deviceUsagePage == usagePage && self.deviceUsage == usage );
}

- (void)registerInputReport:(uint8_t *)report length:(CFIndex)reportLength callback:(IOHIDReportCallback)callback context:(void *)context {
    
    self.inputReportBuffer = report;
    self.inputReportBufferLength = reportLength;
    self.inputReportCallback = callback;
    self.inputReportContext = context;
}

- (IOReturn)setReport:(const uint8_t *)report length:(CFIndex)reportLength reportID:(CFIndex)reportID type:(IOHIDReportType)reportType {
    
    NSAssert(report != NULL, @"");
    if ( report == NULL ) {
        // The actual HIDManager throws with a NULL report pointer
        return kIOReturnError;
    }
    
    [self.outputReports addObject:[[MockHIDOutputReport alloc] initWithBuffer:report length:reportLength reportID:reportID type:reportType]];
    
    return kIOReturnSuccess;
}

- (void)registerRemovalCallback:(IOHIDCallback)callback context:(void *)context {
    self.removalCallback = callback;
    self.removalCallbackContext = context;
}

- (void)registerInputValueCallback:(IOHIDValueCallback)callback context:(void *)context {
    self.inputValueCallback = callback;
    self.inputValueCallbackContext = context;
}

- (void)setInputValueMatchingMultiple:(CFArrayRef)multiple {
    self.inputValueMatchingCriteria = (__bridge NSArray *)multiple;
}

- (void)scheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFStringRef)runLoopMode {
    self.scheduledRunLoop = runLoop;
    self.scheduledRunLoopMode = runLoopMode;
}

- (void)unscheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)runLoopMode {
    if ( runLoop == self.scheduledRunLoop && runLoopMode == self.scheduledRunLoopMode ) {
        self.scheduledRunLoop = NULL;
        self.scheduledRunLoopMode = NULL;
    }
}

// MARK: - MockHIDDevice implementation

- (void)postInputReportOfLength:(CFIndex)reportLength withType:(IOHIDReportType)reportType reportID:(uint32_t)reportID {
    
    if ( self.inputReportCallback == NULL ) {
        return;
    }
    if ( self.inputReportBufferLength < reportLength ) {
        return;
    }
    
    void *context = self.inputReportContext;
    IOReturn result = kIOReturnSuccess;
    void *sender = (__bridge void *)self;
    uint8_t *report = self.inputReportBuffer;
    
    self.inputReportCallback(context, result, sender, reportType, reportID, report, reportLength);
}

- (void)postInputValue:(MockHIDValue *)mockValue {
    
    if ( self.inputValueCallback == NULL ) {
        return;
    }
    
    void *context = self.inputValueCallbackContext;
    IOReturn result = kIOReturnSuccess;
    void *sender = (__bridge void *)self;
    IOHIDValueRef value = (__bridge IOHIDValueRef)mockValue;
    
    self.inputValueCallback(context, result, sender, value);
}

- (void)invokeRemovalCallback {
    
    if ( self.removalCallback == NULL ) {
        return;
    }
    
    void *context = self.removalCallbackContext;
    IOReturn result = kIOReturnSuccess;
    void *sender = (__bridge void *)self;
    
    self.removalCallback(context, result, sender);
}

@end
