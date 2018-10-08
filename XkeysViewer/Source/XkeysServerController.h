//
//  XkeysServerController.h
//  XkeysViewer
//
//  Registers callback blocks to be invoked when Xkeys devices are attached or removed.
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import AppKit;
@import XkeysKit;

@interface XkeysServerController : NSObject

// The devices array is bound to the contents of a popup button in the UI
@property (nonatomic) NSMutableArray<id<XkeysDevice>> *devices;

@end
