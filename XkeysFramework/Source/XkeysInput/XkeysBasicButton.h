//
//  XkeysBasicButton.h
//  XkeysFramework
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

#import "XkeysKit/XkeysButton.h"
#import "XkeysInput.h"

@interface XkeysBasicButton : XkeysInput <XkeysButton>

@property (nonatomic) NSInteger buttonNumber;
@property (nonatomic, copy) NSString *buttonName;

- (instancetype)initWithDevice:(XkeysUnit<XkeysDevice> *)device cookie:(IOHIDElementCookie)cookie controlIndex:(NSInteger)controlIndex NS_DESIGNATED_INITIALIZER;

@end
