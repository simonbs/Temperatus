//
//  StatusItemView.h
//  Temperatus
//
//  Created by Simon Støvring on 21/01/14.
//  Copyright (c) 2014 intuitaps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol StatusItemViewDelegate;

@interface StatusItemView : NSView

@property (nonatomic, weak) NSStatusItem *statusItem;
@property (nonatomic, weak) id <StatusItemViewDelegate> delegate;
@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL clickAction;

- (void)showIcon;
- (void)showTemperature:(CGFloat)temperature withUnit:(TMPUSUnit)unit;

@end

@protocol StatusItemViewDelegate <NSObject>
@optional
- (void)statusItemView:(StatusItemView *)view preferredLengthChanged:(CGFloat)preferredLength;
@end