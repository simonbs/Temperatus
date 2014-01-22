//
//  GVUserDefaults+Settings.m
//  Temperatus
//
//  Created by Simon Støvring on 21/01/14.
//  Copyright (c) 2014 intuitaps. All rights reserved.
//

#import "GVUserDefaults+Settings.h"

@implementation GVUserDefaults (Settings)

@dynamic unit;

#pragma mark -
#pragma mark Lifecycle

- (NSDictionary *)setupDefaults
{
    return @{ @"unit" : @(TMPUSUnitCelcius) };
}

@end
