//
//  NonEditableTextField.m
//  RingSeq
//
//  Created by Nir Boneh on 10/20/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "NonEditableTextField.h"

@implementation NonEditableTextField

-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.delegate = self;
    }
    return self;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self endEditing:YES];
    [self resignFirstResponder];
}
@end
