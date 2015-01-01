/*
 * Asterisk -- An open source telephony toolkit.
 *
 * Copyright (C) 2010, Digium, Inc.
 *
 * David Vossel <dvossel@digium.com>
 *
 * See http://www.asterisk.org for more information about
 * the Asterisk project. Please do not directly contact
 * any of the maintainers of this project for assistance;
 * the project provides a web site, mailing lists and IRC
 * channels for your use.
 *
 * This program is free software, distributed under the terms of
 * the GNU General Public License Version 2. See the LICENSE file
 * at the top of the source tree.
 */

/*! \file
 *
 * \brief Pitch Shift Audio Effect
 *
 * \author David Vossel <dvossel@digium.com>
 *
 * \ingroup functions
 */

/************************* SMB FUNCTION LICENSE *********************************
 *
 * SYNOPSIS: Routine for doing pitch shifting while maintaining
 * duration using the Short Time Fourier Transform.
 *
 * DESCRIPTION: The routine takes a pitchShift factor value which is between 0.5
 * (one octave down) and 2. (one octave up). A value of exactly 1 does not change
 * the pitch. num_samps_to_process tells the routine how many samples in indata[0...
 * num_samps_to_process-1] should be pitch shifted and moved to outdata[0 ...
 * num_samps_to_process-1]. The two buffers can be identical (ie. it can process the
 * data in-place). fft_frame_size defines the FFT frame size used for the
 * processing. Typical values are 1024, 2048 and 4096. It may be any value <=
 * MAX_FRAME_LENGTH but it MUST be a power of 2. osamp is the STFT
 * oversampling factor which also determines the overlap between adjacent STFT
 * frames. It should at least be 4 for moderate scaling ratios. A value of 32 is
 * recommended for best quality. sampleRate takes the sample rate for the signal
 * in unit Hz, ie. 44100 for 44.1 kHz audio. The data passed to the routine in
 * indata[] should be in the range [-1.0, 1.0), which is also the output range
 * for the data, make sure you scale the data accordingly (for 16bit signed integers
 * you would have to divide (and multiply) by 32768).
 *
 * COPYRIGHT 1999-2009 Stephan M. Bernsee <smb [AT] dspdimension [DOT] com>
 *
 *                        The Wide Open License (WOL)
 *
 * Permission to use, copy, modify, distribute and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice and this license appear in all source copies.
 * THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED WARRANTY OF
 * ANY KIND. See http://www.dspguru.com/wol.htm for more information.
 *
 *****************************************************************************/

/*** MODULEINFO
 <support_level>extended</support_level>
 ***/

#include "PitchShift.h"

#include <math.h>
#include <limits.h>
#include <Accelerate/Accelerate.h>
//Assuming the sample is in 44100 hz .2 secs is 8820 samples to calculate
#define PITCH_DETECT_INTERVAL 8820

#define PI	M_PI	/* pi to machine precision, defined in math.h */
#define TWOPI	(2.0*PI)

 static float InterpolateHermite4pt3oX(float x0, float x1, float x2, float x3, float t)
{
    float a0, a1, a2, a3;
    a0 = x3 - x2 - x0 + x1;
    a1 = x0 - x1 - a0;
    a2 = x2 - x0;
    a3 = x1;
    return (a0 * (t * t * t)) + (a1 * (t * t)) + (a2 * t) + (a3);
}
void smb_pitch_shift(short int *origData, short int *outData, long origDataLength, long outDataLength, float delta) {
    for (int i = 0; i < outDataLength; i++)
    {
        float realPos = i / delta;
        
        if(realPos >= 1)
        outData[i] = InterpolateHermite4pt3oX(origData[(int)realPos -1], origData[(int)realPos ],  origData[(int)realPos+1 ], origData[(int)realPos +2
                                                                                                                                       ] , .5f);
        else{
            outData[i] = 0;
        }
    }}
static float autocorr(long size,short *data,float *result)
{
    long i,j,k;
    float temp,norm;
    
    for (i=0;i<size/2;i++)      {
        result[i] = 0.0;
        for (j=0;j<size-i-1;j++)	{
            result[i] += data[i+j] * data[j];
        }
    }
    temp = result[0];
    j = (long) size*0.02;
    while (result[j]<temp && j < size/2)	{
        temp = result[j];
        j += 1;
    }
    temp = 0.0;
    for (i=j;i<size*0.5;i++) {
        if (result[i]>temp) {
            j = i;
            temp = result[i];
        }
    }
    norm = 1.0 / size;
    k = size/2;
    for (i=0;i<size/2;i++)
        result[i] *=  (k - i) * norm;
    if (result[j] == 0) j = 0;
    else if ((result[j] / result[0]) < 0.4) j = 0;
    else if (j > size/4) j = 0;
    return (float) j;
}


float pitchdetect(int size,short int*data)
{
    //Finding max value
    short int maxValue = 0;
    int sizeInShort = size/2;
    for(int i = 0; i < sizeInShort; i++){
       short int val =abs(data[i]) ;
        if(val > maxValue)
            maxValue = val;
    }
    
    int startIndex = 0;
    //Our starting point to detect the pitch would be the first time the amplitude reached over half
    int testVal = maxValue/2;
    for(int i = 0; i < sizeInShort; i++){
        short int val = abs(data[i]);
        if(val > testVal)
            startIndex = i;
    }
    
    int finishedIndex = startIndex + PITCH_DETECT_INTERVAL;
    if(finishedIndex > sizeInShort)
        finishedIndex = sizeInShort;

    int sizeToComputeInShorts = finishedIndex - startIndex;
    if(sizeToComputeInShorts < 500)
        //Very bad sample, the user recorded bad and he should feel bad.
        //We will just return frequency of C4 and not tune instrument to staff
        return 261.63;
    
   
    short int *floatdata  = malloc(sizeToComputeInShorts *2 );

    float *outdata = malloc(sizeToComputeInShorts *4);
    
    for(int i = startIndex; i < finishedIndex; i++){
        floatdata[i] = data[i];
    }
   return (44100/autocorr(sizeToComputeInShorts*2,floatdata,outdata));
   
    //Perform fft
    //vDSP_ctoz((COMPLEX*)outdata, 2, floatdata, 1, sizeToComputeInShorts/2);
}

