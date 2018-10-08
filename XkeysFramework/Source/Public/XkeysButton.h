//
//  XkeysButton.h
//  XkeysFramework
//
//  Created by Ken Heglund on 3/12/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import <XkeysKit/XkeysControl.h>

NS_ASSUME_NONNULL_BEGIN

/// Provides access to the properties of a general-purpose button
@protocol XkeysButton <XkeysControl>

/// The index of the button.
@property (nonatomic, readonly) NSInteger buttonNumber;

@end

NS_ASSUME_NONNULL_END
