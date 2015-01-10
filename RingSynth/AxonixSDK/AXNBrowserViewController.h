//
//  AXNBrowserViewController.h
//  Axonix iOS SDK
//
//  Copyright 2011 - 2014 Axonix. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AXNBrowserStyle) {
	AXNBrowserToolbarStyle, // Toolbar with back/forward/reload buttons, no navigation bar
	AXNBrowserNavigationStyle, // No toolbar, Navigation bar with "Done" button + self.title (Default: Advertisement)
	AXNBrowserWidgetStyle, // No toolbar, No Navigation bar, Single "X" in top left corner
	AXNBrowserFullStyle, // Contains toolbar and navigation bar. 
};

@protocol AXNBrowserViewControllerDelegate;
@interface AXNBrowserViewController : UIViewController<UIWebViewDelegate,UIActionSheetDelegate> {
@private
	AXNBrowserStyle _browserStyle;
	NSURLRequest* _urlRequest;
	NSString* _embeddedHTML;
	UIToolbar* _toolbar;
	UIBarButtonItem* backItem;
	UIBarButtonItem* forwardItem;
	UIActionSheet* _actionSheet;
	BOOL _preloadedRequest;
	BOOL _preloadingRequest;
	BOOL _isVisible;
}

- (id)initWithURLRequest:(NSURLRequest*)urlRequest; // browserStyle:MCBrowserToolbarStyle
- (id)initWithURLRequest:(NSURLRequest*)urlRequest browserStyle:(AXNBrowserStyle)browserStyle;

- (id)initWithEmbeddedHTML:(NSString*)embeddedHTML baseURL:(NSURL*)baseURL; // browserStyle:MCBrowserWidgetStyle
- (id)initWithEmbeddedHTML:(NSString*)embeddedHTML baseURL:(NSURL*)baseURL browserStyle:(AXNBrowserStyle)browserStyle;

- (void)stopLoading;
- (void)preloadRequest;

// Status bar state
@property(nonatomic,assign) BOOL statusBarHidden;

@property(nonatomic,readonly) UIWebView* webView;
@property(nonatomic,weak) id<AXNBrowserViewControllerDelegate> delegate;
@property(nonatomic,assign) BOOL autoDismissOnResignActive; // Default is false.  If set to true, the browser view will automatically dismiss when the application recieves UIApplicationWillResignActiveNotification.
@end

@protocol AXNBrowserViewControllerDelegate<NSObject>
@optional
- (void)browserViewControllerFinishedPreloading:(AXNBrowserViewController*)browserViewController;
- (void)browserViewController:(AXNBrowserViewController*)browserViewController failedToPreloadWithError:(NSError*)error;
@end


extern NSString* const AXNBrowserWillShowNotification;
extern NSString* const AXNBrowserDidHideNotification;

/**
 * Deprecated notification definitions.
 * Change your application to use MCBrowserWillShowNotification and MCBrowserDidHideNotification
 * The notification definitions will be removed in a subsequent release.
 */
#define kNotificationAxonixBrowserOpen AXNBrowserWillShowNotification
#define kNotificationAxonixBrowserClose AXNBrowserDidHideNotification

#import "MCBrowserViewController.h"