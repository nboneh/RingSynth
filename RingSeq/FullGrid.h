//
//  FullGrid.h
//  l
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Layout.h"
#import "Instrument.h"
#import "TAPPCAudioConverter.h"
@protocol FullGridDelegate
@optional
-(void)finishedEncoding:(BOOL)success;
@end

@interface FullGrid : UIScrollView<UIScrollViewDelegate, TPAACAudioConverterDelegate>{
    NSMutableArray *layers;
    UIView *container;
    UIActionSheet *newColors;
    UISegmentedControl* instrumentsController;
    Staff* staff;
    Layout *currentLayer;
    int bpm;
    NSTimer *stopAnimTimer;
    NSTimer *stopPlayingTimer;
    NSString *tempFilePath;
    TPAACAudioConverter * audioConverter;
    
}
@property(nonatomic,assign)id delegateForEncode;
@property(nonatomic) int numOfMeasures;
@property BOOL isPlaying;
-(void)replay;
-(void)changeLayer:(int)index;
-(void)addLayer;
-(void)deleteLayerAt:(int)index;
-(void)playWithTempo:(int)bpm;
-(void)stop;
-(void)silence;
-(NSArray*)createSaveFile;
-(void)loadSaveFile:(NSArray *)saveFile;
-(void) encodeWithBpm:(int)bpm andName:(NSString *)name andDelegate:(id)delegate ;
@end
