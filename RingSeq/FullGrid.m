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
#define MAX_VALUE_SHORT 32768

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
    @synchronized(self){
    NSMutableArray* preSaveFile = [[NSMutableArray alloc] init];
    for(int i = 0; i < [layers count]; i++){
        [preSaveFile addObject:[(Layout *)[layers objectAtIndex:i] createSaveFile] ];
    }
    return [[NSArray alloc] initWithArray:preSaveFile];
    }
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
        
        
        //Lower over all volume of output to reduce number of clippings
        float volumeChange = 0.16667f;
        long sampleRate = 44100;
        int bytesPerSample = 2;
        int channels = 2;
        float measuresPerSecond = 1.0f/bpm_ * 60;
        int samplePerMeasure = (sampleRate * measuresPerSecond)  *bytesPerSample;
        
        //Extra two seconds after piece is over
        long lengthOfPiece =samplePerMeasure *numOfMeasures + 2*sampleRate;
        
        long totalLength = 44 + lengthOfPiece;
        
        Byte*cdata = ( Byte*)malloc( lengthOfPiece);
        for(int i = 0; i <lengthOfPiece; i++){
            cdata[i] = 0;
        }
        long byteRate = 16 * 11025.0 * channels/8;
        cdata[0] = 'R';
        cdata[1] = 'I';
        cdata[2] = 'F';
        cdata[3] = 'F';
        cdata[4] = (Byte) (totalLength & 0xff);
        cdata[5] = (Byte) ((totalLength >> 8) & 0xff);
        cdata[6] = (Byte) ((totalLength >> 16) & 0xff);
        cdata[7] = (Byte) ((totalLength >> 24) & 0xff);
        cdata[8] = 'W';
        cdata[9] = 'A';
        cdata[10] = 'V';
        cdata[11] = 'E';
        cdata[12] = 'f';  // 'fmt ' chunk
        cdata[13] = 'm';
        cdata[14] = 't';
        cdata[15] = ' ';
        cdata[16] = 16;  // 4 bytes: size of 'fmt ' chunk
        cdata[17] = 0;
        cdata[18] = 0;
        cdata[19] = 0;
        cdata[20] = 1;  // format = 1
        cdata[21] = 0;
        cdata[22] = channels;
        cdata[23] = 0;
        cdata[24] = (Byte) (sampleRate & 0xff);
        cdata[25] = (Byte) ((sampleRate >> 8) & 0xff);
        cdata[26] = (Byte) ((sampleRate >> 16) & 0xff);
        cdata[27] = (Byte) ((sampleRate >> 24) & 0xff);
        cdata[28] = (Byte) (byteRate & 0xff);
        cdata[29] = (Byte) ((byteRate >> 8) & 0xff);
        cdata[30] = (Byte) ((byteRate >> 16) & 0xff);
        cdata[31] = (Byte) ((byteRate >> 24) & 0xff);
        cdata[32] = (Byte) (2 * 8 / 8);  // block align
        cdata[33] = 0;
        cdata[34] = 16;  // bits per sample
        cdata[35] = 0;
        cdata[36] = 'd';
        cdata[37] = 'a';
        cdata[38] = 't';
        cdata[39] = 'a';
        cdata[40] = (Byte) (lengthOfPiece & 0xff);
        cdata[41] = (Byte) ((lengthOfPiece >> 8) & 0xff);
        cdata[42] = (Byte) ((lengthOfPiece >> 16) & 0xff);
        cdata[43] = (Byte) ((lengthOfPiece >> 24) & 0xff);
        
        short int *wavfile = (short int*)cdata;
        //Creating a copy of saveData we will decode it into out giant wave file composition
        //This allows the user to mess with the grid as it encodes the wave file
        NSArray *decodeData = [self createSaveFile];
        NSArray *decodeLayer = [decodeData objectAtIndex:0];
        for(int i = 0; i < decodeLayer.count; i++){
            NSMutableDictionary *decodeMeasure = [decodeLayer objectAtIndex:i];
            NSDictionary *notesHolder = [[decodeMeasure objectForKey:@"notesholders"] objectAtIndex:0];
            float volume = [[notesHolder objectForKey:@"volume"] floatValue];
            NSArray *notes = [notesHolder objectForKey:@"notes"];
            
            for(int j = 0; j <notes.count; j++){
                NSDictionary *decodeNote=[notes objectAtIndex:j];
                Instrument * instrument = [[Assets INSTRUMENTS] objectAtIndex:[[decodeNote objectForKey:@"instrument"] intValue]];
                Accidental accidental = [[decodeNote objectForKey:@"accidental"] intValue];
                NotePlacement * notePlacement =[staff.notePlacements objectAtIndex:[[decodeNote objectForKey:@"noteplacement"] intValue]];
                NoteDescription* noteDescription = [[notePlacement noteDescs] objectAtIndex:accidental];
                NSData * noteData  = [instrument getDataNoteDescription:noteDescription andVolume:volume];
                
                unsigned long noteLength = noteData.length/2;
                short int*noteCData = ( short int*)malloc( noteData.length);
                unsigned long positionInPiece = i * samplePerMeasure +22;;
                for(int k = 0; k < noteLength; k++){
                    if(positionInPiece >= (totalLength/2))
                        break;
                    wavfile[positionInPiece] =[ self clippingWith:round(noteCData[k] *volumeChange) and:wavfile[positionInPiece]];
                     positionInPiece++;
                }
                free(noteCData);
                
            }
        }
        
        
        NSData *data = [NSData dataWithBytes:(const void *)wavfile length:(lengthOfPiece)];
        
        [[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@/%@", path, @"Yo.wav"]
                                                contents:data
                                              attributes:nil];
        free(cdata);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            callBackBlock(data);
        }];
        
        
        
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

-(short int)clippingWith:(short int)a and:(short int)b{
    if(((short int)a) >= 0 && ((short int)b )>= 0 && ((short int)(a +b)) < 0 )
        return MAX_VALUE_SHORT;
    else if(((short int)a) < 0 && ((short int)b) < 0 && ((short int)(a+b)) >=0 )
        return -MAX_VALUE_SHORT;
    else
        return a +b;

}
@end
