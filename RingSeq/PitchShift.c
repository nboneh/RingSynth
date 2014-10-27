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
        
        if(realPos >= 1 && realPos < (outDataLength -2))
        outData[i] = InterpolateHermite4pt3oX(origData[(int)realPos -1], origData[(int)realPos ],  origData[(int)realPos+1 ], origData[(int)realPos +2
                                                                                                                                       ] , .5f);
        else{
            outData[i] = 0;
        }
    }}

