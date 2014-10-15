//
//  Note.m
//  RingSeq
//
//  Created by Nir Boneh on 10/14/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Note.h"
@implementation Note
@synthesize instrument = _instrument;

-(id) initWithNotePlacement: (NotePlacement *)placement withInstrument:(Instrument *)instrument andAccedintal:(Accidental)accidental{
    self = [super init];
    if(self){
        _instrument = instrument;
        _notePlacement =placement;
        _noteDescription = [placement.noteDescs objectAtIndex:accidental];
        _instrView = [[UIImageView alloc] initWithImage:[instrument getImage]];
        [_instrView setTintColor:self.tintColor];
        CGRect imageFrame = _instrView.frame;
        self.frame = CGRectMake(0, placement.y - imageFrame.size.height/2, imageFrame.size.width, imageFrame.size.height);
        [self addSubview:_instrView];
        CGRect myFrame = self.frame;
        int width = myFrame.size.width/2;
        _accidentalView= [[UILabel alloc] initWithFrame:CGRectMake(-width * .8f,width/2,width,width)];
        _accidentalView.textColor = self.tintColor;
        [self addSubview:_accidentalView];
        [self drawAccidental:_noteDescription.accidental];
        
    }
    return self;
}


-(void)drawAccidental:(Accidental)accidental{
    switch(accidental){
        case natural:
            _accidentalView.text = @"";
            break;
        case sharp:
            _accidentalView.text = @"#";
            break;
        case flat:
            _accidentalView.text = @"b";
            break;
        case numOfAccedintals:
            break;
            
    }
    _noteDescription = [_notePlacement.noteDescs objectAtIndex:accidental];
}


-(BOOL)equals:(Note *)note{
    if( self.noteDescription == note.noteDescription && self.instrument == note.instrument)
        return YES;
    return NO;
}

-(void) moveToNotePlacement:(NotePlacement *)placement withAccedintal:(Accidental)accidental{
    _noteDescription = [placement.noteDescs objectAtIndex:accidental];
    CGRect frame = [self frame];
    frame.origin.y = placement.y - _instrView.frame.size.height/2;
    self.frame = frame;
    [self drawAccidental:accidental];
}

-(void) playWithVolume:(float)volume{
    
}
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    // Calculate and store offset, and pop view into front if needed
    startLocation = [[touches anyObject] locationInView:self];
    [self.superview bringSubviewToFront:self];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    // Calculate offset
    CGPoint pt = [[touches anyObject] locationInView:self];
    float dx = pt.x - startLocation.x;
    float dy = pt.y - startLocation.y;
    CGPoint newcenter = CGPointMake(
                                    self.center.x + dx,
                                    self.center.y + dy);
    
    // Set new location
    self.center = newcenter;
}


@end
