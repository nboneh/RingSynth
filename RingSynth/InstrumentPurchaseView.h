//
//  InstrumentPurchaseView.h
//  RingSynth
//
//  Created by Nir Boneh on 11/4/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"

@interface InstrumentPurchaseView : UIImageView<AVAudioPlayerDelegate>{
    Instrument * instrument;
    CGRect origFrame;
    AVAudioPlayer *player;
}
-(id)initWitInstrument:(Instrument *) instrument andX:(int)x;



@end
