//
//  PitchShift.h
//  RingSeq
//
//  Created by Nir Boneh on 10/25/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#ifndef __RingSeq__PitchShift__
#define __RingSeq__PitchShift__

#include <stdio.h>
#include <math.h>


void smb_pitch_shift(short int *origData, short int *outData, long origDataLength, int outDataLength, float frequency);
#endif /* defined(__RingSeq__PitchShift__) */
