//
//  WindowResetButton.m
//  Lingr Hat
//
//  Created by Tomoo Mizukami on 10/11/12.
//  Copyright 2010 tmiz.net. All rights reserved.
//

#import "WindowResetButton.h"

@implementation WindowResetButton

-(IBAction)clicked:(id)sender
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setValue:[NSNumber numberWithInt:800] forKey:@"windowWidth"];
	[userDefaults setValue:[NSNumber numberWithInt:700] forKey:@"windowHeight"];
}


-(void)awakeFromNib
{
	[self setTarget:self];
	[self setAction:@selector(clicked:)];
}


@end
