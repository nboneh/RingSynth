//
//  Assets.m
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Assets.h"
#import "Instrument.h"

@implementation Assets

static NSArray *INSTRUMENTS;
+(void) initialize{
    NSMutableArray *instrumentMut = [[NSMutableArray alloc] init];
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"guitar" andNotes:nil]];
     [instrumentMut addObject:[[Instrument alloc] initWithName:@"drums" andNotes:nil]];
     [instrumentMut addObject:[[Instrument alloc] initWithName:@"saxphone" andNotes:nil]];
    INSTRUMENTS  = [[NSArray alloc]initWithArray:instrumentMut];
}

+(NSArray *)getInstruments{
    return INSTRUMENTS;
}

@end
