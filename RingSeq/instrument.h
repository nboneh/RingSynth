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

@property NSString *name;
@property UIImage *image;
@property NSDictionary *notes;

-(id)initWithName:(NSString *)name andNotes: (NSDictionary *)notes;

-(UIImage *)getImage;

-(void) playNote: (NSString *)note;

@end
