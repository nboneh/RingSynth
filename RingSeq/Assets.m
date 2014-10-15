//
//  Assets.m
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Assets.h"
#import "Instrument.h"
#include <stdlib.h>

@interface Assets()
+(SystemSoundID)loadSound:(NSString *)name ofType:(NSString *)type;
@end
@implementation Assets

static NSArray *INSTRUMENTS;
static int ERASE_SOUND_SIZE = 4;
static  SystemSoundID eraseSounds[4];

static int numOfEraseSounds;
+(void) initialize{
    NSMutableArray *instrumentMut = [[NSMutableArray alloc] init];
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"guitar" andNotes:nil]];
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"drums" andNotes:nil]];
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"saxphone" andNotes:nil]];
    INSTRUMENTS  = [[NSArray alloc]initWithArray:instrumentMut];
    eraseSounds[0] = [Assets loadSound:@"delete1" ofType:@"wav"];
    eraseSounds[1] = [Assets loadSound:@"delete2" ofType:@"wav"];
    eraseSounds[2] = [Assets loadSound:@"delete3" ofType:@"wav"];
    eraseSounds[3] = [Assets loadSound:@"delete4" ofType:@"wav"];
    
}

+(NSArray *)getInstruments{
    return INSTRUMENTS;
}
+(SystemSoundID)loadSound:(NSString *)name ofType:(NSString *)type{
    SystemSoundID sound;
    NSString *pewPewPath = [[NSBundle mainBundle]
                            pathForResource:name ofType:type];
    NSURL *pewPewURL = [NSURL fileURLWithPath:pewPewPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &sound);
    return sound;
}

+(void) playEraseSound{
    SystemSoundID sound =eraseSounds[arc4random_uniform(ERASE_SOUND_SIZE)];
    AudioServicesPlaySystemSound(sound);
}

@end
