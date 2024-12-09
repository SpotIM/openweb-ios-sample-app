#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

@class KSSASpotImAdsDebugSharedIos, KSSASpotImAdsSharedIos, KSSACampaignIdentifier, KSSASpotImAnalyticsInfo, KSSAAdUnitSetupDisplay, KSSAAdCampaignDisplay, KSSAAdUnitSetupVideo, KSSAAdCampaignVideo, KSSAAdSetup, KSSAAdUnitDisplayProviderNimbusPriceGranularity, KSSAAdUnitDisplayProviderNimbus, KSSAAdUnitDisplayProviderOpenWrap, KSSAAdUnitSize, KSSADisplayAutoRefresh, KSSAKotlinThrowable, KSSAKotlinPair<__covariant A, __covariant B>, KSSAAvResult<__covariant T>, KSSAKMPublisherProvidedId, KSSAKotlinEnumCompanion, KSSAKotlinEnum<E>, KSSAKMDisplayAdStatus, KSSAKotlinArray<T>, KSSADisplayAdLoadInfo, KSSAAvStateFlow<T>, KSSAContentEvents, KSSAAvSharedFlow<T>, KSSAKMDuration, KSSAKMAdPlacementViewModelFactory, KSSAContentEventsDisplay, KSSAContentEventsDisplayClickThrough, KSSAContentEventsDisplayClosed, KSSAContentEventsDisplayError, KSSAContentEventsDisplayImpression, KSSAContentEventsDisplayInventory, KSSAContentEventsDisplaySourceLoaded, KSSAContentEventsDisplayViewableImpression, KSSAContentEventsVideo, KSSAContentEventsVideoAdPaused, KSSAContentEventsVideoClickThrough, KSSAContentEventsVideoClosed, KSSAContentEventsVideoError, KSSAContentEventsVideoFullScreenToggleRequested, KSSAContentEventsVideoGeneric, KSSAContentEventsVideoImpression, KSSAContentEventsVideoInventory, KSSAContentEventsVideoMovedFromFullscreen, KSSAContentEventsVideoMovedToFullscreen, KSSAVideoProgress, KSSAContentEventsVideoProgress, KSSAContentEventsVideoSkippableStateChange, KSSAContentEventsVideoSourceLoaded, KSSAContentEventsVideoVideoAdServerCalled, KSSAContentEventsVideoViewableImpression, KSSAKMPlacementDisplayContentDisplay, KSSAKMPlacementDisplayContentEmpty, KSSAKMPlacementDisplayContentVideo, KSSAKotlinUnit, KSSAAvResultFailure<__covariant T>, KSSAAvResultSuccess<__covariant T>, KSSAKMAniviewTagStateHaveNoVideo, KSSAKMAniviewTagStateHaveVideo, KSSAKotlinException, KSSAKotlinRuntimeException, KSSAKotlinIllegalStateException, KSSAKotlinCancellationException;

@protocol KSSAPlayerIosProviding, KSSATagsIosProviding, KSSADisplayAdsSourceFactory, KSSAKMCrashReportProvider, KSSAKMGeoEdgeInitializer, KSSAAdCampaign, KSSAKotlinSequence, KSSAAdUnitDisplayProvider, KSSAAdUnitSetup, KSSAAniviewTag, KSSAKotlinx_coroutines_coreSharedFlow, KSSAKotlinx_coroutines_coreStateFlow, KSSAKotlinComparable, KSSADisplayAd, KSSADisplayAdsSource, KSSAKMPlacementDisplayContent, KSSAAdPlacementViewModel, KSSAKotlinx_coroutines_coreFlowCollector, KSSAKotlinx_coroutines_coreFlow, KSSAKotlinx_coroutines_coreMutableSharedFlow, KSSAKotlinx_coroutines_coreJob, KSSAKotlinx_coroutines_coreMutableStateFlow, KSSAKMAniviewTagState, KSSAKotlinIterator, KSSAKotlinx_coroutines_coreChildHandle, KSSAKotlinx_coroutines_coreChildJob, KSSAKotlinx_coroutines_coreDisposableHandle, KSSAKotlinx_coroutines_coreSelectClause0, KSSAKotlinCoroutineContextKey, KSSAKotlinCoroutineContextElement, KSSAKotlinCoroutineContext, KSSAKotlinx_coroutines_coreParentJob, KSSAKotlinx_coroutines_coreSelectInstance, KSSAKotlinx_coroutines_coreSelectClause;

NS_ASSUME_NONNULL_BEGIN
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunknown-warning-option"
#pragma clang diagnostic ignored "-Wincompatible-property-type"
#pragma clang diagnostic ignored "-Wnullability"

#pragma push_macro("_Nullable_result")
#if !__has_feature(nullability_nullable_result)
#undef _Nullable_result
#define _Nullable_result _Nullable
#endif

__attribute__((swift_name("KotlinBase")))
@interface KSSABase : NSObject
- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
+ (void)initialize __attribute__((objc_requires_super));
@end

@interface KSSABase (KSSABaseCopying) <NSCopying>
@end

__attribute__((swift_name("KotlinMutableSet")))
@interface KSSAMutableSet<ObjectType> : NSMutableSet<ObjectType>
@end

__attribute__((swift_name("KotlinMutableDictionary")))
@interface KSSAMutableDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>
@end

@interface NSError (NSErrorKSSAKotlinException)
@property (readonly) id _Nullable kotlinException;
@end

__attribute__((swift_name("KotlinNumber")))
@interface KSSANumber : NSNumber
- (instancetype)initWithChar:(char)value __attribute__((unavailable));
- (instancetype)initWithUnsignedChar:(unsigned char)value __attribute__((unavailable));
- (instancetype)initWithShort:(short)value __attribute__((unavailable));
- (instancetype)initWithUnsignedShort:(unsigned short)value __attribute__((unavailable));
- (instancetype)initWithInt:(int)value __attribute__((unavailable));
- (instancetype)initWithUnsignedInt:(unsigned int)value __attribute__((unavailable));
- (instancetype)initWithLong:(long)value __attribute__((unavailable));
- (instancetype)initWithUnsignedLong:(unsigned long)value __attribute__((unavailable));
- (instancetype)initWithLongLong:(long long)value __attribute__((unavailable));
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value __attribute__((unavailable));
- (instancetype)initWithFloat:(float)value __attribute__((unavailable));
- (instancetype)initWithDouble:(double)value __attribute__((unavailable));
- (instancetype)initWithBool:(BOOL)value __attribute__((unavailable));
- (instancetype)initWithInteger:(NSInteger)value __attribute__((unavailable));
- (instancetype)initWithUnsignedInteger:(NSUInteger)value __attribute__((unavailable));
+ (instancetype)numberWithChar:(char)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedChar:(unsigned char)value __attribute__((unavailable));
+ (instancetype)numberWithShort:(short)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedShort:(unsigned short)value __attribute__((unavailable));
+ (instancetype)numberWithInt:(int)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedInt:(unsigned int)value __attribute__((unavailable));
+ (instancetype)numberWithLong:(long)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedLong:(unsigned long)value __attribute__((unavailable));
+ (instancetype)numberWithLongLong:(long long)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value __attribute__((unavailable));
+ (instancetype)numberWithFloat:(float)value __attribute__((unavailable));
+ (instancetype)numberWithDouble:(double)value __attribute__((unavailable));
+ (instancetype)numberWithBool:(BOOL)value __attribute__((unavailable));
+ (instancetype)numberWithInteger:(NSInteger)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedInteger:(NSUInteger)value __attribute__((unavailable));
@end

__attribute__((swift_name("KotlinByte")))
@interface KSSAByte : KSSANumber
- (instancetype)initWithChar:(char)value;
+ (instancetype)numberWithChar:(char)value;
@end

__attribute__((swift_name("KotlinUByte")))
@interface KSSAUByte : KSSANumber
- (instancetype)initWithUnsignedChar:(unsigned char)value;
+ (instancetype)numberWithUnsignedChar:(unsigned char)value;
@end

__attribute__((swift_name("KotlinShort")))
@interface KSSAShort : KSSANumber
- (instancetype)initWithShort:(short)value;
+ (instancetype)numberWithShort:(short)value;
@end

__attribute__((swift_name("KotlinUShort")))
@interface KSSAUShort : KSSANumber
- (instancetype)initWithUnsignedShort:(unsigned short)value;
+ (instancetype)numberWithUnsignedShort:(unsigned short)value;
@end

__attribute__((swift_name("KotlinInt")))
@interface KSSAInt : KSSANumber
- (instancetype)initWithInt:(int)value;
+ (instancetype)numberWithInt:(int)value;
@end

__attribute__((swift_name("KotlinUInt")))
@interface KSSAUInt : KSSANumber
- (instancetype)initWithUnsignedInt:(unsigned int)value;
+ (instancetype)numberWithUnsignedInt:(unsigned int)value;
@end

__attribute__((swift_name("KotlinLong")))
@interface KSSALong : KSSANumber
- (instancetype)initWithLongLong:(long long)value;
+ (instancetype)numberWithLongLong:(long long)value;
@end

__attribute__((swift_name("KotlinULong")))
@interface KSSAULong : KSSANumber
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value;
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value;
@end

__attribute__((swift_name("KotlinFloat")))
@interface KSSAFloat : KSSANumber
- (instancetype)initWithFloat:(float)value;
+ (instancetype)numberWithFloat:(float)value;
@end

__attribute__((swift_name("KotlinDouble")))
@interface KSSADouble : KSSANumber
- (instancetype)initWithDouble:(double)value;
+ (instancetype)numberWithDouble:(double)value;
@end

__attribute__((swift_name("KotlinBoolean")))
@interface KSSABoolean : KSSANumber
- (instancetype)initWithBool:(BOOL)value;
+ (instancetype)numberWithBool:(BOOL)value;
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SpotImAdsDebugSharedIos")))
@interface KSSASpotImAdsDebugSharedIos : KSSABase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)spotImAdsDebugSharedIos __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSASpotImAdsDebugSharedIos *shared __attribute__((swift_name("shared")));
- (void)observeAnalyticsEventsOnEvent:(void (^)(NSString *, NSString *))onEvent __attribute__((swift_name("observeAnalyticsEvents(onEvent:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SpotImAdsSharedIos")))
@interface KSSASpotImAdsSharedIos : KSSABase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)spotImAdsSharedIos __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSASpotImAdsSharedIos *shared __attribute__((swift_name("shared")));
- (void)initializeSpotId:(NSString *)spotId libraryVersionName:(NSString *)libraryVersionName player:(id<KSSAPlayerIosProviding>)player tagsProvider:(id<KSSATagsIosProviding>)tagsProvider displayAdsSourceFactory:(id<KSSADisplayAdsSourceFactory>)displayAdsSourceFactory crashReportProvider:(id<KSSAKMCrashReportProvider>)crashReportProvider geoEdgeInitializer:(id<KSSAKMGeoEdgeInitializer>)geoEdgeInitializer __attribute__((swift_name("initialize(spotId:libraryVersionName:player:tagsProvider:displayAdsSourceFactory:crashReportProvider:geoEdgeInitializer:)")));
- (void)preloadSlotIdentifier:(KSSACampaignIdentifier *)identifier analyticsInfo:(KSSASpotImAnalyticsInfo * _Nullable)analyticsInfo __attribute__((swift_name("preloadSlot(identifier:analyticsInfo:)")));
@end

__attribute__((swift_name("AdCampaign")))
@protocol KSSAAdCampaign
@required
@property (readonly) KSSAAdUnitSetupDisplay * _Nullable displayAd __attribute__((swift_name("displayAd")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) KSSACampaignIdentifier *identifier __attribute__((swift_name("identifier")));
@property (readonly) BOOL isSticky __attribute__((swift_name("isSticky")));
@property (readonly) BOOL isTakeover __attribute__((swift_name("isTakeover")));
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("AdCampaignDisplay")))
@interface KSSAAdCampaignDisplay : KSSABase <KSSAAdCampaign>
- (instancetype)initWithId:(NSString *)id type:(NSString *)type identifier:(KSSACampaignIdentifier *)identifier isSticky:(BOOL)isSticky isTakeover:(BOOL)isTakeover displayAd:(KSSAAdUnitSetupDisplay *)displayAd __attribute__((swift_name("init(id:type:identifier:isSticky:isTakeover:displayAd:)"))) __attribute__((objc_designated_initializer));
- (KSSAAdCampaignDisplay *)doCopyId:(NSString *)id type:(NSString *)type identifier:(KSSACampaignIdentifier *)identifier isSticky:(BOOL)isSticky isTakeover:(BOOL)isTakeover displayAd:(KSSAAdUnitSetupDisplay *)displayAd __attribute__((swift_name("doCopy(id:type:identifier:isSticky:isTakeover:displayAd:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) KSSAAdUnitSetupDisplay *displayAd __attribute__((swift_name("displayAd")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) KSSACampaignIdentifier *identifier __attribute__((swift_name("identifier")));
@property (readonly) BOOL isSticky __attribute__((swift_name("isSticky")));
@property (readonly) BOOL isTakeover __attribute__((swift_name("isTakeover")));
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("AdCampaignVideo")))
@interface KSSAAdCampaignVideo : KSSABase <KSSAAdCampaign>
- (instancetype)initWithId:(NSString *)id type:(NSString *)type identifier:(KSSACampaignIdentifier *)identifier isSticky:(BOOL)isSticky isTakeover:(BOOL)isTakeover displayAd:(KSSAAdUnitSetupDisplay * _Nullable)displayAd videoAd:(KSSAAdUnitSetupVideo *)videoAd displayAdAfterVideo:(KSSAAdUnitSetupDisplay * _Nullable)displayAdAfterVideo __attribute__((swift_name("init(id:type:identifier:isSticky:isTakeover:displayAd:videoAd:displayAdAfterVideo:)"))) __attribute__((objc_designated_initializer));
- (KSSAAdCampaignVideo *)doCopyId:(NSString *)id type:(NSString *)type identifier:(KSSACampaignIdentifier *)identifier isSticky:(BOOL)isSticky isTakeover:(BOOL)isTakeover displayAd:(KSSAAdUnitSetupDisplay * _Nullable)displayAd videoAd:(KSSAAdUnitSetupVideo *)videoAd displayAdAfterVideo:(KSSAAdUnitSetupDisplay * _Nullable)displayAdAfterVideo __attribute__((swift_name("doCopy(id:type:identifier:isSticky:isTakeover:displayAd:videoAd:displayAdAfterVideo:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) KSSAAdUnitSetupDisplay * _Nullable displayAd __attribute__((swift_name("displayAd")));
@property (readonly) KSSAAdUnitSetupDisplay * _Nullable displayAdAfterVideo __attribute__((swift_name("displayAdAfterVideo")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) KSSACampaignIdentifier *identifier __attribute__((swift_name("identifier")));
@property (readonly) BOOL isSticky __attribute__((swift_name("isSticky")));
@property (readonly) BOOL isTakeover __attribute__((swift_name("isTakeover")));
@property (readonly) NSString *type __attribute__((swift_name("type")));
@property (readonly) KSSAAdUnitSetupVideo *videoAd __attribute__((swift_name("videoAd")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("AdSetup")))
@interface KSSAAdSetup : KSSABase
- (instancetype)initWithSpotId:(NSString *)spotId monetizationId:(NSString *)monetizationId mcmNetworkId:(NSString *)mcmNetworkId sellerId:(NSString *)sellerId clientIp:(NSString *)clientIp campaigns:(NSArray<id<KSSAAdCampaign>> *)campaigns __attribute__((swift_name("init(spotId:monetizationId:mcmNetworkId:sellerId:clientIp:campaigns:)"))) __attribute__((objc_designated_initializer));
- (KSSAAdSetup *)doCopySpotId:(NSString *)spotId monetizationId:(NSString *)monetizationId mcmNetworkId:(NSString *)mcmNetworkId sellerId:(NSString *)sellerId clientIp:(NSString *)clientIp campaigns:(NSArray<id<KSSAAdCampaign>> *)campaigns __attribute__((swift_name("doCopy(spotId:monetizationId:mcmNetworkId:sellerId:clientIp:campaigns:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (id<KSSAAdCampaign> _Nullable)getCampaignOrNullIdentifier:(KSSACampaignIdentifier *)identifier __attribute__((swift_name("getCampaignOrNull(identifier:)")));
- (id<KSSAKotlinSequence>)getDisplayAds __attribute__((swift_name("getDisplayAds()")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSArray<id<KSSAAdCampaign>> *campaigns __attribute__((swift_name("campaigns")));
@property (readonly) NSString *clientIp __attribute__((swift_name("clientIp")));
@property (readonly) NSString *mcmNetworkId __attribute__((swift_name("mcmNetworkId")));
@property (readonly) NSString *monetizationId __attribute__((swift_name("monetizationId")));
@property (readonly) NSString *sellerId __attribute__((swift_name("sellerId")));
@property (readonly) NSString *spotId __attribute__((swift_name("spotId")));
@end

__attribute__((swift_name("AdUnitDisplayProvider")))
@protocol KSSAAdUnitDisplayProvider
@required
@property (readonly) int64_t noAdTimeout __attribute__((swift_name("noAdTimeout")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("AdUnitDisplayProviderNimbus")))
@interface KSSAAdUnitDisplayProviderNimbus : KSSABase <KSSAAdUnitDisplayProvider>
- (instancetype)initWithApiKey:(NSString *)apiKey publisherKey:(NSString *)publisherKey position:(NSString *)position gamUnitId:(NSString *)gamUnitId priceMapping:(NSArray<KSSAAdUnitDisplayProviderNimbusPriceGranularity *> *)priceMapping __attribute__((swift_name("init(apiKey:publisherKey:position:gamUnitId:priceMapping:)"))) __attribute__((objc_designated_initializer));
- (KSSAAdUnitDisplayProviderNimbus *)doCopyApiKey:(NSString *)apiKey publisherKey:(NSString *)publisherKey position:(NSString *)position gamUnitId:(NSString *)gamUnitId priceMapping:(NSArray<KSSAAdUnitDisplayProviderNimbusPriceGranularity *> *)priceMapping __attribute__((swift_name("doCopy(apiKey:publisherKey:position:gamUnitId:priceMapping:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *apiKey __attribute__((swift_name("apiKey")));
@property (readonly) NSString *gamUnitId __attribute__((swift_name("gamUnitId")));
@property (readonly) int64_t noAdTimeout __attribute__((swift_name("noAdTimeout")));
@property (readonly) NSString *position __attribute__((swift_name("position")));
@property (readonly) NSArray<KSSAAdUnitDisplayProviderNimbusPriceGranularity *> *priceMapping __attribute__((swift_name("priceMapping")));
@property (readonly) NSString *publisherKey __attribute__((swift_name("publisherKey")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("AdUnitDisplayProviderNimbus.PriceGranularity")))
@interface KSSAAdUnitDisplayProviderNimbusPriceGranularity : KSSABase
- (instancetype)initWithMin:(int32_t)min max:(int32_t)max step:(int32_t)step __attribute__((swift_name("init(min:max:step:)"))) __attribute__((objc_designated_initializer));
- (KSSAAdUnitDisplayProviderNimbusPriceGranularity *)doCopyMin:(int32_t)min max:(int32_t)max step:(int32_t)step __attribute__((swift_name("doCopy(min:max:step:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) int32_t max __attribute__((swift_name("max")));
@property (readonly) int32_t min __attribute__((swift_name("min")));
@property (readonly) int32_t step __attribute__((swift_name("step")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("AdUnitDisplayProviderOpenWrap")))
@interface KSSAAdUnitDisplayProviderOpenWrap : KSSABase <KSSAAdUnitDisplayProvider>
- (instancetype)initWithAdUnit:(NSString *)adUnit adUnitId:(NSString *)adUnitId profileId:(int32_t)profileId publisherId:(NSString *)publisherId __attribute__((swift_name("init(adUnit:adUnitId:profileId:publisherId:)"))) __attribute__((objc_designated_initializer));
- (KSSAAdUnitDisplayProviderOpenWrap *)doCopyAdUnit:(NSString *)adUnit adUnitId:(NSString *)adUnitId profileId:(int32_t)profileId publisherId:(NSString *)publisherId __attribute__((swift_name("doCopy(adUnit:adUnitId:profileId:publisherId:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *adUnit __attribute__((swift_name("adUnit")));
@property (readonly) NSString *adUnitId __attribute__((swift_name("adUnitId")));
@property (readonly) int64_t noAdTimeout __attribute__((swift_name("noAdTimeout")));
@property (readonly) int32_t profileId __attribute__((swift_name("profileId")));
@property (readonly) NSString *publisherId __attribute__((swift_name("publisherId")));
@end

__attribute__((swift_name("AdUnitSetup")))
@protocol KSSAAdUnitSetup
@required
@property (readonly) KSSACampaignIdentifier *campaignIdentifier __attribute__((swift_name("campaignIdentifier")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) KSSAAdUnitSize * _Nullable size __attribute__((swift_name("size")));
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("AdUnitSetupDisplay")))
@interface KSSAAdUnitSetupDisplay : KSSABase <KSSAAdUnitSetup>
- (instancetype)initWithId:(NSString *)id type:(NSString *)type size:(KSSAAdUnitSize * _Nullable)size campaignIdentifier:(KSSACampaignIdentifier *)campaignIdentifier provider:(id<KSSAAdUnitDisplayProvider>)provider sizes:(NSArray<KSSAAdUnitSize *> *)sizes iauSdkSpotId:(NSString *)iauSdkSpotId videoFloorPrice:(NSString * _Nullable)videoFloorPrice keyValues:(NSDictionary<NSString *, NSString *> *)keyValues autoRefresh:(KSSADisplayAutoRefresh *)autoRefresh intentIqEnabled:(BOOL)intentIqEnabled geoEdgeApiKey:(NSString *)geoEdgeApiKey geoEdgeEnabled:(BOOL)geoEdgeEnabled mpvVisibilityDelay:(int64_t)mpvVisibilityDelay guaranteedVisibilityTime:(id _Nullable)guaranteedVisibilityTime __attribute__((swift_name("init(id:type:size:campaignIdentifier:provider:sizes:iauSdkSpotId:videoFloorPrice:keyValues:autoRefresh:intentIqEnabled:geoEdgeApiKey:geoEdgeEnabled:mpvVisibilityDelay:guaranteedVisibilityTime:)"))) __attribute__((objc_designated_initializer));
- (KSSAAdUnitSetupDisplay *)doCopyId:(NSString *)id type:(NSString *)type size:(KSSAAdUnitSize * _Nullable)size campaignIdentifier:(KSSACampaignIdentifier *)campaignIdentifier provider:(id<KSSAAdUnitDisplayProvider>)provider sizes:(NSArray<KSSAAdUnitSize *> *)sizes iauSdkSpotId:(NSString *)iauSdkSpotId videoFloorPrice:(NSString * _Nullable)videoFloorPrice keyValues:(NSDictionary<NSString *, NSString *> *)keyValues autoRefresh:(KSSADisplayAutoRefresh *)autoRefresh intentIqEnabled:(BOOL)intentIqEnabled geoEdgeApiKey:(NSString *)geoEdgeApiKey geoEdgeEnabled:(BOOL)geoEdgeEnabled mpvVisibilityDelay:(int64_t)mpvVisibilityDelay guaranteedVisibilityTime:(id _Nullable)guaranteedVisibilityTime __attribute__((swift_name("doCopy(id:type:size:campaignIdentifier:provider:sizes:iauSdkSpotId:videoFloorPrice:keyValues:autoRefresh:intentIqEnabled:geoEdgeApiKey:geoEdgeEnabled:mpvVisibilityDelay:guaranteedVisibilityTime:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) KSSADisplayAutoRefresh *autoRefresh __attribute__((swift_name("autoRefresh")));
@property (readonly) KSSACampaignIdentifier *campaignIdentifier __attribute__((swift_name("campaignIdentifier")));
@property (readonly) NSString *geoEdgeApiKey __attribute__((swift_name("geoEdgeApiKey")));
@property (readonly) BOOL geoEdgeEnabled __attribute__((swift_name("geoEdgeEnabled")));
@property (readonly) id _Nullable guaranteedVisibilityTime __attribute__((swift_name("guaranteedVisibilityTime")));
@property (readonly) NSString *iauSdkSpotId __attribute__((swift_name("iauSdkSpotId")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) BOOL intentIqEnabled __attribute__((swift_name("intentIqEnabled")));
@property (readonly) NSDictionary<NSString *, NSString *> *keyValues __attribute__((swift_name("keyValues")));
@property (readonly) int64_t mpvVisibilityDelay __attribute__((swift_name("mpvVisibilityDelay")));
@property (readonly) id<KSSAAdUnitDisplayProvider> provider __attribute__((swift_name("provider")));
@property (readonly) KSSAAdUnitSize * _Nullable size __attribute__((swift_name("size")));
@property (readonly) NSArray<KSSAAdUnitSize *> *sizes __attribute__((swift_name("sizes")));
@property (readonly) NSString *type __attribute__((swift_name("type")));
@property (readonly) NSString * _Nullable videoFloorPrice __attribute__((swift_name("videoFloorPrice")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("AdUnitSetupVideo")))
@interface KSSAAdUnitSetupVideo : KSSABase <KSSAAdUnitSetup>
- (instancetype)initWithId:(NSString *)id type:(NSString *)type size:(KSSAAdUnitSize * _Nullable)size campaignIdentifier:(KSSACampaignIdentifier *)campaignIdentifier publisherId:(NSString *)publisherId tagId:(NSString *)tagId channelId:(NSString *)channelId __attribute__((swift_name("init(id:type:size:campaignIdentifier:publisherId:tagId:channelId:)"))) __attribute__((objc_designated_initializer));
- (KSSAAdUnitSetupVideo *)doCopyId:(NSString *)id type:(NSString *)type size:(KSSAAdUnitSize * _Nullable)size campaignIdentifier:(KSSACampaignIdentifier *)campaignIdentifier publisherId:(NSString *)publisherId tagId:(NSString *)tagId channelId:(NSString *)channelId __attribute__((swift_name("doCopy(id:type:size:campaignIdentifier:publisherId:tagId:channelId:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) KSSACampaignIdentifier *campaignIdentifier __attribute__((swift_name("campaignIdentifier")));
@property (readonly) NSString *channelId __attribute__((swift_name("channelId")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) NSString *publisherId __attribute__((swift_name("publisherId")));
@property (readonly) KSSAAdUnitSize * _Nullable size __attribute__((swift_name("size")));
@property (readonly) NSString *tagId __attribute__((swift_name("tagId")));
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("AdUnitSize")))
@interface KSSAAdUnitSize : KSSABase
- (instancetype)initWithWidth:(int32_t)width height:(int32_t)height __attribute__((swift_name("init(width:height:)"))) __attribute__((objc_designated_initializer));
- (KSSAAdUnitSize *)doCopyWidth:(int32_t)width height:(int32_t)height __attribute__((swift_name("doCopy(width:height:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) int32_t height __attribute__((swift_name("height")));
@property (readonly) int32_t width __attribute__((swift_name("width")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("CampaignIdentifier")))
@interface KSSACampaignIdentifier : KSSABase
- (instancetype)initWithRow:(int32_t)row column:(int32_t)column __attribute__((swift_name("init(row:column:)"))) __attribute__((objc_designated_initializer));
- (KSSACampaignIdentifier *)doCopyRow:(int32_t)row column:(int32_t)column __attribute__((swift_name("doCopy(row:column:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) int32_t column __attribute__((swift_name("column")));
@property (readonly) int32_t row __attribute__((swift_name("row")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("DisplayAutoRefresh")))
@interface KSSADisplayAutoRefresh : KSSABase
- (instancetype)initWithLimit:(int32_t)limit timeout:(int64_t)timeout onlyWhenVisible:(BOOL)onlyWhenVisible __attribute__((swift_name("init(limit:timeout:onlyWhenVisible:)"))) __attribute__((objc_designated_initializer));
- (KSSADisplayAutoRefresh *)doCopyLimit:(int32_t)limit timeout:(int64_t)timeout onlyWhenVisible:(BOOL)onlyWhenVisible __attribute__((swift_name("doCopy(limit:timeout:onlyWhenVisible:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) int32_t limit __attribute__((swift_name("limit")));
@property (readonly) BOOL onlyWhenVisible __attribute__((swift_name("onlyWhenVisible")));
@property (readonly) int64_t timeout __attribute__((swift_name("timeout")));
@end

__attribute__((swift_name("KMCrashReportProvider")))
@protocol KSSAKMCrashReportProvider
@required
- (void)doInit __attribute__((swift_name("doInit()")));
- (void)messageMessage:(NSString *)message __attribute__((swift_name("message(message:)")));
- (void)reportThrowable:(KSSAKotlinThrowable *)throwable __attribute__((swift_name("report(throwable:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SpotImAnalyticsInfo")))
@interface KSSASpotImAnalyticsInfo : KSSABase
- (instancetype)initWithPostId:(NSString *)postId __attribute__((swift_name("init(postId:)"))) __attribute__((objc_designated_initializer));
- (KSSASpotImAnalyticsInfo *)doCopyPostId:(NSString *)postId __attribute__((swift_name("doCopy(postId:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property NSString *postId __attribute__((swift_name("postId")));
@end

__attribute__((swift_name("KMPlayerProviding")))
@protocol KSSAPlayerIosProviding
@required
- (void)initializePublisherPublisherId:(NSString *)publisherId tagIds:(NSArray<KSSAKotlinPair<NSString *, KSSAAdCampaignVideo *> *> *)tagIds adSetup:(KSSAAdSetup *)adSetup completion:(void (^)(KSSAKotlinThrowable * _Nullable))completion __attribute__((swift_name("initializePublisher(publisherId:tagIds:adSetup:completion:)")));
@end

__attribute__((swift_name("KMTagsProviding")))
@protocol KSSATagsIosProviding
@required
- (void)getTagId:(NSString *)id completion:(void (^)(KSSAAvResult<id<KSSAAniviewTag>> *))completion __attribute__((swift_name("getTag(id:completion:)")));
@end

__attribute__((swift_name("KMDisplayAd")))
@protocol KSSADisplayAd
@required
- (void)dispose __attribute__((swift_name("dispose()")));
@property (readonly) id<KSSAKotlinx_coroutines_coreSharedFlow> events __attribute__((swift_name("events")));
@property (readonly) id<KSSAKotlinx_coroutines_coreStateFlow> impressionsCount __attribute__((swift_name("impressionsCount")));
@property (readonly) BOOL isExpired __attribute__((swift_name("isExpired")));
@property (readonly) id<KSSAKotlinx_coroutines_coreStateFlow> ready __attribute__((swift_name("ready")));
@property (readonly) KSSAAdUnitSetupDisplay *setup __attribute__((swift_name("setup")));
@property (readonly) id view __attribute__((swift_name("view")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMDisplayAdLoadInfo")))
@interface KSSADisplayAdLoadInfo : KSSABase
- (instancetype)initWithGeoEdgeEnabled:(BOOL)geoEdgeEnabled publisherProvidedId:(KSSAKMPublisherProvidedId * _Nullable)publisherProvidedId additionalKeyValues:(NSDictionary<NSString *, NSString *> *)additionalKeyValues __attribute__((swift_name("init(geoEdgeEnabled:publisherProvidedId:additionalKeyValues:)"))) __attribute__((objc_designated_initializer));
@property (readonly) NSDictionary<NSString *, NSString *> *additionalKeyValues __attribute__((swift_name("additionalKeyValues")));
@property (readonly) BOOL geoEdgeEnabled __attribute__((swift_name("geoEdgeEnabled")));
@property (readonly) KSSAKMPublisherProvidedId * _Nullable publisherProvidedId __attribute__((swift_name("publisherProvidedId")));
@end

__attribute__((swift_name("KotlinComparable")))
@protocol KSSAKotlinComparable
@required
- (int32_t)compareToOther:(id _Nullable)other __attribute__((swift_name("compareTo(other:)")));
@end

__attribute__((swift_name("KotlinEnum")))
@interface KSSAKotlinEnum<E> : KSSABase <KSSAKotlinComparable>
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) KSSAKotlinEnumCompanion *companion __attribute__((swift_name("companion")));
- (int32_t)compareToOther:(E)other __attribute__((swift_name("compareTo(other:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
@property (readonly) int32_t ordinal __attribute__((swift_name("ordinal")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMDisplayAdStatus")))
@interface KSSAKMDisplayAdStatus : KSSAKotlinEnum<KSSAKMDisplayAdStatus *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly) KSSAKMDisplayAdStatus *initial __attribute__((swift_name("initial")));
@property (class, readonly) KSSAKMDisplayAdStatus *ready __attribute__((swift_name("ready")));
@property (class, readonly) KSSAKMDisplayAdStatus *noads __attribute__((swift_name("noads")));
@property (class, readonly) KSSAKMDisplayAdStatus *error __attribute__((swift_name("error")));
@property (class, readonly) KSSAKMDisplayAdStatus *blocked __attribute__((swift_name("blocked")));
+ (KSSAKotlinArray<KSSAKMDisplayAdStatus *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<KSSAKMDisplayAdStatus *> *entries __attribute__((swift_name("entries")));
@property (readonly) BOOL failure __attribute__((swift_name("failure")));
@end

__attribute__((swift_name("KMDisplayAdsSource")))
@protocol KSSADisplayAdsSource
@required
- (id<KSSADisplayAd>)loadAdSetup:(KSSAAdUnitSetupDisplay *)setup info:(KSSADisplayAdLoadInfo *)info __attribute__((swift_name("loadAd(setup:info:)")));
@end

__attribute__((swift_name("KMDisplayAdsSourceFactory")))
@protocol KSSADisplayAdsSourceFactory
@required
- (id<KSSADisplayAdsSource>)create __attribute__((swift_name("create()")));
@end

__attribute__((swift_name("KMAdPlacementViewModel")))
@protocol KSSAAdPlacementViewModel
@required
- (void)sendMpvDelayedEvent __attribute__((swift_name("sendMpvDelayedEvent()")));
- (void)sendMpvEvent __attribute__((swift_name("sendMpvEvent()")));
- (void)setAnalyticsAdditionalInfoInfo:(KSSASpotImAnalyticsInfo *)info __attribute__((swift_name("setAnalyticsAdditionalInfo(info:)")));
- (void)setCampaignIdentifierIdentifier:(KSSACampaignIdentifier * _Nullable)identifier __attribute__((swift_name("setCampaignIdentifier(identifier:)")));
- (void)setScreenIdId:(NSString *)id __attribute__((swift_name("setScreenId(id:)")));
- (void)setScreenResumedActive:(BOOL)active __attribute__((swift_name("setScreenResumed(active:)")));
- (void)setViewAttachedAttached:(BOOL)attached __attribute__((swift_name("setViewAttached(attached:)")));
- (void)setVisibilityFraction:(float)fraction __attribute__((swift_name("setVisibility(fraction:)")));
@property (readonly) KSSAAvStateFlow<NSString *> *aniviewTagId __attribute__((swift_name("aniviewTagId")));
@property (readonly) KSSAAvStateFlow<id<KSSAKMPlacementDisplayContent>> *displayContent __attribute__((swift_name("displayContent")));
@property (readonly) KSSAAvSharedFlow<KSSAContentEvents *> *event __attribute__((swift_name("event")));
@property (readonly) KSSAAvStateFlow<KSSAKMDuration *> *mpvVisibilityDelay __attribute__((swift_name("mpvVisibilityDelay")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMAdPlacementViewModelFactory")))
@interface KSSAKMAdPlacementViewModelFactory : KSSABase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)kMAdPlacementViewModelFactory __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAKMAdPlacementViewModelFactory *shared __attribute__((swift_name("shared")));
- (id<KSSAAdPlacementViewModel>)createPlacementId:(NSString *)placementId __attribute__((swift_name("create(placementId:)")));
@end

__attribute__((swift_name("KMContentEvent")))
@interface KSSAContentEvents : KSSABase
@end

__attribute__((swift_name("KMContentEvent.Display")))
@interface KSSAContentEventsDisplay : KSSAContentEvents
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.DisplayClickThrough")))
@interface KSSAContentEventsDisplayClickThrough : KSSAContentEventsDisplay
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)clickThrough __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsDisplayClickThrough *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.DisplayClosed")))
@interface KSSAContentEventsDisplayClosed : KSSAContentEventsDisplay
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)closed __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsDisplayClosed *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.DisplayError")))
@interface KSSAContentEventsDisplayError : KSSAContentEventsDisplay
- (instancetype)initWithMessage:(NSString *)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (KSSAContentEventsDisplayError *)doCopyMessage:(NSString *)message __attribute__((swift_name("doCopy(message:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *message __attribute__((swift_name("message")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.DisplayImpression")))
@interface KSSAContentEventsDisplayImpression : KSSAContentEventsDisplay
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)impression __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsDisplayImpression *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.DisplayInventory")))
@interface KSSAContentEventsDisplayInventory : KSSAContentEventsDisplay
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)inventory __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsDisplayInventory *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.DisplaySourceLoaded")))
@interface KSSAContentEventsDisplaySourceLoaded : KSSAContentEventsDisplay
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)sourceLoaded __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsDisplaySourceLoaded *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.DisplayViewableImpression")))
@interface KSSAContentEventsDisplayViewableImpression : KSSAContentEventsDisplay
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)viewableImpression __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsDisplayViewableImpression *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("KMContentEvent.Video")))
@interface KSSAContentEventsVideo : KSSAContentEvents
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoAdPaused")))
@interface KSSAContentEventsVideoAdPaused : KSSAContentEventsVideo
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)adPaused __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsVideoAdPaused *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoClickThrough")))
@interface KSSAContentEventsVideoClickThrough : KSSAContentEventsVideo
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)clickThrough __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsVideoClickThrough *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoClosed")))
@interface KSSAContentEventsVideoClosed : KSSAContentEventsVideo
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)closed __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsVideoClosed *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoError")))
@interface KSSAContentEventsVideoError : KSSAContentEventsVideo
- (instancetype)initWithMessage:(NSString *)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (KSSAContentEventsVideoError *)doCopyMessage:(NSString *)message __attribute__((swift_name("doCopy(message:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *message __attribute__((swift_name("message")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoFullScreenToggleRequested")))
@interface KSSAContentEventsVideoFullScreenToggleRequested : KSSAContentEventsVideo
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)fullScreenToggleRequested __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsVideoFullScreenToggleRequested *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoGeneric")))
@interface KSSAContentEventsVideoGeneric : KSSAContentEventsVideo
- (instancetype)initWithName:(NSString *)name __attribute__((swift_name("init(name:)"))) __attribute__((objc_designated_initializer));
- (KSSAContentEventsVideoGeneric *)doCopyName:(NSString *)name __attribute__((swift_name("doCopy(name:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoImpression")))
@interface KSSAContentEventsVideoImpression : KSSAContentEventsVideo
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)impression __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsVideoImpression *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoInventory")))
@interface KSSAContentEventsVideoInventory : KSSAContentEventsVideo
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)inventory __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsVideoInventory *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoMovedFromFullscreen")))
@interface KSSAContentEventsVideoMovedFromFullscreen : KSSAContentEventsVideo
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)movedFromFullscreen __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsVideoMovedFromFullscreen *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoMovedToFullscreen")))
@interface KSSAContentEventsVideoMovedToFullscreen : KSSAContentEventsVideo
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)movedToFullscreen __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsVideoMovedToFullscreen *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoProgress")))
@interface KSSAContentEventsVideoProgress : KSSAContentEventsVideo
- (instancetype)initWithProgress:(KSSAVideoProgress *)progress __attribute__((swift_name("init(progress:)"))) __attribute__((objc_designated_initializer));
- (KSSAContentEventsVideoProgress *)doCopyProgress:(KSSAVideoProgress *)progress __attribute__((swift_name("doCopy(progress:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) KSSAVideoProgress *progress __attribute__((swift_name("progress")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoSkippableStateChange")))
@interface KSSAContentEventsVideoSkippableStateChange : KSSAContentEventsVideo
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)skippableStateChange __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsVideoSkippableStateChange *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoSourceLoaded")))
@interface KSSAContentEventsVideoSourceLoaded : KSSAContentEventsVideo
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)sourceLoaded __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsVideoSourceLoaded *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoVideoAdServerCalled")))
@interface KSSAContentEventsVideoVideoAdServerCalled : KSSAContentEventsVideo
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)videoAdServerCalled __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsVideoVideoAdServerCalled *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMContentEvent.VideoViewableImpression")))
@interface KSSAContentEventsVideoViewableImpression : KSSAContentEventsVideo
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)viewableImpression __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAContentEventsVideoViewableImpression *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("KMPlacementDisplayContent")))
@protocol KSSAKMPlacementDisplayContent
@required
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMPlacementDisplayContentDisplay")))
@interface KSSAKMPlacementDisplayContentDisplay : KSSABase <KSSAKMPlacementDisplayContent>
- (instancetype)initWithAd:(id<KSSADisplayAd>)ad __attribute__((swift_name("init(ad:)"))) __attribute__((objc_designated_initializer));
- (KSSAKMPlacementDisplayContentDisplay *)doCopyAd:(id<KSSADisplayAd>)ad __attribute__((swift_name("doCopy(ad:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) id<KSSADisplayAd> ad __attribute__((swift_name("ad")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMPlacementDisplayContentEmpty")))
@interface KSSAKMPlacementDisplayContentEmpty : KSSABase <KSSAKMPlacementDisplayContent>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)empty __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAKMPlacementDisplayContentEmpty *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMPlacementDisplayContentVideo")))
@interface KSSAKMPlacementDisplayContentVideo : KSSABase <KSSAKMPlacementDisplayContent>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)video __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAKMPlacementDisplayContentVideo *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMVideoProgress")))
@interface KSSAVideoProgress : KSSAKotlinEnum<KSSAVideoProgress *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly) KSSAVideoProgress *started __attribute__((swift_name("started")));
@property (class, readonly) KSSAVideoProgress *firstQuartile __attribute__((swift_name("firstQuartile")));
@property (class, readonly) KSSAVideoProgress *midpoint __attribute__((swift_name("midpoint")));
@property (class, readonly) KSSAVideoProgress *thirdQuartile __attribute__((swift_name("thirdQuartile")));
@property (class, readonly) KSSAVideoProgress *complete __attribute__((swift_name("complete")));
+ (KSSAKotlinArray<KSSAVideoProgress *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<KSSAVideoProgress *> *entries __attribute__((swift_name("entries")));
@end

__attribute__((swift_name("KMGeoEdgeInitializer")))
@protocol KSSAKMGeoEdgeInitializer
@required
- (void)initializeApiKey:(NSString *)apiKey result:(void (^)(KSSAAvResult<KSSAKotlinUnit *> *))result __attribute__((swift_name("initialize(apiKey:result:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMPublisherProvidedId")))
@interface KSSAKMPublisherProvidedId : KSSABase
- (void)reportBidResult __attribute__((swift_name("reportBidResult()")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) int64_t timestamp __attribute__((swift_name("timestamp")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreFlow")))
@protocol KSSAKotlinx_coroutines_coreFlow
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<KSSAKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreSharedFlow")))
@protocol KSSAKotlinx_coroutines_coreSharedFlow <KSSAKotlinx_coroutines_coreFlow>
@required
@property (readonly) NSArray<id> *replayCache __attribute__((swift_name("replayCache")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreFlowCollector")))
@protocol KSSAKotlinx_coroutines_coreFlowCollector
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)emitValue:(id _Nullable)value completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("emit(value:completionHandler:)")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreMutableSharedFlow")))
@protocol KSSAKotlinx_coroutines_coreMutableSharedFlow <KSSAKotlinx_coroutines_coreSharedFlow, KSSAKotlinx_coroutines_coreFlowCollector>
@required

/**
 * @note annotations
 *   kotlinx.coroutines.ExperimentalCoroutinesApi
*/
- (void)resetReplayCache __attribute__((swift_name("resetReplayCache()")));
- (BOOL)tryEmitValue:(id _Nullable)value __attribute__((swift_name("tryEmit(value:)")));
@property (readonly) id<KSSAKotlinx_coroutines_coreStateFlow> subscriptionCount __attribute__((swift_name("subscriptionCount")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMMutableSharedFlow")))
@interface KSSAAvMutableSharedFlow<T> : KSSABase <KSSAKotlinx_coroutines_coreMutableSharedFlow>
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<KSSAKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)emitValue:(T _Nullable)value completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("emit(value:completionHandler:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.ExperimentalCoroutinesApi
*/
- (void)resetReplayCache __attribute__((swift_name("resetReplayCache()")));
- (id<KSSAKotlinx_coroutines_coreJob>)subscribeOnChange:(void (^)(T _Nullable))onChange __attribute__((swift_name("subscribe(onChange:)")));
- (BOOL)tryEmitValue:(T _Nullable)value __attribute__((swift_name("tryEmit(value:)")));
@property (readonly) NSArray<id> *replayCache __attribute__((swift_name("replayCache")));
@property (readonly) id<KSSAKotlinx_coroutines_coreStateFlow> subscriptionCount __attribute__((swift_name("subscriptionCount")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreStateFlow")))
@protocol KSSAKotlinx_coroutines_coreStateFlow <KSSAKotlinx_coroutines_coreSharedFlow>
@required
@property (readonly) id _Nullable value __attribute__((swift_name("value")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreMutableStateFlow")))
@protocol KSSAKotlinx_coroutines_coreMutableStateFlow <KSSAKotlinx_coroutines_coreStateFlow, KSSAKotlinx_coroutines_coreMutableSharedFlow>
@required
- (void)setValue:(id _Nullable)value __attribute__((swift_name("setValue(_:)")));
- (BOOL)compareAndSetExpect:(id _Nullable)expect update:(id _Nullable)update __attribute__((swift_name("compareAndSet(expect:update:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMMutableStateFlow")))
@interface KSSAAvMutableStateFlow<T> : KSSABase <KSSAKotlinx_coroutines_coreMutableStateFlow>
- (instancetype)initWithValue:(T _Nullable)value __attribute__((swift_name("init(value:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<KSSAKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
- (BOOL)compareAndSetExpect:(T _Nullable)expect update:(T _Nullable)update __attribute__((swift_name("compareAndSet(expect:update:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)emitValue:(T _Nullable)value completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("emit(value:completionHandler:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.ExperimentalCoroutinesApi
*/
- (void)resetReplayCache __attribute__((swift_name("resetReplayCache()")));
- (id<KSSAKotlinx_coroutines_coreJob>)subscribeOnChange:(void (^)(T _Nullable))onChange __attribute__((swift_name("subscribe(onChange:)")));
- (BOOL)tryEmitValue:(T _Nullable)value __attribute__((swift_name("tryEmit(value:)")));
@property (readonly) NSArray<id> *replayCache __attribute__((swift_name("replayCache")));
@property (readonly) id<KSSAKotlinx_coroutines_coreStateFlow> subscriptionCount __attribute__((swift_name("subscriptionCount")));
@property T _Nullable value __attribute__((swift_name("value")));
@end

__attribute__((swift_name("KMResult")))
@interface KSSAAvResult<__covariant T> : KSSABase
- (T _Nullable)getSuccessOrNull __attribute__((swift_name("getSuccessOrNull()")));
- (T _Nullable)guardBlock:(void (^)(KSSAKotlinThrowable *))block __attribute__((swift_name("guard(block:)")));
@property (readonly) BOOL isSuccess __attribute__((swift_name("isSuccess")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMResultFailure")))
@interface KSSAAvResultFailure<__covariant T> : KSSAAvResult<T>
- (instancetype)initWithFailure:(KSSAKotlinThrowable *)failure __attribute__((swift_name("init(failure:)"))) __attribute__((objc_designated_initializer));
- (KSSAAvResultFailure<T> *)doCopyFailure:(KSSAKotlinThrowable *)failure __attribute__((swift_name("doCopy(failure:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) KSSAKotlinThrowable *failure __attribute__((swift_name("failure")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMResultSuccess")))
@interface KSSAAvResultSuccess<__covariant T> : KSSAAvResult<T>
- (instancetype)initWithValue:(T _Nullable)value __attribute__((swift_name("init(value:)"))) __attribute__((objc_designated_initializer));
- (KSSAAvResultSuccess<T> *)doCopyValue:(T _Nullable)value __attribute__((swift_name("doCopy(value:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) T _Nullable value __attribute__((swift_name("value")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMSharedFlow")))
@interface KSSAAvSharedFlow<T> : KSSABase <KSSAKotlinx_coroutines_coreSharedFlow>

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<KSSAKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
- (id<KSSAKotlinx_coroutines_coreJob>)subscribeOnChange:(void (^)(T _Nullable))onChange __attribute__((swift_name("subscribe(onChange:)")));
@property (readonly) NSArray<id> *replayCache __attribute__((swift_name("replayCache")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMStateFlow")))
@interface KSSAAvStateFlow<T> : KSSABase <KSSAKotlinx_coroutines_coreStateFlow>

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<KSSAKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
- (id<KSSAKotlinx_coroutines_coreJob>)subscribeOnChange:(void (^)(T _Nullable))onChange __attribute__((swift_name("subscribe(onChange:)")));
@property (readonly) NSArray<id> *replayCache __attribute__((swift_name("replayCache")));
@property (readonly) T _Nullable value __attribute__((swift_name("value")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMDuration")))
@interface KSSAKMDuration : KSSABase
- (KSSAKMDuration *)doCopyValue:(int64_t)value __attribute__((swift_name("doCopy(value:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) int64_t inWholeMilliseconds __attribute__((swift_name("inWholeMilliseconds")));
@end

__attribute__((swift_name("AniviewTag")))
@protocol KSSAAniviewTag
@required
- (void)pause __attribute__((swift_name("pause()")));
- (void)preloadVideo __attribute__((swift_name("preloadVideo()")));
- (void)resume __attribute__((swift_name("resume()")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) id<KSSAKotlinx_coroutines_coreStateFlow> state __attribute__((swift_name("state")));
@property (readonly) id<KSSAKotlinx_coroutines_coreSharedFlow> videoEvent __attribute__((swift_name("videoEvent")));
@end

__attribute__((swift_name("KMAniviewTagState")))
@protocol KSSAKMAniviewTagState
@required
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMAniviewTagStateHaveNoVideo")))
@interface KSSAKMAniviewTagStateHaveNoVideo : KSSABase <KSSAKMAniviewTagState>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)haveNoVideo __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAKMAniviewTagStateHaveNoVideo *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KMAniviewTagStateHaveVideo")))
@interface KSSAKMAniviewTagStateHaveVideo : KSSABase <KSSAKMAniviewTagState>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)haveVideo __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAKMAniviewTagStateHaveVideo *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

@interface KSSAAdSetup (Extensions)
- (NSDictionary<NSString *, NSString *> *)aniviewMacrosCampaign:(id<KSSAAdCampaign>)campaign pageId:(NSString *)pageId __attribute__((swift_name("aniviewMacros(campaign:pageId:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PlatformLoggingKt")))
@interface KSSAPlatformLoggingKt : KSSABase
@property (class) BOOL forceAllLogs __attribute__((swift_name("forceAllLogs")));
@end

__attribute__((swift_name("KotlinSequence")))
@protocol KSSAKotlinSequence
@required
- (id<KSSAKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
@end

__attribute__((swift_name("KotlinThrowable")))
@interface KSSAKotlinThrowable : KSSABase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(KSSAKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(KSSAKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));

/**
 * @note annotations
 *   kotlin.experimental.ExperimentalNativeApi
*/
- (KSSAKotlinArray<NSString *> *)getStackTrace __attribute__((swift_name("getStackTrace()")));
- (void)printStackTrace __attribute__((swift_name("printStackTrace()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) KSSAKotlinThrowable * _Nullable cause __attribute__((swift_name("cause")));
@property (readonly) NSString * _Nullable message __attribute__((swift_name("message")));
- (NSError *)asError __attribute__((swift_name("asError()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinPair")))
@interface KSSAKotlinPair<__covariant A, __covariant B> : KSSABase
- (instancetype)initWithFirst:(A _Nullable)first second:(B _Nullable)second __attribute__((swift_name("init(first:second:)"))) __attribute__((objc_designated_initializer));
- (KSSAKotlinPair<A, B> *)doCopyFirst:(A _Nullable)first second:(B _Nullable)second __attribute__((swift_name("doCopy(first:second:)")));
- (BOOL)equalsOther:(id _Nullable)other __attribute__((swift_name("equals(other:)")));
- (int32_t)hashCode __attribute__((swift_name("hashCode()")));
- (NSString *)toString __attribute__((swift_name("toString()")));
@property (readonly) A _Nullable first __attribute__((swift_name("first")));
@property (readonly) B _Nullable second __attribute__((swift_name("second")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinEnumCompanion")))
@interface KSSAKotlinEnumCompanion : KSSABase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAKotlinEnumCompanion *shared __attribute__((swift_name("shared")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinArray")))
@interface KSSAKotlinArray<T> : KSSABase
+ (instancetype)arrayWithSize:(int32_t)size init:(T _Nullable (^)(KSSAInt *))init __attribute__((swift_name("init(size:init:)")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (T _Nullable)getIndex:(int32_t)index __attribute__((swift_name("get(index:)")));
- (id<KSSAKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
- (void)setIndex:(int32_t)index value:(T _Nullable)value __attribute__((swift_name("set(index:value:)")));
@property (readonly) int32_t size __attribute__((swift_name("size")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinUnit")))
@interface KSSAKotlinUnit : KSSABase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)unit __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) KSSAKotlinUnit *shared __attribute__((swift_name("shared")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("KotlinException")))
@interface KSSAKotlinException : KSSAKotlinThrowable
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(KSSAKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(KSSAKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("KotlinRuntimeException")))
@interface KSSAKotlinRuntimeException : KSSAKotlinException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(KSSAKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(KSSAKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("KotlinIllegalStateException")))
@interface KSSAKotlinIllegalStateException : KSSAKotlinRuntimeException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(KSSAKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(KSSAKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.4")
*/
__attribute__((swift_name("KotlinCancellationException")))
@interface KSSAKotlinCancellationException : KSSAKotlinIllegalStateException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(KSSAKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(KSSAKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.3")
*/
__attribute__((swift_name("KotlinCoroutineContext")))
@protocol KSSAKotlinCoroutineContext
@required
- (id _Nullable)foldInitial:(id _Nullable)initial operation:(id _Nullable (^)(id _Nullable, id<KSSAKotlinCoroutineContextElement>))operation __attribute__((swift_name("fold(initial:operation:)")));
- (id<KSSAKotlinCoroutineContextElement> _Nullable)getKey:(id<KSSAKotlinCoroutineContextKey>)key __attribute__((swift_name("get(key:)")));
- (id<KSSAKotlinCoroutineContext>)minusKeyKey:(id<KSSAKotlinCoroutineContextKey>)key __attribute__((swift_name("minusKey(key:)")));
- (id<KSSAKotlinCoroutineContext>)plusContext:(id<KSSAKotlinCoroutineContext>)context __attribute__((swift_name("plus(context:)")));
@end

__attribute__((swift_name("KotlinCoroutineContextElement")))
@protocol KSSAKotlinCoroutineContextElement <KSSAKotlinCoroutineContext>
@required
@property (readonly) id<KSSAKotlinCoroutineContextKey> key __attribute__((swift_name("key")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreJob")))
@protocol KSSAKotlinx_coroutines_coreJob <KSSAKotlinCoroutineContextElement>
@required
- (id<KSSAKotlinx_coroutines_coreChildHandle>)attachChildChild:(id<KSSAKotlinx_coroutines_coreChildJob>)child __attribute__((swift_name("attachChild(child:)")));
- (void)cancelCause:(KSSAKotlinCancellationException * _Nullable)cause __attribute__((swift_name("cancel(cause:)")));
- (KSSAKotlinCancellationException *)getCancellationException __attribute__((swift_name("getCancellationException()")));
- (id<KSSAKotlinx_coroutines_coreDisposableHandle>)invokeOnCompletionHandler:(void (^)(KSSAKotlinThrowable * _Nullable))handler __attribute__((swift_name("invokeOnCompletion(handler:)")));
- (id<KSSAKotlinx_coroutines_coreDisposableHandle>)invokeOnCompletionOnCancelling:(BOOL)onCancelling invokeImmediately:(BOOL)invokeImmediately handler:(void (^)(KSSAKotlinThrowable * _Nullable))handler __attribute__((swift_name("invokeOnCompletion(onCancelling:invokeImmediately:handler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)joinWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("join(completionHandler:)")));
- (id<KSSAKotlinx_coroutines_coreJob>)plusOther:(id<KSSAKotlinx_coroutines_coreJob>)other __attribute__((swift_name("plus(other:)"))) __attribute__((unavailable("Operator '+' on two Job objects is meaningless. Job is a coroutine context element and `+` is a set-sum operator for coroutine contexts. The job to the right of `+` just replaces the job the left of `+`.")));
- (BOOL)start __attribute__((swift_name("start()")));
@property (readonly) id<KSSAKotlinSequence> children __attribute__((swift_name("children")));
@property (readonly) BOOL isActive __attribute__((swift_name("isActive")));
@property (readonly) BOOL isCancelled __attribute__((swift_name("isCancelled")));
@property (readonly) BOOL isCompleted __attribute__((swift_name("isCompleted")));
@property (readonly) id<KSSAKotlinx_coroutines_coreSelectClause0> onJoin __attribute__((swift_name("onJoin")));

/**
 * @note annotations
 *   kotlinx.coroutines.ExperimentalCoroutinesApi
*/
@property (readonly) id<KSSAKotlinx_coroutines_coreJob> _Nullable parent __attribute__((swift_name("parent")));
@end

__attribute__((swift_name("KotlinIterator")))
@protocol KSSAKotlinIterator
@required
- (BOOL)hasNext __attribute__((swift_name("hasNext()")));
- (id _Nullable)next __attribute__((swift_name("next()")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreDisposableHandle")))
@protocol KSSAKotlinx_coroutines_coreDisposableHandle
@required
- (void)dispose __attribute__((swift_name("dispose()")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreChildHandle")))
@protocol KSSAKotlinx_coroutines_coreChildHandle <KSSAKotlinx_coroutines_coreDisposableHandle>
@required
- (BOOL)childCancelledCause:(KSSAKotlinThrowable *)cause __attribute__((swift_name("childCancelled(cause:)")));
@property (readonly) id<KSSAKotlinx_coroutines_coreJob> _Nullable parent __attribute__((swift_name("parent")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreChildJob")))
@protocol KSSAKotlinx_coroutines_coreChildJob <KSSAKotlinx_coroutines_coreJob>
@required
- (void)parentCancelledParentJob:(id<KSSAKotlinx_coroutines_coreParentJob>)parentJob __attribute__((swift_name("parentCancelled(parentJob:)")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreSelectClause")))
@protocol KSSAKotlinx_coroutines_coreSelectClause
@required
@property (readonly) id clauseObject __attribute__((swift_name("clauseObject")));
@property (readonly) KSSAKotlinUnit *(^(^ _Nullable onCancellationConstructor)(id<KSSAKotlinx_coroutines_coreSelectInstance>, id _Nullable, id _Nullable))(KSSAKotlinThrowable *) __attribute__((swift_name("onCancellationConstructor")));
@property (readonly) id _Nullable (^processResFunc)(id, id _Nullable, id _Nullable) __attribute__((swift_name("processResFunc")));
@property (readonly) void (^regFunc)(id, id<KSSAKotlinx_coroutines_coreSelectInstance>, id _Nullable) __attribute__((swift_name("regFunc")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreSelectClause0")))
@protocol KSSAKotlinx_coroutines_coreSelectClause0 <KSSAKotlinx_coroutines_coreSelectClause>
@required
@end

__attribute__((swift_name("KotlinCoroutineContextKey")))
@protocol KSSAKotlinCoroutineContextKey
@required
@end

__attribute__((swift_name("Kotlinx_coroutines_coreParentJob")))
@protocol KSSAKotlinx_coroutines_coreParentJob <KSSAKotlinx_coroutines_coreJob>
@required
- (KSSAKotlinCancellationException *)getChildJobCancellationCause __attribute__((swift_name("getChildJobCancellationCause()")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreSelectInstance")))
@protocol KSSAKotlinx_coroutines_coreSelectInstance
@required
- (void)disposeOnCompletionDisposableHandle:(id<KSSAKotlinx_coroutines_coreDisposableHandle>)disposableHandle __attribute__((swift_name("disposeOnCompletion(disposableHandle:)")));
- (void)selectInRegistrationPhaseInternalResult:(id _Nullable)internalResult __attribute__((swift_name("selectInRegistrationPhase(internalResult:)")));
- (BOOL)trySelectClauseObject:(id)clauseObject result:(id _Nullable)result __attribute__((swift_name("trySelect(clauseObject:result:)")));
@property (readonly) id<KSSAKotlinCoroutineContext> context __attribute__((swift_name("context")));
@end

#pragma pop_macro("_Nullable_result")
#pragma clang diagnostic pop
NS_ASSUME_NONNULL_END
