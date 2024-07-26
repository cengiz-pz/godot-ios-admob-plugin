//
// © 2024-present https://github.com/cengiz-pz
//

#import "banner.h"

#import "admob_plugin_implementation.h"


@implementation BannerAd

- (instancetype) initWithID:(NSString*) adId {
	if ((self = [super init])) {
		self.adId = adId;
		self.isLoaded = NO;
	}
	return self;
}

- (void) load:(LoadAdRequest*) loadAdRequest {
	// set ad position
	if ([loadAdRequest.adSize isEqualToString:@"TOP"]) {
		self.adPosition = AdPositionTop;
	} else if ([loadAdRequest.adSize isEqualToString:@"BOTTOM"]) {
		self.adPosition = AdPositionBottom;
	} else if ([loadAdRequest.adSize isEqualToString:@"LEFT"]) {
		self.adPosition = AdPositionLeft;
	} else if ([loadAdRequest.adSize isEqualToString:@"RIGHT"]) {
		self.adPosition = AdPositionLeft;
	} else if ([loadAdRequest.adSize isEqualToString:@"TOP_LEFT"]) {
		self.adPosition = AdPositionTopLeft;
	} else if ([loadAdRequest.adSize isEqualToString:@"TOP_RIGHT"]) {
		self.adPosition = AdPositionTopRight;
	} else if ([loadAdRequest.adSize isEqualToString:@"BOTTOM_LEFT"]) {
		self.adPosition = AdPositionBottomLeft;
	} else if ([loadAdRequest.adSize isEqualToString:@"BOTTOM_RIGHT"]) {
		self.adPosition = AdPositionBottomRight;
	} else if ([loadAdRequest.adSize isEqualToString:@"CENTER"]) {
		self.adPosition = AdPositionCenter;
	} else if ([loadAdRequest.adSize isEqualToString:@"CUSTOM"]) {
		self.adPosition = AdPositionCustom;
	} else {
		NSLog(@"AdmobPlugin banner load: ERROR: invalid ad position '%@'", loadAdRequest.adSize);
	}

	self.adSize = [GAPConverter nsStringToAdSize: loadAdRequest.adSize];
	
	self.bannerView = [[GADBannerView alloc] initWithAdSize:self.adSize];
	[self.bannerView setHidden:YES];
	[self addBanner:self.bannerView];

	self.bannerView.adUnitID = loadAdRequest.adUnitId;
	self.bannerView.rootViewController = self;
	self.bannerView.delegate = self;

	GADRequest* gadRequest = [GADRequest request];
	gadRequest.requestAgent = loadAdRequest.requestAgent;
	gadRequest.keywords = loadAdRequest.keywords;

	[self.bannerView loadRequest:gadRequest];
}

- (void) destroy {
	[self.bannerView setHidden:YES];
	[self.bannerView removeFromSuperview];
	self.bannerView = nil;
}

- (void) hide {
	[self.bannerView setHidden:YES];
}

- (void) show {
	[self.bannerView setHidden:NO];
}

- (int) getWidth {
	return self.bannerView.bounds.size.width;
}

- (int) getHeight {
	return self.bannerView.bounds.size.height;
}

- (int) getWidthInPixels {
	CGFloat scale = [[UIScreen mainScreen] scale];
	return (int)(self.bannerView.bounds.size.width * scale);
}

- (int) getHeightInPixels {
	CGFloat scale = [[UIScreen mainScreen] scale];
	return (int)(self.bannerView.bounds.size.height * scale);
}

- (void) addBanner:(GADBannerView *) bannerView {
	bannerView.translatesAutoresizingMaskIntoConstraints = NO;
	[AppDelegate.viewController.view addSubview:bannerView];
	[self updateBannerPosition:static_cast<AdPosition>(self.adPosition)];	// Center on screen
}

- (void) addBannerConstraint:(NSLayoutAttribute)attribute toView:(id)toView {
	[AppDelegate.viewController.view addConstraint:
				[NSLayoutConstraint constraintWithItem:self.bannerView attribute:attribute relatedBy:NSLayoutRelationEqual
							toItem:toView attribute:attribute multiplier:1 constant:0]];
}

- (void) addBannerConstraint:(NSLayoutAttribute)attribute toView:(id)toView attributeConstant:(CGFloat)constant {
	[AppDelegate.viewController.view addConstraint:
				[NSLayoutConstraint constraintWithItem:self.bannerView attribute:attribute relatedBy:NSLayoutRelationEqual
							toItem:toView attribute:attribute multiplier:1 constant:constant]];
}

- (void) updateBannerPosition:(AdPosition) adPosition {
	if (@available(iOS 11.0, *)) {
		NSLog(@"BannerAd updateBannerPosition: position=%lu", (unsigned long) adPosition);
		[AppDelegate.viewController.view removeConstraints:self.bannerView.constraints];

		switch (adPosition) {
			case AdPositionTop:
				[self addBannerConstraint:NSLayoutAttributeCenterX toView:AppDelegate.viewController.view];
				[self addBannerConstraint:NSLayoutAttributeTop toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				break;
				
			case AdPositionBottom:
				[self addBannerConstraint:NSLayoutAttributeCenterX toView:AppDelegate.viewController.view];
				[self addBannerConstraint:NSLayoutAttributeBottom toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				break;
				
			case AdPositionLeft:
				[self addBannerConstraint:NSLayoutAttributeLeft toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				[self addBannerConstraint:NSLayoutAttributeCenterY toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				break;
				
			case AdPositionRight:
				[self addBannerConstraint:NSLayoutAttributeRight toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				[self addBannerConstraint:NSLayoutAttributeCenterY toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				break;
				
			case AdPositionTopLeft:
				[self addBannerConstraint:NSLayoutAttributeLeft toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				[self addBannerConstraint:NSLayoutAttributeTop toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				break;
				
			case AdPositionTopRight:
				[self addBannerConstraint:NSLayoutAttributeRight toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				[self addBannerConstraint:NSLayoutAttributeTop toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				break;
				
			case AdPositionBottomLeft:
				[self addBannerConstraint:NSLayoutAttributeLeft toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				[self addBannerConstraint:NSLayoutAttributeBottom toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				break;
				
			case AdPositionBottomRight:
				[self addBannerConstraint:NSLayoutAttributeRight toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				[self addBannerConstraint:NSLayoutAttributeBottom toView:AppDelegate.viewController.view.safeAreaLayoutGuide];
				break;
				
			case AdPositionCenter:
				[self addBannerConstraint:NSLayoutAttributeCenterX toView:AppDelegate.viewController.view];
				[self addBannerConstraint:NSLayoutAttributeCenterY toView:AppDelegate.viewController.view];
				break;
				
			case AdPositionCustom:
				[self addBannerConstraint:NSLayoutAttributeLeft toView:AppDelegate.viewController.view.safeAreaLayoutGuide attributeConstant:0];
				[self addBannerConstraint:NSLayoutAttributeTop toView:AppDelegate.viewController.view.safeAreaLayoutGuide attributeConstant:0];
				break;
		}
	}
	else {
		NSLog(@"iOS 11.0 or later required.");
	}

	[AppDelegate.viewController.view layoutIfNeeded];
}

- (void) bannerViewDidReceiveAd:(GADBannerView*) bannerView {
	NSLog(@"BannerAd bannerViewDidReceiveAd %@", self.adId);
	if (self.isLoaded){
		AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_REFRESHED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
	}
	else {
		self.isLoaded = YES;
		AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_LOADED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
	}
}

- (void) bannerView: (GADBannerView *) bannerView didFailToReceiveAdWithError: (NSError *) error {
	NSLog(@"BannerAd bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
	
	AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_FAILED_TO_LOAD_SIGNAL, [GAPConverter nsStringToGodotString:self.adId],
				[GAPConverter nsLoadErrorToGodotDictionary:error]);
}

- (void) bannerViewDidRecordClick: (GADBannerView*) bannerView {
	NSLog(@"BannerAd bannerViewDidRecordClick");
	AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_CLICKED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

- (void) bannerViewDidRecordImpression: (GADBannerView*) bannerView {
	NSLog(@"BannerAd bannerViewDidRecordImpression");
	AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_IMPRESSION_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

- (void) bannerViewWillPresentScreen: (GADBannerView*) bannerView {
	NSLog(@"BannerAd bannerViewWillPresentScreen");
	AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_OPENED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

- (void) bannerViewDidDismissScreen: (GADBannerView*) bannerView {
	NSLog(@"BannerAd bannerViewDidDismissScreen");
	AdmobPlugin::get_singleton()->emit_signal(BANNER_AD_CLOSED_SIGNAL, [GAPConverter nsStringToGodotString:self.adId]);
}

@end
