//
//  StringView.m
//  RingSynth
//
//  Created by Nir Boneh on 11/1/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "StringView.h"

@implementation StringView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(id)initWithX:(int)x andDelegate:(id)delegate{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
    self = [super initWithImage:[UIImage imageNamed:@"string-ipad"]];
    } else {
         self = [super initWithImage:[UIImage imageNamed:@"string"]];
    }
    if(self){
        _delegate = delegate;
        [self setUserInteractionEnabled:YES];
        UIPanGestureRecognizer *drag =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(drag:)];
        [self addGestureRecognizer:drag];
        CGRect frame = self.frame;
        frame.origin.y = -frame.size.height/2;
        frame.origin.x  = x;
        self.frame = frame;
    }
    return self;
}

- (void)drag:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        originalCenter = gesture.view.center;
    }
    
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translate = [gesture translationInView:gesture.view.superview];
        int newCenterY = (originalCenter.y + translate.y);
        if(newCenterY < (self.frame.size.height/2) ){
            gesture.view.center = CGPointMake(originalCenter.x ,newCenterY);
        }
        else {
            [self stringActivated];
            [self bounceBack];
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateFailed ||
             gesture.state == UIGestureRecognizerStateCancelled)
    {
        [self bounceBack];
    }
}

-(void)bounceBack{
    [UIView animateWithDuration:1.0f
                          delay:0
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            //Animations
                            self.center = originalCenter;
                        }
                     completion:^(BOOL finished) {
                         //Completion Block
                     }];
    
}

-(void)stringActivated{
    [_delegate stringActivated];
}
@end
