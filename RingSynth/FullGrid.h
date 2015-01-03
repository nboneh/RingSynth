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

@interface FullGrid : UIScrollView<UIScrollViewDelegate>{
    NSMutableArray *layers;
    UIView *container;
    UIActionSheet *newColors;
    UISegmentedControl* instrumentsController;
    Staff* staff;
    Layout *currentLayer;
    int bpm;
    NSTimer *playTimer;
    int currentBeatPlaying;
    int currentTic;
    float timePerTic;
    float widthToAnimatePerTic;
    int endAnimateX;
}
@property(nonatomic) int numOfBeats;
@property BOOL isPlaying;
-(void)replay;
-(void)changeLayer:(int)index;
-(void)addLayer;
-(void)deleteLayerAt:(int)index;
-(void)playWithTempo:(int)bpm;
-(void)stop;
-(NSArray*)createSaveFile;
-(void)loadSaveFile:(NSArray *)saveFile;
-(void) encodeWithBpm:(int)bpm andName:(NSString *)name andCompletionBlock:(void (^)( BOOL)) block;
-(void)changeInstrumentTo:(Instrument *) instrument forLayer:(int)layerIndex;
-(void)playBeat:(NSTimer *)target;
@end
