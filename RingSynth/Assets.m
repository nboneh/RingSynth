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
#import "InstrumentFilesViewController.h"
#import "Util.h"

@implementation Assets
static NSArray* ERASE_SOUNDS;
static NSArray *INSTRUMENTS;
static NSArray *IN_APP_PURCHASE_PACKS;
static NSMutableDictionary* USER_INSTRUMENTS;
//Incase user deletes instrument
static Instrument * NULL_INSTRUMENT;

+(void) load{
    // Do not honor silent switch this is a music app 
    [OALSimpleAudio sharedInstance].honorSilentSwitch = NO;
    NSMutableArray *instrumentMut = [[NSMutableArray alloc] init];
    //Some of the more bassy instruments are tuned to different octaves to let them play bass sounds in treble cleft
    //C4
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"Acoustic Guitar" color: [UIColor redColor] andBaseOctave:4]];
    //C4
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"Electric Guitar" color: [UIColor blueColor] andBaseOctave:4]];
    [instrumentMut addObject:[[Drums alloc] initWithName:@"Drums" color:[UIColor brownColor]]];
    //C4
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"Bass Guitar" color:[UIColor greenColor] andBaseOctave:4 ]];
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
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"High Piano" color:[UIColor blackColor]andBaseOctave:4]];
    //C2
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"Low Piano" color:[UIColor blackColor]  andBaseOctave:4]];
    //C5
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"Clarinet" color:[UIColor cyanColor]  andBaseOctave:5]];
    //C5
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"String Section" color:[UIColor brownColor]  andBaseOctave:5]];
    

    NSArray * packs =[Assets IN_APP_PURCHASE_PACKS];
    for(NSDictionary * pack in packs){
        NSArray * instruments = [pack objectForKey:@"instruments"];
        for(Instrument *instrument in instruments){
            [instrumentMut addObject:instrument];
        }
    }
    
    [instrumentMut addObject:[[Instrument alloc] initWithName:@"Voice" color:[UIColor grayColor]  andBaseOctave:5]];

    
    INSTRUMENTS  = [[NSArray alloc]initWithArray:instrumentMut];
    
    ERASE_SOUNDS = [[NSArray alloc] initWithObjects:@"delete1.wav", @"delete2.wav", @"delete3.wav",@"delete4.wav", nil];

    //Loading user instruments
    USER_INSTRUMENTS = [[NSMutableDictionary alloc] init];
    NSArray* user_instruments_data = [InstrumentFilesViewController INSTRUMENT_LIST];
    for(NSString * name in user_instruments_data){
        NSDictionary * instrument_data = [NSKeyedUnarchiver unarchiveObjectWithFile: [Util getInstrumentPath:(id) name]];
        if(instrument_data != nil){
            [USER_INSTRUMENTS setValue:[[Instrument alloc]
                                        initWithName:name color:[instrument_data objectForKey:@"color"] andBaseNote:[instrument_data objectForKey:@"baseNote"] andImageTitle:[instrument_data objectForKey:@"imageName" ]andWavPath:[NSString stringWithFormat: @"%@.wav", name]] forKey:name];
        }
    }
    
    NULL_INSTRUMENT = [[Instrument alloc] initWithName:@"No Instrument" color: [UIColor redColor]];
}

+(NSArray *)INSTRUMENTS{
    
    return INSTRUMENTS;
}


+(void) playEraseSound{
    
    [[OALSimpleAudio sharedInstance] playEffect:[ERASE_SOUNDS objectAtIndex: arc4random_uniform((int)ERASE_SOUNDS.count)]];
}

+(NSArray *)IN_APP_PURCHASE_PACKS{
    if(!IN_APP_PURCHASE_PACKS){
        NSMutableArray *prePacks = [[NSMutableArray alloc] init];
        NSString* identifier = @"com.clouby.ios.RingSynth.FunkPack";
        BOOL purchased = [[NSUserDefaults standardUserDefaults] boolForKey:identifier];
        NSDictionary *funkPack = @{@"name":@"Funk Pack",
                                   @"instruments":@[//C2
                                           [[Instrument alloc] initWithName:@"Slap Bass" color:[UIColor greenColor] andBaseOctave:4 andPurchased:purchased],
                                           //C5
                                           [[Instrument alloc] initWithName:@"Reverb Guitar" color:[UIColor purpleColor] andBaseOctave:4 andPurchased:purchased],
                                           //C4
                                           [[Instrument alloc] initWithName:@"Synth" color:[UIColor blueColor] andBaseOctave:4 andPurchased:purchased]],
                                   @"samplename": @"Funky Funk",
                                   @"price":[[NSNumber alloc] initWithFloat:0.99f],
                                   @"identifier":identifier
                                   
                                   };
        [prePacks addObject:funkPack];

        identifier=@"com.clouby.ios.RingSynth.BeachPack";
        
        purchased = [[NSUserDefaults standardUserDefaults] boolForKey:identifier];
        
        NSDictionary *beachPack =  @{@"name":@"Beach Pack",
                                     @"instruments":@[//C5
                                             //C4
                                             [[Instrument alloc] initWithName:@"Steel Drum" color:[UIColor lightGrayColor] andBaseOctave:4 andPurchased:purchased],
                                             
                                             //C4
                                             [[Instrument alloc] initWithName:@"Ukulele" color:[UIColor brownColor] andBaseOctave:4 andPurchased:purchased],
                                             
                                             //C4
                                             [[Instrument alloc] initWithName:@"Female Voice" color:[UIColor magentaColor] andBaseOctave:5 andPurchased:purchased]],
                                     
                                     @"samplename": @"Off The Beach",
                                     @"price":[[NSNumber alloc] initWithFloat:0.99f],
                                     @"identifier":@"com.clouby.ios.RingSynth.BeachPack"

                                     
                                     };
        
        [prePacks addObject:beachPack];
        IN_APP_PURCHASE_PACKS = [[NSArray alloc] initWithArray:prePacks];
        
        
    }
    return IN_APP_PURCHASE_PACKS;
}

+ (NSString *) getPath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:fileName];
}

+(NSMutableDictionary *) USER_INSTRUMENTS{
    return USER_INSTRUMENTS;
}
@end
