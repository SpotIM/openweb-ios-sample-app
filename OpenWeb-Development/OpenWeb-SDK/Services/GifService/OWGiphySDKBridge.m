//
//  OWGiphySDKBridge.m
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 25/03/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWGiphySDKBridge.h"

@import GiphyUISDK;

@interface OWGiphySDKBridge() <GiphyDelegate>
@property GiphyViewController* _Nullable giphyVc;
@end

@implementation OWGiphySDKBridge

@synthesize delegate;

+ (BOOL)isGiphySDKAvailable {
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
    if (OWGiphySDKBridge.isGiphySDKAvailable) {
        [Giphy configureWithApiKey:apiKey verificationMode:false metadata:@{@"": @""}];
    }
}

- (nullable UIViewController*)gifSelectionVC {
    if (OWGiphySDKBridge.isGiphySDKAvailable) {
        GiphyViewController *giphy = [[GiphyViewController alloc]init];
        giphy.delegate = self;
        self.giphyVc = giphy;
        return giphy;
    } else {
        return nil;
    }
}

- (void)setIsDarkMode:(Boolean)isDarkMode {
    GPHThemeType themetype = isDarkMode ? GPHThemeTypeDark : GPHThemeTypeLight;
    GPHTheme *theme = [[GPHTheme alloc]initWithType:themetype];
    self.giphyVc.theme = theme;
}

// Giphy delegate implementation
- (void)didDismissWithController:(GiphyViewController * _Nullable)controller {
    [self.delegate didDismissWithController:controller];
    self.giphyVc = nil;
}

- (void)didSelectMediaWithGiphyViewController:(GiphyViewController *)giphyViewController media:(GPHMedia *)media {
    OWGiphyMedia *owMedia = [[OWGiphyMedia alloc]init];

    // Initialize the struct
    owMedia.previewWidth = media.images.preview.width;
    owMedia.previewHeight = media.images.preview.height;
    owMedia.originalWidth = media.images.original.width;
    owMedia.originalHeight = media.images.original.height;
    owMedia.originalUrl = media.images.original.gifUrl;
    owMedia.title = media.title;
    owMedia.previewUrl = media.images.preview.gifUrl;

    [self.delegate didSelectMediaWithGiphyViewController:giphyViewController media:owMedia];
}

@end

// Giphy Media class
@implementation OWGiphyMedia

@end
