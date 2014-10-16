//
//  instrument.m
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Instrument.h"

@implementation Instrument
@synthesize name = _name;
@synthesize image = _image;
-(id)initWithName:(NSString *)name color: (UIColor *)color andNotes: (NSDictionary *)notes{
    self = [super init];
    if(self){
        _name = name;
        _notes =notes;
        _color = color;
    }
    return self;
}

-(UIImage *)image{
    if(_image == nil) {
        _image = [[UIImage imageNamed:self.name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _image;
}

-(void) playNote: (NSString *)note{
    
}
@end
