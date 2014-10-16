//
//  instrument.h
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Instrument : NSObject

@property (readonly)NSString *name;
@property(readonly) UIImage *image;
@property(readonly) UIColor *color;
@property NSDictionary *notes;

-(id)initWithName:(NSString *)name color: (UIColor *)color andNotes: (NSDictionary *)notes;


-(void) playNote: (NSString *)note;

@end
