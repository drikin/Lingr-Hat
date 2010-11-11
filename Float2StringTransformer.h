//
//  Float2StringTransformer.h
//  Lingr Hat
//
//  Created by Tomoo Mizukami on 10/11/11.
//  Copyright 2010 tmiz.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Float2StringTransformer : NSValueTransformer
{
}

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;

- (id)transformedValue:(id)value;


@end
