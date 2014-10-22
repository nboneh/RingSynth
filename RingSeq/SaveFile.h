//
//  SaveFile.h
//  RingSeq
//
//  Created by Nir Boneh on 10/21/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FullGrid.h"

@interface SaveFile : NSData

@property int tempo;
@property int beats;
@property NSArray * instruments;
@property FullGrid* fullGrid;

@end
