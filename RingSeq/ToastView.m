//
//  ToastView.m
//  World Magnetic Model
//
//  Created by Nir Boneh on 6/17/14.
//  Copyright (c) 2014 NOAA. All rights reserved.
//
#import "ToastView.h"

@implementation ToastView

@synthesize textLabel;

float const ToastHeight = 50.0f;
float const ToastGap = 12.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = NO;
    }
    return self;
}

-(void)setTextLabel:(UILabel *)theTextLabel
{
    textLabel = theTextLabel;
    [self addSubview:theTextLabel];
}

+ (void)showToastWithText:(NSString *)text withDuaration:(float)duration;
{
    
    //Count toast views are already showing on parent. Made to show several toasts one above another
    
    UIView * parentView = [[[UIApplication sharedApplication] delegate] window];
        
    CGRect parentFrame = parentView.frame;
    
    float yOrigin = parentFrame.size.height - (70.0 + ToastHeight );
    
    CGRect selfFrame = CGRectMake(parentFrame.origin.x + 20.0, yOrigin, parentFrame.size.width - 40.0, ToastHeight);
    ToastView *toast = [[ToastView alloc] initWithFrame:selfFrame];
    
    toast.backgroundColor = [UIColor darkGrayColor];
    toast.alpha = 0.0f;
    toast.layer.cornerRadius = 4.0;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, toast.frame.size.width - 10.0, toast.frame.size.height - 10.0)];
    
    
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.numberOfLines = 2;
    textLabel.font = [UIFont systemFontOfSize:13.0];
    
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    textLabel.text = text;
    
    [toast setTextLabel:textLabel];
    
    [parentView addSubview:toast];
    
    [UIView animateWithDuration:0.4 animations:^{
        toast.alpha = 0.9f;
        toast.textLabel.alpha = 0.9f;
    }completion:^(BOOL finished) {
        if(finished){
            
        }
    }];
    
    [toast performSelector:@selector(hideSelf) withObject:nil afterDelay:duration];
    
}
- (void)hideSelf
{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
        self.textLabel.alpha = 0.0;
    }completion:^(BOOL finished) {
        if(finished){
            [self removeFromSuperview];
        }
    }];
}

@end
