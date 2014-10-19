//
//  FullGrid.m
//  RingSeq
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "FullGrid.h"
#import "Assets.h"
#import "NotesHolder.h"

static const int NUM_OF_MEASURES = 50;
@implementation FullGrid
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        int volumeMeterSpace = frame.size.height/6;
        int titleSpace = frame.size.height/8;
        container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        staff = [[Staff alloc] initWithFrame:CGRectMake(0,titleSpace, frame.size.width, self.frame.size.height -titleSpace - volumeMeterSpace)];
        [container addSubview:staff];
        self.scrollEnabled = YES;
        //mainScroll.userInteractionEnabled = YES;
        self.maximumZoomScale = 6.5f;
        self.delegate = self;
        [self addSubview:container];
        [self setDelegate:self];
        container.userInteractionEnabled = NO;
        /*   [[NSNotificationCenter defaultCenter] addObserver: self
         selector: @selector(orientationDidChange:)
         name: UIApplicationDidChangeStatusBarOrientationNotification
         object: nil];*/
        
    }
    return self;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return container;
}


-(void)replay{
    [self stop];
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self setZoomScale:1.0f animated:YES];
    [self scrollRectToVisible:frame animated:YES];
}

-(void)handleRotation{
    //mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.height, mainScroll.contentSize.width);
    /*CGRect frame = mainScroll.frame;
     frame.size.width = mainScroll.frame.size.height;
     frame.size.height = frame.size.width;
     mainScroll.frame = frame;*/
}

-(void)changeLayer:(int)index{
    if(index < 0){
        for(Layout * layer in layers){
            [layer setAlpha: 1.0f];
        }
        container.userInteractionEnabled = NO;
    }
    else{
        container.userInteractionEnabled = YES;
        for(Layout * layer in layers){
            [layer setAlpha: 0.2f];
            layer.userInteractionEnabled =NO;
        }
        Layout *currentLayer = [layers objectAtIndex:index];
        [currentLayer setAlpha:1.0f];
        currentLayer.userInteractionEnabled = YES;
    }
    
}
-(void)addLayer{
    if(!layers)
        layers = [[NSMutableArray alloc] init];
    Layout * layer = [[Layout alloc] initWithStaff:staff andFrame:self.frame andNumOfMeasure:NUM_OF_MEASURES];
    [layers addObject:layer];
    [container addSubview:layer];
    if([layers count] == 1){
        [self changeToWidth:layer.frame.size.width];
    }
    [self changeLayer:((int)[layers count] -1)];
    
}
-(void)deleteLayerAt:(int)index{
    Layout * layer=  [layers objectAtIndex:index];
    [layer removeFromSuperview];
    [layers removeObject:layer];
    if([layers count] == 0){
      [self changeToWidth:self.frame.size.width];
        
    }
    
    [Assets playEraseSound];
}

-(void)playWithTempo:(int)bpm{
    if([layers count] >0){
        Layout *layer = [layers objectAtIndex:0];
        float widthPerMeasure = layer.widthPerMeasure;
        [self changeToWidth:layer.frame.size.width + self.frame.size.width];
        float time = (60.0/(bpm)) * NUM_OF_MEASURES;
        float end = NUM_OF_MEASURES * widthPerMeasure;
        [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.contentOffset = CGPointMake(end, 0);
        } completion:^(BOOL success){[self stop];}];
        
    }
}
-(void)stop{
    if([layers count] >0){
        [self.layer removeAllAnimations];
        Layout *layer = [layers objectAtIndex:0];
        [self changeToWidth:layer.frame.size.width];
    }
}

-(void)changeToWidth:(int)width{
    CGRect frame = container.frame;
    frame.size.width = width;
    container.frame = frame;
    self.contentSize =CGSizeMake(width,self.frame.size.height);
    [staff increaseWidthOfLines:width];
}

@end
