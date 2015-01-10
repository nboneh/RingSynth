//
//  MCBrowserViewController.h
//  Axonix iOS SDK
//
//  Copyright 2011 - 2014 Axonix. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MCBrowserStyle) {
	MCBrowserToolbarStyle, // Toolbar with back/forward/reload buttons, no navigation bar
	MCBrowserNavigationStyle, // No toolbar, Navigation bar with "Done" button + self.title (Default: Advertisement)
	MCBrowserWidgetStyle, // No toolbar, No Navigation bar, Single "X" in top left corner
	MCBrowserFullStyle, // Contains toolbar and navigation bar. 
};

@protocol MCBrowserViewControllerDelegate;
__deprecated_msg("Use AXNBrowserViewController instead. You'll need to import the AXNBrowserViewController.h header instead of MCBrowserViewController.h")
@interface MCBrowserViewController : UIViewController<UIWebViewDelegate,UIActionSheetDelegate> {
@private
	MCBrowserStyle _browserStyle;
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
- (id)initWithURLRequest:(NSURLRequest*)urlRequest browserStyle:(MCBrowserStyle)browserStyle;

- (id)initWithEmbeddedHTML:(NSString*)embeddedHTML baseURL:(NSURL*)baseURL; // browserStyle:MCBrowserWidgetStyle
- (id)initWithEmbeddedHTML:(NSString*)embeddedHTML baseURL:(NSURL*)baseURL browserStyle:(MCBrowserStyle)browserStyle;

- (void)stopLoading;
- (void)preloadRequest;

// Status bar state
@property(nonatomic,assign) BOOL statusBarHidden;

@property(nonatomic,readonly) UIWebView* webView;
@property(nonatomic,weak) id<MCBrowserViewControllerDelegate> delegate;
@property(nonatomic,assign) BOOL autoDismissOnResignActive; // Default is false.  If set to true, the browser view will automatically dismiss when the application recieves UIApplicationWillResignActiveNotification.
@end

@protocol MCBrowserViewControllerDelegate<NSObject>
@optional
- (void)browserViewControllerFinishedPreloading:(MCBrowserViewController*)browserViewController;
- (void)browserViewController:(MCBrowserViewController*)browserViewController failedToPreloadWithError:(NSError*)error;
@end


extern NSString* const MCBrowserWillShowNotification;
extern NSString* const MCBrowserDidHideNotification;

/**
 * Deprecated notification definitions.
 * Change your application to use MCBrowserWillShowNotification and MCBrowserDidHideNotification
 * The notification definitions will be removed in a subsequent release.
 */
#define kNotificationMobclixBrowserOpen MCBrowserWillShowNotification
#define kNotificationMobclixBrowserClose MCBrowserDidHideNotification