//
//  MobclixAds.h
//  Axonix iOS SDK
//
//  Copyright 2011 - 2014 Axonix. All rights reserved.
//

typedef NS_ENUM(NSInteger, MCFeedbackRating) {
	MCFeedbackRatingUnknown = 0,
	MCFeedbackRatingPoor,
	MCFeedbackRatingFair,
	MCFeedbackRatingGood,
	MCFeedbackRatingVeryGood,
	MCFeedbackRatingExcellent
};

typedef struct {
	MCFeedbackRating categoryA;
	MCFeedbackRating categoryB;
	MCFeedbackRating categoryC;
	MCFeedbackRating categoryD;
	MCFeedbackRating categoryE;
} MCFeedbackRatings;

@protocol MobclixFeedbackDelegate;

__deprecated_msg("Feedback is no longer available in Axonix.")
@interface MobclixFeedback : NSObject {

}

- (void)sendComment:(NSString*)comment;
- (void)sendRatings:(MCFeedbackRatings)ratings;

@property(nonatomic,weak) id<MobclixFeedbackDelegate> delegate;
@property(nonatomic,assign,readonly,getter=isSendingComment) BOOL sendingComment;
@property(nonatomic,assign,readonly,getter=isSendingRatings) BOOL sendingRatings;

#pragma mark -
#pragma mark Deprecated methods

// These methods have been deprecated as of Mobclix SDK 4.2 and will be removed in a future version.
+ (void)sendComment:(NSString*)comment;
+ (void)sendRatings:(MCFeedbackRatings)ratings;

@end

#pragma mark -

@protocol MobclixFeedbackDelegate<NSObject>
@optional

// Comment Delgates
- (void)mobclixFeedbackSentComment:(MobclixFeedback*)feedback;
- (void)mobclixFeedbackFailedToSendComment:(MobclixFeedback*)feedback withError:(NSError*)error;

// Feedback Delegates
- (void)mobclixFeedbackSentRatings:(MobclixFeedback*)feedback;
- (void)mobclixFeedbackFailedToSendRatings:(MobclixFeedback*)feedback withError:(NSError*)error;

@end