//
//  Float2StringTransformer.m
//  Lingr Hat
//
//  Created by Tomoo Mizukami on 10/11/11.
//  Copyright 2010 tmiz.net. All rights reserved.
//

#import "Float2StringTransformer.h"


@implementation Float2StringTransformer

+ (Class)transformedValueClass {
	return [NSString class];
}
+ (BOOL)allowsReverseTransformation {
	return NO;
}

- (id)transformedValue:(id)value
{
	float fValue = [value floatValue];
	return [NSString stringWithFormat:@"%02.1f",fValue];
}

@end
