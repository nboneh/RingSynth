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
+(void) initialize{
    NSMutableArray *instrumentMut = [[NSMutableArray alloc] init];
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"guitar" color: [UIColor redColor] andNotes:nil]];
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"electricguitar" color: [UIColor blueColor] andNotes:nil]];
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"drums" color:[UIColor brownColor] andNotes:nil]];
        [instrumentMut addObject:[[Instrument alloc] initWithName:@"bass" color:[UIColor greenColor] andNotes:nil]];
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"xylophone" color:[UIColor cyanColor] andNotes:nil]];
        [instrumentMut addObject:[[Instrument alloc] initWithName:@"trumpet" color:[UIColor yellowColor] andNotes:nil]];
     [instrumentMut addObject:[[Instrument alloc] initWithName:@"trombone" color:[UIColor magentaColor] andNotes:nil]];
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"saxphone" color:[UIColor orangeColor] andNotes:nil]];
            [instrumentMut addObject:[[Instrument alloc] initWithName:@"orchestra" color:[UIColor grayColor] andNotes:nil]];
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"highpiano" color:[UIColor purpleColor] andNotes:nil]];
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"lowpiano" color:[UIColor purpleColor] andNotes:nil]];

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
