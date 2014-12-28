//
//  Util.m
//  RingSynth
//
//  Created by Nir Boneh on 12/27/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSString *) getPath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:fileName];
}


+(NSString *)getRingtonePath:(NSString *)fileName{
    return [Util getPath:[NSString stringWithFormat:@"%@.rin",(id) fileName]];
}

+(NSString *)getInstrumentPath:(NSString *)fileName{
    return [Util getPath:[NSString stringWithFormat:@"%@.ins",(id) fileName]];
}
@end
