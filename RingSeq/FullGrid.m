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
#import  "DetailViewController.h"
#import "ObjectAL.h"
@interface FullGrid()
-(void)stopAnimation;
-(void)startAnimation;
@end
@implementation FullGrid
@synthesize  isPlaying = _isPlaying;
@synthesize  numOfMeasures = _numOfMeasures;
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
        [self addSubview:container];
        [self setDelegate:self];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        
        [container addGestureRecognizer:singleFingerTap];
        UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleLongPress:)];
        
        [container addGestureRecognizer:longPress];
        _isPlaying = NO;

        
        
    }
    return self;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return container;
}

-(void)replay{
    [self stopTimers];
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self stopAnimation];
    if(_isPlaying){
        
        for(Layout * layer in layers){
            [layer stop];
        }
        [self stopAnimation];
        [self setZoomScale:1.0f animated:NO];
        [self scrollRectToVisible:frame animated:NO];
        [self playWithTempo:bpm];
    }else{
        [self setZoomScale:1.0f animated:YES];
        [self scrollRectToVisible:frame animated:YES];
    }
}


-(void)changeLayer:(int)index{
    if(index < 0){
        for(Layout * layer in layers){
            [layer setAlpha: 1.0f];
            layer.userInteractionEnabled =NO;
            [layer setMuted:NO];
        }
        currentLayer = nil;
    }
    else{
        for(Layout * layer in layers){
            [layer setAlpha: 0.2f];
            layer.userInteractionEnabled =NO;
            [layer setMuted:YES];
        }
        currentLayer = [layers objectAtIndex:index];
        [currentLayer setAlpha:1.0f];
        currentLayer.userInteractionEnabled = YES;
        [currentLayer setMuted:NO];
    }
    
}
-(void)addLayer{
    if(!layers)
        layers = [[NSMutableArray alloc] init];
    Layout * layer = [[Layout alloc] initWithStaff:staff andFrame:self.frame andNumOfMeasure:_numOfMeasures];
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

-(void)playWithTempo:(int)bpm_{
    
    bpm = bpm_;
    if([layers count] >0  && ![self isZooming] && ![self isDragging] && ![self isDecelerating]){
            [self setUserInteractionEnabled:NO];
        [self setZoomScale:1.0f animated:NO];

        Layout *layer = [layers objectAtIndex:0];
        Measure * measure =[layer findMeasureAtx:(self.contentOffset.x + layer.widthPerMeasure )];
        [self startAnimation];
        for(Layout * layer in layers){
            [layer playWithTempo:bpm fromMeasure:measure.num];
        }
        _isPlaying = YES;
        
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"musicStopped"
                                                            object: nil
                                                          userInfo: nil];
    }
}
-(void)stop{
    [self stopTimers];
    [self setUserInteractionEnabled:YES];
    
    
    for(Layout * layer in layers){
        [layer stop];
    }
    [self stopAnimation];
    _isPlaying = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName: @"musicStopped"
                                                        object: nil
                                                      userInfo: nil];
    

}
-(void)stopAnimation{
    [stopAnimTimer invalidate];
    stopAnimTimer = nil;
    if([layers count] >0){
        CGPoint offset = [self.layer.presentationLayer bounds].origin;
        [self.layer removeAllAnimations];
        self.contentOffset = CGPointMake(offset.x, 0);
    }
}

-(void)startAnimation{
    Layout *layer = [layers objectAtIndex:0];
    Measure * measure =[layer findMeasureAtx:(self.contentOffset.x + layer.widthPerMeasure )];
    
    float dist = self.frame.size.width/3;
    float offset = ((measure.frame.origin.x -self.contentOffset.x ) + dist);
    float widthPerMeasure = layer.widthPerMeasure;
    float delay = (offset/widthPerMeasure) *(60.0/bpm);
    float time = (60.0/(bpm)) * (_numOfMeasures -measure.num);
    
    stopPlayingTimer = [NSTimer scheduledTimerWithTimeInterval:time  target:self
                                                      selector:@selector(checkIfToStopPlaying)
                                                      userInfo:nil
                                                       repeats:NO];
    
    
    //The end goes beyond bound so we went to set a trigger to stop the animation when bound are out of reach
    float end = (_numOfMeasures ) * widthPerMeasure;
    
    float timeToStopAnim =  time -((60.0/(bpm)) * (dist/layer.widthPerMeasure));
    
    stopAnimTimer =[NSTimer scheduledTimerWithTimeInterval:timeToStopAnim
                                                    target:self
                                                  selector:@selector(stopAnimation)
                                                  userInfo:nil
                                                   repeats:NO];
    
    
    [UIView animateWithDuration:time delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        self.contentOffset = CGPointMake(end, 0);
    } completion:NULL];
    
}
-(void)checkIfToStopPlaying{
    if(![DetailViewController LOOPING]){
        [self stop];
        [self replay];
    } else{
        [self replay];
    }
    
}

-(void)changeToWidth:(int)width{
    CGRect frame = container.frame;
    frame.size.width = width;
    container.frame = frame;
    self.contentSize =CGSizeMake(width,self.frame.size.height);
    [staff increaseWidthOfLines:width];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if([DetailViewController CURRENT_EDIT_MODE] == nerase){
        CGPoint location = [recognizer locationInView:container];
        [self deleteNoteAtLocation:location];
    }
    
    
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:container];
    [self deleteNoteAtLocation:location];
    
}

-(void)deleteNoteAtLocation:(CGPoint)location{
    //Global delete mode for all layers instead of a specific one
    if(!currentLayer){
        for(Layout * layer in layers){
            Measure * measure = [layer findMeasureAtx:location.x];
            if(measure){
                NotesHolder *noteHolder = [measure findNoteHolderAtX:round(location.x - measure.frame.origin.x)];
                if(noteHolder){
                    if([noteHolder deleteNoteIfExistsAtY:location.y])
                        return;
                }
            }
        }
    }
}
-(void)silence{
    [self stopTimers];
    [[OALSimpleAudio sharedInstance] stopAllEffects];
    for(Layout * layer in layers){
        [layer setMuted:YES];
    }
}
-(void)stopTimers{
    [stopAnimTimer invalidate];
    stopAnimTimer = nil;
    [stopPlayingTimer invalidate];
    stopPlayingTimer = nil;
}
-(void)setNumOfMeasures:(int)numOfMeasures{
    _numOfMeasures = numOfMeasures;
    BOOL firstLayer = YES;
     for(Layout * layer in layers){
         [layer setNumOfMeasures:_numOfMeasures];
         if(firstLayer){
             [self changeToWidth:layer.frame.size.width];
             firstLayer = NO;
         }
             
     }
}

-(NSArray*)createSaveFile{
    NSMutableArray* preSaveFile = [[NSMutableArray alloc] init];
    for(int i = 0; i < [layers count]; i++){
        [preSaveFile addObject:[(Layout *)[layers objectAtIndex:i] createSaveFile] ];
    }
    return [[NSArray alloc] initWithArray:preSaveFile];
}

-(void)loadSaveFile:(NSArray *)saveFile{
    NSInteger size = saveFile.count;
    for(int i = 0; i < size; i++){
        [self addLayer];
        Layout *layer = [layers objectAtIndex:i];
        [layer loadSaveFile:[saveFile objectAtIndex:i]];
    }
    [self changeLayer:-1];
}
-(void) encodeWithBpm:(int)bpm_ andCallBack:(void (^)(NSData *))callBackBlock {
    int numOfMeasures = self.numOfMeasures;
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(layers.count == 0){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                callBackBlock(NULL);
            }];
            return;
        }
        
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *musicPaths  =[[NSBundle mainBundle] pathForResource:@"Electric Guitar" ofType:@"wav"];
        
         NSData * header = [[NSData alloc] initWithContentsOfFile:musicPaths];
     
    
        int sampleRate = 44100;
        int bytesPerSample = 2;
        float measuresPerSecond = 1/bpm_;
        int samplePerMeasure = sampleRate * measuresPerSecond;
        
        int lengthOfPiece =bytesPerSample *samplePerMeasure *numOfMeasures+44;
        
        short int*cdata = ( short int*)malloc( bytesPerSample *sampleRate*measuresPerSecond* numOfMeasures+44);
        [header getBytes:(  short int*)cdata range:NSMakeRange(0,44)];
        
        //Creating a copy of saveData we will decode it into out giant wave file composition
        //This allows the user to mess with the grid as it encodes the wave file
        NSArray *decodeData = [self createSaveFile];
        NSArray *decodeLayer = [decodeData objectAtIndex:0];
        for(int i = 0; i < 1; i++){
            NSMutableDictionary *decodeMeasure = [decodeLayer objectAtIndex:i];
            NSDictionary *notesHolder = [[decodeMeasure objectForKey:@"notesholders"] objectAtIndex:0];
            float volume = [[notesHolder objectForKey:@"volume"] floatValue];
            NSArray *notes = [notesHolder objectForKey:@"notes"];

            for(int j = 0; j <1; j++){
                NSDictionary *decodeNote=[notes objectAtIndex:j];
                Instrument * instrument = [[Assets INSTRUMENTS] objectAtIndex:[[decodeNote objectForKey:@"instrument"] intValue]];
                Accidental accidental = [[decodeNote objectForKey:@"accidental"] intValue];
                NotePlacement * notePlacement =[staff.notePlacements objectAtIndex:[[decodeNote objectForKey:@"noteplacement"] intValue]];
                NoteDescription* noteDescription = [[notePlacement noteDescs] objectAtIndex:accidental];
                NSData * noteData  = [instrument getDataNoteDescription:noteDescription andVolume:volume];
                int positionToInsert = j * samplePerMeasure +22;
                unsigned long noteLength = noteData.length/2;
                short int*noteCData = ( short int*)malloc( noteData.length);
                for(int k = 0; k < noteLength; k++){
                    cdata[positionToInsert] +=noteCData[k]/10;
                    positionToInsert++;
                }
                // free(noteCData);
                
            }
        }

       
        NSData *data = [NSData dataWithBytes:(const void *)cdata length:(lengthOfPiece)];
        
        [[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@/%@", path, @"Yo.wav"]
                                                contents:data
                                              attributes:nil];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            callBackBlock(data);
        }];

        free(cdata);
        /*AudioFileTypeID fileType = kAudioFileWAVEType;
        AudioStreamBasicDescription audioFormat;
        audioFormat.mSampleRate         = 44100.00;
        audioFormat.mFormatID           = kAudioFormatLinearPCM;
        audioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        audioFormat.mFramesPerPacket    = 1;
        audioFormat.mChannelsPerFrame   = 2;
        audioFormat.mBitsPerChannel     = 16;
        audioFormat.mBytesPerPacket     = 4;
        audioFormat.mBytesPerFrame      = 4;*/


        

    });
}


@end
