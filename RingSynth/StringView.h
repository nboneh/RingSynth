//
//  StringView.h
//  RingSynth
//
//  Created by Nir Boneh on 11/1/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StringViewDelegate
@optional
-(void)stringActivated;
@end

@interface StringView : UIImageView{
    CGPoint originalCenter;
}

@property(nonatomic,assign)id delegate;
-(id)initWithX:(int)x andDelegate:(id)delegate;
-(void)bounceBack;
@end
