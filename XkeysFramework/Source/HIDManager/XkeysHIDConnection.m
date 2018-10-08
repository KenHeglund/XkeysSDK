//
//  XkeysHIDConnection.m
//  XkeysFramework
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

@import IOKit.hid;

#import "XkeysHIDSystem.h"

#import "XkeysHIDConnection.h"

@interface XkeysHIDConnection ()

@property (nonatomic) id<XkeysHIDSystem> hidSystem;
@property (nonatomic) IOHIDDeviceRef hidDevice;
@property (nonatomic) CFIndex reportID;

@end

// MARK: -

@implementation XkeysHIDConnection

- (instancetype)initWithHIDSystem:(id<XkeysHIDSystem>)hidSystem device:(IOHIDDeviceRef)hidDevice reportID:(CFIndex)reportID {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _hidSystem = hidSystem;
    _hidDevice = hidDevice;
    _reportID = reportID;
    
    return self;
}

// MARK: - XkeysConnection implementation

- (BOOL)receivesData {
    return YES;
}

- (void)open {
    // HID connections don't need to be opened/closed
}

- (void)close {
    // HID connections don't need to be opened/closed
}

- (void)sendReportBytes:(uint8_t *)reportBuffer ofLength:(size_t)bufferLength {
    
    [self.hidSystem device:self.hidDevice setReport:reportBuffer length:bufferLength reportID:self.reportID type:kIOHIDReportTypeOutput];
}

@end
