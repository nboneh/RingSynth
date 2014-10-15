//
//  Staff.h
//  RingSeq
//
//  Created by Nir Boneh on 10/13/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteDescription.h"
@interface NotePlacement :NSObject
@property float y;
@property NSArray *noteDescs;
-(id) initWithY:(int) y andNote:(NoteDescription *) noteDesc;
@end

@interface Staff : UIView
@property int spacePerNote;
@property UIImageView *trebleView;
@property NSArray *notePlacements;
@end
