//
//  GVUserDefaults+Settings.h
//  Temperatus
//
//  Created by Simon Støvring on 21/01/14.
//  Copyright (c) 2014 intuitaps. All rights reserved.
//

#import "GVUserDefaults.h"

typedef NS_ENUM(NSInteger, TMPUSUnit) {
    TMPUSUnitCelcius = 0,
    TMPUSUnitFahrenheit,
    TMPUSUnitKelvin,
};

@interface GVUserDefaults (Settings)

@property (nonatomic) TMPUSUnit unit;

@end
