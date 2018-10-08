//
//  XkeysUSBConnection.m
//  XkeysFramework
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

@import IOKit.hid;
@import IOKit.usb.IOUSBLib;

#import "XkeysUSBConnection.h"

@interface XkeysUSBConnection ()

@property (nonatomic) IOUSBInterfaceInterface **interface;
@property (nonatomic, readwrite, getter = isOpen) BOOL open;

@end

// MARK: -

@implementation XkeysUSBConnection

- (instancetype)initWithHIDDevice:(IOHIDDeviceRef)hidDevice interfaceNumber:(NSInteger)interfaceNumber {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    io_service_t interfaceService = [XkeysUSBConnection copyInterfaceServiceForDevice:hidDevice interfaceNumber:interfaceNumber];
    if ( interfaceService == 0 ) {
        return nil;
    }
    
    _interface = [XkeysUSBConnection createInterfaceWithService:interfaceService];
    
    IOObjectRelease(interfaceService);
    
    if ( _interface == NULL ) {
        return nil;
    }
    
    return self;
}

- (void)dealloc {
    
    [self close];
    
    if ( _interface ) {
        (*_interface)->Release( _interface );
    }
}

// MARK: - XkeysConnection implementation

- (BOOL)receivesData {
    return NO;
}

- (void)open {
    
    if ( self.isOpen ) {
        return;
    }
    
    NSAssert(self.interface != NULL, @"");
    if ( self.interface == NULL ) {
        return;
    }
    
    IOReturn result = (*self.interface)->USBInterfaceOpen( self.interface );
    
    NSAssert(result == kIOReturnSuccess, @"0x%08X", result);
    if ( result != kIOReturnSuccess ) {
        return;
    }
    
    self.open = YES;
}

- (void)close {
    
    if ( ! self.open ) {
        return;
    }
    
    self.open = NO;
    
    NSAssert(self.interface != NULL, @"");
    if ( self.interface == NULL ) {
        return;
    }
    
    IOReturn result = (*self.interface)->USBInterfaceClose( self.interface );
    
    if ( result == kIOReturnNoDevice ) {
        return;
    }
    
    NSAssert(result == kIOReturnSuccess, @"0x%08X", result);
}

- (void)sendReportBytes:(uint8_t *)reportBuffer ofLength:(size_t)bufferLength {
    
    NSAssert(self.interface != NULL, @"");
    if ( self.interface == NULL ) {
        return;
    }
    
    UInt8 pipeRef = 1;
    IOReturn writeResult __unused = (*self.interface)->WritePipe( self.interface, pipeRef, reportBuffer, (UInt32)bufferLength );
    NSAssert(writeResult == kIOReturnSuccess, @"0x%08X", writeResult);
}

// MARK: - XkeysUSBConnection internal

+ (io_service_t)copyInterfaceServiceForDevice:(IOHIDDeviceRef)hidDevice interfaceNumber:(NSInteger)deviceInterfaceNumber {
    
    // A non-zero return value needs to be released by the caller.
    
    // hidService represents the IOHIDDevice instance in the kernel
    io_service_t hidService = IOHIDDeviceGetService(hidDevice);
    NSAssert( hidService != 0, @"" );
    if ( hidService == 0 ) {
        return 0;
    }
    
    // usbInterface represents the IOUSBInterface instance in the kernel
    io_registry_entry_t usbInterface = 0;
    kern_return_t usbInterfaceResult = IORegistryEntryGetParentEntry(hidService, kIOServicePlane, &usbInterface);
    NSAssert(usbInterfaceResult == KERN_SUCCESS, @"0x%08X", usbInterfaceResult);
    if ( usbInterfaceResult != KERN_SUCCESS ) {
        return 0;
    }
    
    // usbDevice represents the IOUSBDevice instance in the kernel
    io_registry_entry_t usbDevice = 0;
    kern_return_t usbDeviceResult = IORegistryEntryGetParentEntry(usbInterface, kIOServicePlane, &usbDevice);
    NSAssert(usbDeviceResult == KERN_SUCCESS, @"0x%08X", usbDeviceResult);
    if ( usbDeviceResult != KERN_SUCCESS ) {
        return 0;
    }
    
    // Iterate over the device's child entries to find an IOUSBInterface with a bInterfaceNumber of "0"
    
    io_iterator_t deviceChildIterator = 0;
    kern_return_t deviceChildIteratorResult = IORegistryEntryGetChildIterator(usbDevice, kIOServicePlane, &deviceChildIterator);
    NSAssert(deviceChildIteratorResult == KERN_SUCCESS, @"0x%08X", deviceChildIteratorResult);
    if ( deviceChildIteratorResult != KERN_SUCCESS ) {
        return 0;
    }
    
    io_service_t deviceChild = 0;
    while (( deviceChild = IOIteratorNext(deviceChildIterator) )) {
        
        if ( ! IOObjectConformsTo(deviceChild, kIOUSBInterfaceClassName) ) {
            IOObjectRelease(deviceChild);
            continue;
        }
        
        IOOptionBits options = 0;
        CFTypeRef property = IORegistryEntryCreateCFProperty(deviceChild, CFSTR(kUSBInterfaceNumber), kCFAllocatorDefault, options);
        if ( property == NULL ) {
            IOObjectRelease(deviceChild);
            continue;
        }
        
        if ( CFGetTypeID(property) != CFNumberGetTypeID() ) {
            CFRelease(property);
            IOObjectRelease(deviceChild);
            continue;
        }
        
        long interfaceNumber = 0;
        if ( ! CFNumberGetValue(property, kCFNumberLongType, &interfaceNumber) ) {
            CFRelease(property);
            IOObjectRelease(deviceChild);
            continue;
        }
        
        CFRelease(property);
        
        if ( interfaceNumber != deviceInterfaceNumber ) {
            IOObjectRelease(deviceChild);
            continue;
        }
        
        break;
    }
    
    IOObjectRelease(deviceChildIterator);
    
    return deviceChild;
}

+ (IOUSBInterfaceInterface **)createInterfaceWithService:(io_service_t)inService {
    
    // Step 1: Create a plugin interface for the service
    
    IOCFPlugInInterface **plugInInterface = NULL;
    SInt32 score = 0;
    IOReturn result = IOCreatePlugInInterfaceForService( inService, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score );
    NSAssert(plugInInterface != NULL, @"");
    if ( plugInInterface == NULL ) {
        return NULL;
    }
    if ( result == kIOReturnNoResources ) {
        // This status is returned if the device has already, been detached
        IODestroyPlugInInterface( plugInInterface );
        return NULL;
    }
    NSAssert(result == kIOReturnSuccess, @"0x%08X", result);
    if ( result != kIOReturnSuccess) {
        IODestroyPlugInInterface( plugInInterface );
        return NULL;
    }
    
    // Step 2: Create an interface to the IOUSBInterface instance in the kernel
    
    IOUSBInterfaceInterface **newInterface = NULL;
    HRESULT plugInResult = (*plugInInterface)->QueryInterface( plugInInterface, CFUUIDGetUUIDBytes( kIOUSBInterfaceInterfaceID ), (LPVOID)&newInterface );
    IODestroyPlugInInterface( plugInInterface );
    NSAssert(newInterface != NULL, @"");
    if ( newInterface == NULL ) {
        return NULL;
    }
    NSAssert(plugInResult == S_OK, @"0x%08X", plugInResult);
    if ( plugInResult != S_OK ) {
        (*newInterface)->Release( newInterface );
        return NULL;
    }
    
    // Step 3: Sanity check on the interface, at least one endpoint is needed
    
    UInt8 numEndpoints = 0;
    IOReturn endpointResult = (*newInterface)->GetNumEndpoints( newInterface, &numEndpoints );
    NSAssert(endpointResult == S_OK, @"0x%08X", endpointResult );
    if (endpointResult != S_OK) {
        (*newInterface)->Release( newInterface );
        return NULL;
    }
    NSAssert(numEndpoints >= 1, @"");
    if ( numEndpoints < 1 ) {
        (*newInterface)->Release( newInterface );
        return NULL;
    }
    
    return newInterface;
}

@end
