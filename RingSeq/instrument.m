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
-(id)initWithName:(NSString *)name andNotes: (NSDictionary *)notes{
    self = [super init];
    if(self){
        self.name = name;
        self.notes =notes;
    }
    return self;
}

-(UIImage *)getImage{
    if(_image == nil) {
        _image = [[UIImage imageNamed:self.name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _image;
}

-(void) playNote: (NSString *)note{
    
}
@end
