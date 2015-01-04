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
#import "MusicViewController.h"
#import "ObjectAL.h"
#import "Drums.h"
#include <limits.h>

@interface FullGrid()

@end
@implementation FullGrid
@synthesize  isPlaying = _isPlaying;

@synthesize  numOfBeats = _numOfBeats;
const int TICS_PER_BEAT  =12;
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
        
        UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleLongPress:)];
        
        [container addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *tapPress =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleTap:)];
        
        [container addGestureRecognizer:tapPress];
        _isPlaying = NO;
        currentBeatPlaying = -1;
        
    }
    return self;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return container;
}

-(void)replay{
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    for(Layout * layer in layers){
        [layer stopBeat];
    }
    
    
    if(_isPlaying){
        [self setZoomScale:1.0f animated:NO];
        [self scrollRectToVisible:frame animated:NO];
        if([layers count] == 0){
            [self stop];
            return;
        }
        Layout * layer =  [layers objectAtIndex:0];
        currentBeatPlaying =[layer findBeatIndexAtx:(self.contentOffset.x + layer.widthPerBeat  )] -1;
        currentTic = TICS_PER_BEAT -1;
    }else{
        [self setZoomScale:1.0f animated:YES];
        [self scrollRectToVisible:frame animated:YES];
    }
}


-(void)changeLayer:(int)index{
    if(index < 0){
        for(Layout * layer in layers){
            [layer setState:all_mode];
        }
        currentLayer = nil;
    }
    else{
        for(Layout * layer in layers){
            [layer setState: not_active];
            
        }
        currentLayer = [layers objectAtIndex:index];
        [currentLayer setState:active];
        
        //Bringing subview in the front of all other layers but not in front of all the notes
        [currentLayer removeFromSuperview];
        [container insertSubview:currentLayer atIndex:[layers count]];
    }
    
}
-(void)addLayer{
    if(!layers)
        layers = [[NSMutableArray alloc] init];
    Layout * layer = [[Layout alloc] initWithStaff:staff andFrame:self.frame andNumOfBeat:_numOfBeats];
    [layers addObject:layer];
    [container addSubview:layer];
    if([layers count] == 1){
        [self changeToWidth:layer.frame.size.width];
    }
    [self changeLayer:((int)[layers count] -1)];
    
}
-(void)deleteLayerAt:(int)index{
    Layout * layer=  [layers objectAtIndex:index];
    [layer remove];
    [layers removeObject:layer];
    if([layers count] == 0){
        [self changeToWidth:self.frame.size.width];
        
    }
    
    [Assets playEraseSound];
}

-(void)playWithTempo:(int)bpm_{
    
    bpm = bpm_;
    if([layers count] >0  && ![self isZooming] && ![self isDragging] && ![self isDecelerating]){
        [playTimer invalidate];
        playTimer = nil;
        [self setUserInteractionEnabled:NO];
        [self setZoomScale:1.0f animated:NO];
        
        Layout *layer = [layers objectAtIndex:0];
        currentBeatPlaying = [layer findBeatIndexAtx:(self.contentOffset.x + layer.widthPerBeat  )] -1;
        if(currentBeatPlaying < -1){
            [self stop];
            return;
        }
        currentTic = TICS_PER_BEAT -1;
        
        if(playTimer)
            [self stop];
        
        timePerTic= ((60.0f/bpm)/(TICS_PER_BEAT));
            _isPlaying = YES;
        
        
        widthToAnimatePerTic = layer.widthPerBeat/(TICS_PER_BEAT -1);
        playTimer =[NSTimer scheduledTimerWithTimeInterval:timePerTic                                                    target:self
                                                  selector:@selector(playBeat:)
                                                  userInfo:nil
                                                   repeats:YES];
        [playTimer fire];
        
        
        
        endAnimateX =container.frame.size.width- self.frame.size.width;
        
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"musicStopped"
                                                            object: nil
                                                          userInfo: nil];
    }
}

-(void)playBeat:(NSTimer *)target{
    currentTic++;
    if(currentTic >= TICS_PER_BEAT){
        currentTic = 0;
        currentBeatPlaying++;
    }
    
    if(currentBeatPlaying >= _numOfBeats){
        [self checkIfToStopPlaying];
        return;
    }

   
    
    BOOL animate = NO;
    int midX =  self.contentOffset.x + self.frame.size.width/2;
    Layout * layer= [layers objectAtIndex:0];
    int currentXPlaying =  [layer findBeatAtIndex:currentBeatPlaying].frame.origin.x + (layer.widthPerBeat * currentTic)/TICS_PER_BEAT;
    if(midX <= currentXPlaying)
        animate = YES;

    if(animate){
        int newX = self.contentOffset.x + widthToAnimatePerTic;
        if(newX > endAnimateX)
            newX = endAnimateX;
        [self.layer removeAllAnimations];
        [UIView animateWithDuration:timePerTic delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.contentOffset = CGPointMake(newX, 0);
        } completion:NULL];
    }
    
    
    for(Layout * layer in layers){
        [layer playWithTempo:bpm beat:currentBeatPlaying tic:currentTic andTicDivision:TICS_PER_BEAT];
    }
    
}

-(void)stop{
    [self stopWithoutSilence];
    [self silence];
}

-(void)stopWithoutSilence{
    [playTimer invalidate];
    playTimer = nil;
    [self setUserInteractionEnabled:YES];
    _isPlaying = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"musicStopped"
                                                        object: nil
                                                      userInfo: nil];
}

-(void)silence{
    ALChannelSource * mainChannel = [[OALSimpleAudio sharedInstance] channel];
    for(Layout * layer in layers){
        [layer stopBeat];
        [OALSimpleAudio sharedInstance].channel = layer.channel;
        [[OALSimpleAudio sharedInstance] stopAllEffects];
        
    }
    [OALSimpleAudio sharedInstance].channel = mainChannel;
}


-(void)checkIfToStopPlaying{
    if(![MusicViewController LOOPING])
        [self stopWithoutSilence];
    [self replay];
    
}

-(void)changeToWidth:(int)width{
    [self setZoomScale:1.0f animated:NO];
    CGRect frame = container.frame;
    frame.size.width = width;
    container.frame = frame;
    self.contentSize =CGSizeMake(width,self.frame.size.height);
    [staff increaseWidthOfLines:width];
}



- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:container];
    [self deleteNoteAtLocation:location];
}

-(void)handleTap:(UITapGestureRecognizer *) recognizer{
    CGPoint location = [recognizer locationInView:container];
    [self insertNoteAtLocation:location];
}

-(void)deleteNoteAtLocation:(CGPoint)location{
    if(!currentLayer){
        for(Layout * layer in layers){
            NotesHolder * notesholder = [self findNoteHolderAtLocation:location andLayer:layer];
            if(notesholder)
                if([notesholder deleteNoteIfExistsAtY:location.y])
                    return;
        }
    } else {
        NotesHolder *noteHolder = [self findNoteHolderAtLocation:location andLayer:currentLayer];
        if(noteHolder){
            [noteHolder deleteNoteIfExistsAtY:location.y];
        }
    }
}

-(void)insertNoteAtLocation:(CGPoint)location{
    if(currentLayer){
        NotesHolder *noteHolder = [self findNoteHolderAtLocation:location andLayer:currentLayer];
        if(noteHolder){
            [noteHolder placeNoteAtY:location.y];
        }
    }
    
}

-(NotesHolder *)findNoteHolderAtLocation:(CGPoint)location andLayer:(Layout *)layer{
    Beat * beat = [layer findBeatAtx:location.x];
    if(beat){
        NotesHolder *noteHolder = [beat findNoteHolderAtX:round(location.x - beat.frame.origin.x)];
        return noteHolder;
    }
    else{
        return nil;
    }
}

-(void)setNumOfBeats:(int)numOfBeats{
    _numOfBeats = numOfBeats;
    BOOL firstLayer = YES;
    for(Layout * layer in layers){
        [layer setNumOfBeats:_numOfBeats];
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
-(void) encodeWithBpm:(int)bpm_ andName:(NSString *)name andCompletionBlock:(void (^)( BOOL)) block {
    if(layers.count == 0 ){
        block(NO);
        return;
    }
    
    int numOfBeats = self.numOfBeats;
    
    //Creating a copy of saveData we will decode it into out giant wave file composition
    //This allows the user to mess with the grid as it encodes the wave file
    NSArray *decodeData = [self createSaveFile];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        long sampleRate = 44100;
        int bytesPerSample = 2;
        int channels = 2;
        float beatsPerSecond = 1.0f/bpm_ * 60;
        int samplePerBeat = (sampleRate * beatsPerSecond)  *bytesPerSample;
        
        //Extra two seconds after piece is over
        long lengthOfPiece =(samplePerBeat *numOfBeats * bytesPerSample + 2*sampleRate);
        
        long totalLength = 44 + lengthOfPiece;
        
        Byte*headerfile = ( Byte*)malloc( 44);
        long byteRate = 16 * 11025.0 * channels/8;
        headerfile[0] = 'R';
        headerfile[1] = 'I';
        headerfile[2] = 'F';
        headerfile[3] = 'F';
        headerfile[4] = (Byte) (totalLength & 0xff);
        headerfile[5] = (Byte) ((totalLength >> 8) & 0xff);
        headerfile[6] = (Byte) ((totalLength >> 16) & 0xff);
        headerfile[7] = (Byte) ((totalLength >> 24) & 0xff);
        headerfile[8] = 'W';
        headerfile[9] = 'A';
        headerfile[10] = 'V';
        headerfile[11] = 'E';
        headerfile[12] = 'f';  // 'fmt ' chunk
        headerfile[13] = 'm';
        headerfile[14] = 't';
        headerfile[15] = ' ';
        headerfile[16] = 16;  // 4 bytes: size of 'fmt ' chunk
        headerfile[17] = 0;
        headerfile[18] = 0;
        headerfile[19] = 0;
        headerfile[20] = 1;  // format = 1
        headerfile[21] = 0;
        headerfile[22] = channels;
        headerfile[23] = 0;
        headerfile[24] = (Byte) (sampleRate & 0xff);
        headerfile[25] = (Byte) ((sampleRate >> 8) & 0xff);
        headerfile[26] = (Byte) ((sampleRate >> 16) & 0xff);
        headerfile[27] = (Byte) ((sampleRate >> 24) & 0xff);
        headerfile[28] = (Byte) (byteRate & 0xff);
        headerfile[29] = (Byte) ((byteRate >> 8) & 0xff);
        headerfile[30] = (Byte) ((byteRate >> 16) & 0xff);
        headerfile[31] = (Byte) ((byteRate >> 24) & 0xff);
        headerfile[32] = (Byte) (2 * 8 / 8);  // block align
        headerfile[33] = 0;
        headerfile[34] = 16;  // bits per sample
        headerfile[35] = 0;
        headerfile[36] = 'd';
        headerfile[37] = 'a';
        headerfile[38] = 't';
        headerfile[39] = 'a';
        headerfile[40] = (Byte) (lengthOfPiece & 0xff);
        headerfile[41] = (Byte) ((lengthOfPiece >> 8) & 0xff);
        headerfile[42] = (Byte) ((lengthOfPiece >> 16) & 0xff);
        headerfile[43] = (Byte) ((lengthOfPiece >> 24) & 0xff);
        
        
        //We are going to create a list of int arrays for each layer then we are going to add those all togther and the finnally analyze the data
        //to turn it to a short int array
        //So much nested loops gah
        int **uncompDataPointers = malloc(sizeof(int*)*decodeData.count);
        for(int i = 0; i < decodeData.count; i++) {
            uncompDataPointers[i] = 0;
        }
        for(int t = 0; t < decodeData.count; t++){
            int*uncompLayer = malloc(lengthOfPiece *2);
            NSArray *decodeLayer = [decodeData objectAtIndex:t];
            for(int i = 0; i < lengthOfPiece/2; i++){
                uncompLayer[i] = 0;
            }
            for(int i = 0; i < decodeLayer.count; i++){
                NSDictionary *decodeBeat = [decodeLayer objectAtIndex:i];
                NSArray *notesHolders = [decodeBeat objectForKey:@"notesholders"];
                int subdivision = [[decodeBeat objectForKey:@"subdivision"] intValue] +1;
                for(int j=0; j < notesHolders.count; j++){
                    NSDictionary *notesHolder = [[decodeBeat objectForKey:@"notesholders"] objectAtIndex:j];
                    float volume = [[notesHolder objectForKey:@"volume"] floatValue];
                    if(notesHolder.count > 0){
                        
                        
                        NSArray *notes = [notesHolder objectForKey:@"notes"];
                        for(int k = 0;k <notes.count; k++){
                            
                            NSDictionary *decodeNote=[notes objectAtIndex:k];
                            Instrument * instrument = [Assets instForObject:[decodeNote objectForKey:@"instrument"]];
                            Accidental accidental = [[decodeNote objectForKey:@"accidental"] intValue];
                            NotePlacement * notePlacement =[staff.notePlacements objectAtIndex:[[decodeNote objectForKey:@"noteplacement"] intValue]];
                            NoteDescription* noteDescription = [[notePlacement noteDescs] objectAtIndex:accidental];
                            struct NoteData noteData  = [instrument getDataNoteDescription:noteDescription andVolume:volume];
                            
                            unsigned long noteLength = noteData.length;
                            short int*noteShortData = noteData.noteData;
                            
                            if(  k == 0 &&( ![instrument isKindOfClass:[Drums class]]  || volume == 0)){
                                unsigned long positionInPiece = i * samplePerBeat + (j * (samplePerBeat/ ((float)subdivision)));
                                for(long l= positionInPiece; l < lengthOfPiece/2; l++)
                                    uncompLayer[l] = 0;
                            }
                            
                            unsigned long positionInPiece = i * samplePerBeat + (j * (samplePerBeat/ ((float)subdivision)));
                            for(int l = 0; l < noteLength; l++){
                                if(positionInPiece >= (totalLength/2))
                                    break;
                                uncompLayer[positionInPiece] += noteShortData[l];
                                positionInPiece++;
                            }
                            free(noteShortData);
                        }
                        
                    }
                }
            }
            uncompDataPointers[t] = uncompLayer;
        }
        //Adding all the layers to the wavefile
        int *uncompData = malloc(decodeData.count * lengthOfPiece *2);
        for(int i = 0; i < lengthOfPiece/2; i++){
            uncompData[i] = 0;
        }
        for(int i = 0; i < decodeData.count; i++){
            int *uncompLayer = uncompDataPointers[i];
            for(int j =0; j < lengthOfPiece/2; j++)
                uncompData[j] += uncompLayer[j];
            free(uncompLayer);
        }
        free(uncompDataPointers);
        
        Byte *wavfileByte = ( Byte*)malloc( totalLength);
        for(int i = 0; i < 44; i++){
            wavfileByte[i] = headerfile[i];
        }
        free(headerfile);
        
        for(int i = 44; i < totalLength; i++){
            wavfileByte[i] = 0;
        }
        int maxValue = 0;
        for(int i = 0; i < lengthOfPiece/2; i++){
            int val =abs(uncompData[i]) ;
            if(val > maxValue)
                maxValue = val;
        }
        
        if(maxValue < SHRT_MAX)
            maxValue = SHRT_MAX;
        
        short int*wavfile = (short int *)wavfileByte;
        float multi =  (1.0f/maxValue) *SHRT_MAX;
        for( int i = 22; i < (totalLength/2); i++){
            int value = uncompData[i -22] * multi;
            if(value >= SHRT_MAX)
                value = SHRT_MAX;
            else if(value <= SHRT_MIN)
                value = SHRT_MIN;
            wavfile[i] =value;
        }
        free(uncompData);
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *tempFilePath=[NSString stringWithFormat:@"%@/%@%@", path, name, @"temp.wav"];
        NSData *data = [NSData dataWithBytes:(const void *)wavfile length:(lengthOfPiece)];
        [[NSFileManager defaultManager] createFileAtPath:tempFilePath
                                                contents:data
                                              attributes:nil];
        
        //Delete ringtone file if exists
        NSString *ringtonePath =[NSString stringWithFormat:@"%@/%@%@", path, name, @".m4r"];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL exists = [fm fileExistsAtPath:ringtonePath];
        if(exists == YES)
            [fm removeItemAtPath:ringtonePath error:nil];
        
        free(wavfile);
        AVURLAsset *wavAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:tempFilePath] options:nil];
        
        AVMutableComposition *mutableComposition = [AVMutableComposition composition];
        NSError * error;
        [mutableComposition insertTimeRange:CMTimeRangeMake(kCMTimeZero, wavAsset.duration)
                                    ofAsset:wavAsset atTime:kCMTimeZero error:&error];
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                               initWithAsset:[mutableComposition copy] presetName:AVAssetExportPresetAppleM4A];
        exportSession.outputURL = [NSURL fileURLWithPath:ringtonePath];
        exportSession.outputFileType = AVFileTypeAppleM4A;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:tempFilePath error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (exportSession.status) {
                        
                    case AVAssetExportSessionStatusCompleted: {
                        
                        
                        block(YES) ;
                        
                        break;
                    }
                    case AVAssetExportSessionStatusFailed: {
                        
                        
                        block(NO);
                        break;
                    }
                        // ... handle some other cases...
                    default: {
                        block(NO);
                        break;
                    }
                }
            });
        }];
        
        
    }
                   
                   );
}


-(void)changeInstrumentTo:(Instrument *) instrument forLayer:(int)layerIndex{
    [self changeLayer:layerIndex];
    NSArray * beats = [currentLayer beats];
    for(Beat *beat in beats){
        for(NotesHolder *noteHolder in [beat noteHolders]){
            for(Note*note in [noteHolder notes])
                [note setInstrument:instrument];
        }
    }
}

-(int)currentBeatNumber{
    if(layers.count == 0)
        return 0;
    Layout * layer =  [layers objectAtIndex:0];
   return [layer findBeatIndexAtx:(self.contentOffset.x + layer.widthPerBeat  )] +1;
}

-(void)clearBeat:(int)startBeat to:(int)endBeat{
    if(currentLayer){
        [currentLayer clearBeat:startBeat to:endBeat];
    } else{
        for(Layout * layer in layers){
            [layer clearBeat:startBeat to:endBeat];
        }
    }
}

-(void)duplicateBeat:(int)startBeat to:(int)endBeat insert:(int)insertBeat{
    if(currentLayer){
        [currentLayer duplicateBeat:startBeat to:endBeat insert:insertBeat];
    } else{
        for(Layout * layer in layers){
            [layer duplicateBeat:startBeat to:endBeat insert:insertBeat];
        }
    }

}

-(void)moveBeat:(int)startBeat to:(int)endBeat insert:(int)insertBeat{
    if(currentLayer){
        [currentLayer moveBeat:startBeat to:endBeat insert:insertBeat];
    } else{
        for(Layout * layer in layers){
            [layer moveBeat:startBeat to:endBeat insert:insertBeat];
        }
    }

}
@end
