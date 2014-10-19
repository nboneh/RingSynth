//
//  instrument.h
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NoteDescription.h"


@interface Instrument : NSObject

@property (readonly)NSString *name;
@property(readonly) UIImage *image;
@property(readonly) UIColor *color;
@property NSDictionary *notes;

-(id)initWithName:(NSString *)name color: (UIColor *)color;


-(void) playNote: (NoteDescription *)note withVolume:(float)volume;
-(void)play;

@end
