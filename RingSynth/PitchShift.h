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
#include <stdlib.h>


void smb_pitch_shift(short int *origData, short int *outData, long origDataLength, long outDataLength, float frequency);

//Helps determine pitch of a wave sample
float pitchdetect(int size,short int *data);

#endif /* defined(__RingSeq__PitchShift__) */
