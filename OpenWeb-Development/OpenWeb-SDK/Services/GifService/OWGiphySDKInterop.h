//
//  OWGiphySDKInterop.h
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 25/03/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef struct {
    NSInteger previewWidth;
    NSInteger previewHeight;
    NSInteger originalWidth;
    NSInteger originalHeight;
    NSString* originalUrl;
    NSString * _Nullable title;
    NSString * _Nullable previewUrl;
} OWGiphyMedia;

@protocol OWGiphySDKInteropDelegate // <NSObject>

- (void)didDismissWithController:(UIViewController*)controller;
//- (void)didSelectMediaWithGiphyViewController:(UIViewController *)giphyViewController media:(OWGiphyMedia)media;

@end

@interface OWGiphySDKInterop : NSObject

@property (nonatomic, weak) id<OWGiphySDKInteropDelegate> delegate;

+ (BOOL)giphySDKAvailable;

- (instancetype)init;
- (void)configure:(NSString*)apiKey;
- (nullable UIViewController*)gifSelectionVC;

@end

NS_ASSUME_NONNULL_END
