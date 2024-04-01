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

@interface OWGiphySDKInterop() <GiphyDelegate>

@end

@implementation OWGiphySDKInterop

@synthesize delegate;

+ (BOOL)giphySDKAvailable {
    if ([Giphy class]) {
        return YES;
    } else {
        return NO;
    }
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)configure:(NSString*)apiKey {
    if (OWGiphySDKInterop.giphySDKAvailable) {
        [Giphy configureWithApiKey:apiKey verificationMode:false metadata:@{@"": @""}];
    }
}

// TODO: support theme change
- (nullable UIViewController*)gifSelectionVC {
    if (OWGiphySDKInterop.giphySDKAvailable) {
        GiphyViewController *giphy = [[GiphyViewController alloc]init];
        giphy.delegate = self;
        return giphy;
    } else {
        return nil;
    }
}

// Giphy delegate implementation
- (void)didDismissWithController:(GiphyViewController * _Nullable)controller {
    [self.delegate didDismissWithController:controller];
}

- (void)didSelectMediaWithGiphyViewController:(GiphyViewController *)giphyViewController media:(GPHMedia *)media {
    OWGiphyMedia owMedia;

    // Initialize the struct
    owMedia.previewWidth = media.images.preview.width;
    owMedia.previewHeight = media.images.preview.height;
    owMedia.originalWidth = media.images.original.width;
    owMedia.originalHeight = media.images.original.height;
    owMedia.originalUrl = media.images.original.gifUrl;
    owMedia.title = media.title;
    owMedia.previewUrl = media.images.preview.gifUrl;

//    [self.delegate didSelectMediaWithGiphyViewController:giphyViewController media:owMedia];
}

@end
