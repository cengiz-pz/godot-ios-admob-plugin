//
// © 2024-present https://github.com/cengiz-pz
//

#import "interstitial.h"

#import "os_ios.h"
#import "admob_plugin_implementation.h"


@implementation InterstitialAd

- (instancetype) initWithID:(NSString*) adId {
	if ((self = [super init])) {
		self.adId = adId;
	}
	return self;
}

- (void) load:(LoadAdRequest*) loadAdRequest {
	GADRequest* gadRequest = [GADRequest request];
	gadRequest.requestAgent = loadAdRequest.requestAgent;
	gadRequest.keywords = loadAdRequest.keywords;

	[GADInterstitialAd loadWithAdUnitID:loadAdRequest.adUnitId request:gadRequest completionHandler:^(GADInterstitialAd* ad, NSError* error) {
		if (error) {
			NSLog(@"failed to load InterstitialAd with error: %@", [error localizedDescription]);
			AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_FAILED_TO_LOAD_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
						[GAPConverter nsLoadErrorToGodotDictionary:error]);
		}
		else {
			self.interstitial = ad;
			self.interstitial.fullScreenContentDelegate = self;
		
			NSLog(@"InterstitialAd %@ loaded successfully", self.adId);
			AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_LOADED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
		}
	}];
}

- (void) show {
	if (self.interstitial) {
		[self.interstitial presentFromRootViewController:[AppDelegate viewController]];
	}
	else {
		NSLog(@"InterstitialAd show: ad not set");
	}
}

- (void) adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>) ad {
	NSLog(@"InterstitialAd adDidRecordImpression");
	AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_IMPRESSION_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

- (void) adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>) ad {
	NSLog(@"InterstitialAd adDidRecordClick");
	AdmobPlugin::get_singleton()->emit_signal(REWARDED_INTERSTITIAL_AD_CLICKED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

- (void) ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *) error {
	NSLog(@"InterstitialAd didFailToPresentFullScreenContentWithError");
	AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_FAILED_TO_SHOW_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
				[GAPConverter nsAdErrorToGodotDictionary:error]);
}

- (void) adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>) ad {
	NSLog(@"InterstitialAd adWillPresentFullScreenContent");
	AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_SHOWED_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
	
	if (AdFormatBase.pauseOnBackground) {
		NSLog(@"InterstitialAd pauseOnBackground is true");
		OS_IOS::get_singleton()->on_focus_out();
	}
	else {
		NSLog(@"InterstitialAd pauseOnBackground is false");
	}
}

- (void) adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>) ad {
	NSLog(@"InterstitialAd adDidDismissFullScreenContent");
	AdmobPlugin::get_singleton()->emit_signal(INTERSTITIAL_AD_DISMISSED_FULL_SCREEN_CONTENT_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
	OS_IOS::get_singleton()->on_focus_in();
}

@end
