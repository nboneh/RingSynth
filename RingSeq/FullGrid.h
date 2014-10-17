//
//  FullGrid.h
//  l
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullGrid : UIView<UIScrollViewDelegate>{
    NSMutableArray *layers;
    UIView *container;
    UIScrollView *mainScroll;
}

-(void)replay;
-(void)play;
@end
