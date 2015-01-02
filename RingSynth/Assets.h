//
//  Assets.h
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Instrument.h"

@interface Assets : NSObject

+(NSArray *)INSTRUMENTS;

+(NSDictionary *) USER_INSTRUMENTS;
+(NSArray *)USER_INSTRUMENTS_KEYS;

+(void) UPDATE_USER_INSTRUMENTS;

//Helps with saving instruments
+(NSObject *) objectForInst:(Instrument *)instrument;
+(Instrument *) instForObject:(NSObject *) object;


+(NSArray *)IN_APP_PURCHASE_PACKS;
+(void) playEraseSound;

@end
