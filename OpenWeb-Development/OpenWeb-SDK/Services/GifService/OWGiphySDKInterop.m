//
//  OWGiphySDKInterop.m
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 25/03/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWGiphySDKInterop.h"

@import GiphyUISDK;

@interface OWGiphySDKInterop()

@end

@implementation OWGiphySDKInterop

+ (BOOL)giphySDKAvailable {
    if ([Giphy class]) {
        return YES;
    } else {
        return NO;
    }
}

- (instancetype)init {
    self = [super init];
//    if (self && [OWGiphySDKInterop giphySDKAvailable]) {
//        _primeChecker = [[PrimeNumberChecker alloc] init];
//        [_primeChecker setDelegate:self];
//    }
    return self;
}

- (void)configure:(NSString*)apiKey {
    if (OWGiphySDKInterop.giphySDKAvailable) {
        [Giphy configureWithApiKey:apiKey verificationMode:false metadata:@{@"": @""}];
    }
}

- (nullable UIViewController*)gifSelectionVC {
    if (OWGiphySDKInterop.giphySDKAvailable) {
        GiphyViewController *giphy = [[GiphyViewController alloc]init];
        return giphy;
    } else {
        return nil;
    }
}

@end
