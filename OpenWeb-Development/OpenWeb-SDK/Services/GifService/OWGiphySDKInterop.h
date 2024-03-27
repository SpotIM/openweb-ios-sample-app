//
//  OWGiphySDKInterop.h
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 25/03/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

#import <Foundation/Foundation.h>
// #import <OpenWebSDK/OpenWebSDK-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWGiphySDKInterop : NSObject

//@property (weak, nonatomic) id<InteropDelegate> delegate;

+ (BOOL)giphySDKAvailable;

- (instancetype)init;
//- (void)inspectWithNumber:(NSInteger)number;

@end

NS_ASSUME_NONNULL_END
