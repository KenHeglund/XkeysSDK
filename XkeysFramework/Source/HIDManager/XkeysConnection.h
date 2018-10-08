//
//  XkeysConnection.h
//  XkeysFramework
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol XkeysConnection <NSObject>

@property (nonatomic, readonly) BOOL receivesData;

- (void)open;
- (void)close;

- (void)sendReportBytes:(uint8_t *)reportBuffer ofLength:(size_t)bufferLength;

@end

NS_ASSUME_NONNULL_END
