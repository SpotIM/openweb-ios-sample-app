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
@property GiphyViewController* _Nullable giphyVc;
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

- (nullable UIViewController*)gifSelectionVC:(Boolean)isDarkMode {
    if (OWGiphySDKInterop.giphySDKAvailable) {
        GiphyViewController *giphy = [[GiphyViewController alloc]init];
        GPHThemeType themetype = isDarkMode ? GPHThemeTypeDark : GPHThemeTypeLight;
        GPHTheme *theme = [[GPHTheme alloc]initWithType:themetype];
        giphy.theme = theme;
        giphy.delegate = self;
        self.giphyVc = giphy;
        return giphy;
    } else {
        return nil;
    }
}

- (void)setThemeMode:(Boolean)isDarkMode {
    GPHThemeType themetype = isDarkMode ? GPHThemeTypeDark : GPHThemeTypeLight;
    GPHTheme *theme = [[GPHTheme alloc]initWithType:themetype];
    self.giphyVc.theme = theme;
}

// Giphy delegate implementation
- (void)didDismissWithController:(GiphyViewController * _Nullable)controller {
    [self.delegate didDismissWithController:controller];
    self.giphyVc = nil; // TODO: GiphyVC is still in memry - investigate why
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
