//
//  UIColor+saveColor.m
//  RingSeq
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "UIColor+saveColor.h"
#import <objc/runtime.h>
@implementation UIColor (saveColor)

static char STRING_KEY; // global 0 initialization is fine here, no
// need to change it since the value of the
// variable is not used, just the address

- (UIImage*)associatedObject
{
    return objc_getAssociatedObject(self,&STRING_KEY);
}

- (void)setAssociatedObject:(UIImage*)newObject
{
    objc_setAssociatedObject(self,&STRING_KEY,newObject,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)encodeWithCoderAssociatedObject:(NSCoder *)aCoder
{
    if (CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))==kCGColorSpaceModelPattern)
    {
        UIImage *i = [self associatedObject];
        NSData *imageData = UIImagePNGRepresentation(i);
        [aCoder encodeObject:imageData forKey:@"associatedObjectKey"];
    } else {
        
        // Call default implementation, Swizzled
        [self encodeWithCoderAssociatedObject:aCoder];
    }
}

- (id)initWithCoderAssociatedObject:(NSCoder *)aDecoder
{
    if([aDecoder containsValueForKey:@"associatedObjectKey"])
    {
        NSData *imageData = [aDecoder decodeObjectForKey:@"associatedObjectKey"];
        UIImage *i = [UIImage imageWithData:imageData];

        [self setAssociatedObject:i];
        return self;
    }
    else
    {
        // Call default implementation, Swizzled
        return [self initWithCoderAssociatedObject:aDecoder];
    }
}
@end
