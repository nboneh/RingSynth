//
//  Assets.h
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <Foundation/Foundation.h>
#define RING_TONE_LIST_FILE_NAME @"ringtones.dat"

@interface Assets : NSObject

+(NSArray *)INSTRUMENTS;
+(NSArray *)IN_APP_PURCHASE_PACKS;
+(void) playEraseSound;

@end
