//
//  Util.h
//  RingSynth
//
//  Created by Nir Boneh on 12/27/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+(NSString *) getPath:(NSString *)fileName;
+(NSString *)getRingtonePath:(NSString *)fileName;
+(NSString *)getInstrumentPath:(NSString *)fileName;
+(BOOL)showAds;

@end
