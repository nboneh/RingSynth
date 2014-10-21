//
//  Note.h
//  RingSeq
//
//  Created by Nir Boneh on 10/14/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteDescription.h"
#import "Staff.h"
#import "Instrument.h"

@interface Note : UIView

@property NoteDescription *noteDescription;
@property NotePlacement *notePlacement;
@property Instrument *instrument;
@property UILabel *accidentalView;
@property UIImageView *instrView;
@property (nonatomic) Accidental accidental;


-(id) initWithNotePlacement: (NotePlacement *)placement withInstrument:(Instrument *)instrument andAccedintal:(Accidental)accidental;
-(void) playWithVolume:(float)volume andChannel:(ALChannelSource *)channel;
-(BOOL)equals:(Note *)note;

@end
