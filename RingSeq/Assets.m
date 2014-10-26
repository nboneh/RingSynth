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
#import "ObjectAL.h"
#import "Drums.h"

@implementation Assets
static NSArray* ERASE_SOUNDS;
static NSArray *INSTRUMENTS;
+(void) initialize{
    [OALSimpleAudio sharedInstance].allowIpod = NO;
    
    // Mute all audio if the silent switch is turned on.
    [OALSimpleAudio sharedInstance].honorSilentSwitch = YES;
    
}

+(NSArray *)INSTRUMENTS{
    if(!INSTRUMENTS){
        NSMutableArray *instrumentMut = [[NSMutableArray alloc] init];
        //Some of the more bassy instruments are tuned to different octaves to let them play bass sounds in treble cleft
        //C4
        [instrumentMut addObject:[[Instrument alloc] initWithName:@"Acoustic Guitar" color: [UIColor redColor] andBaseOctave:4]];
        //C4
        [instrumentMut addObject:[[Instrument alloc] initWithName:@"Electric Guitar" color: [UIColor blueColor] andBaseOctave:4]];
        [instrumentMut addObject:[[Drums alloc] initWithName:@"Drums" color:[UIColor brownColor] andBaseOctave:4]];
        //C4
        [instrumentMut addObject:[[Instrument alloc] initWithName:@"Bass" color:[UIColor greenColor] andBaseOctave:4 ]];
        //C5
        [instrumentMut addObject:[[Instrument alloc] initWithName:@"Bell" color:[UIColor cyanColor] andBaseOctave:5]];
        //C5
        [instrumentMut addObject:[[Instrument alloc] initWithName:@"Trumpet" color:[UIColor yellowColor] andBaseOctave:5]];
        //C3
        [instrumentMut addObject:[[Instrument alloc] initWithName:@"Trombone" color:[UIColor magentaColor]  andBaseOctave:4]];
        //C5
        [instrumentMut addObject:[[Instrument alloc] initWithName:@"Saxophone" color:[UIColor orangeColor] andBaseOctave:5]];
        //C5
        [instrumentMut addObject:[[Instrument alloc] initWithName:@"Orchestra Hit" color:[UIColor grayColor] andBaseOctave:5]];
        
        //C4
        [instrumentMut addObject:[[Instrument alloc] initWithName:@"High Piano" color:[UIColor purpleColor]andBaseOctave:4]];
        //C2
        [instrumentMut addObject:[[Instrument alloc] initWithName:@"Low Piano" color:[UIColor purpleColor]  andBaseOctave:4]];
        INSTRUMENTS  = [[NSArray alloc]initWithArray:instrumentMut];
    }
    return INSTRUMENTS;
}


+(void) playEraseSound{
    if(!ERASE_SOUNDS){
        ERASE_SOUNDS = [[NSArray alloc] initWithObjects:@"delete1.wav", @"delete2.wav", @"delete3.wav",@"delete4.wav", nil];
    }
    
    [[OALSimpleAudio sharedInstance] playEffect:[ERASE_SOUNDS objectAtIndex: arc4random_uniform((int)ERASE_SOUNDS.count)]];
}

@end
