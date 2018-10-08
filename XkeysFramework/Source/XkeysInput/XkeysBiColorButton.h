//
//  XkeysBiColorButton.h
//  XkeysFramework
//
//  This class represents a button on an Xkeys device that has blue and red backlight LEDs.
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import <XkeysKit/XkeysBlueRedButton.h>
#import <XkeysKit/XkeysLEDOutput.h>
#import "XkeysIndexedBitInput.h"

NS_ASSUME_NONNULL_BEGIN

@interface XkeysBiColorButton : XkeysIndexedBitInput <XkeysBlueRedButton>

@property (nonatomic) XkeysLEDOutput *blueLED;
@property (nonatomic) XkeysLEDOutput *redLED;

@end

NS_ASSUME_NONNULL_END
