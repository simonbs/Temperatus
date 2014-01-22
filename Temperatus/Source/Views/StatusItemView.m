//
//  StatusItemView.m
//  Temperatus
//
//  Created by Simon Støvring on 21/01/14.
//  Copyright (c) 2014 intuitaps. All rights reserved.
//

#import "StatusItemView.h"

#define TMPUSStatusBarHeight 20.0f
#define TMPUSTitlePadding 2.0f
#define TMPUSIconPadding 2.0f

typedef NS_ENUM(NSInteger, StatusItemViewMode) {
    StatusItemViewModeIcon = 0,
    StatusItemViewModeTemperature,
};

static void *KVOSelfContext = &KVOSelfContext;

@interface StatusItemView ()
@property (nonatomic, assign) StatusItemViewMode statusItemViewMode;
@property (nonatomic, assign) CGFloat temperature;
@property (nonatomic, strong) NSImageView *imageView;
@property (nonatomic, strong) NSTextField *textField;
@property (nonatomic, assign) TMPUSUnit unit;
@end

@implementation StatusItemView

#pragma mark -
#pragma mark Lifecycle

- (id)init
{
    if (self = [super init])
    {
        self.imageView = [NSImageView new];
        self.imageView.alphaValue = 0.0f;
        [self addSubview:self.imageView];
        
        self.textField = [NSTextField new];
        self.textField.alphaValue = 0.0f;
        self.textField.backgroundColor = [NSColor clearColor];
        self.textField.font = [NSFont boldSystemFontOfSize:12.0f];
        [self.textField.cell setUsesSingleLineMode:YES];
        [self.textField setBezeled:NO];
        [self.textField setEditable:NO];
        [self.textField setSelectable:NO];
        [self addSubview:self.textField];
        
        [self addObserver:self forKeyPath:@"highlighted" options:0 context:KVOSelfContext];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KVOSelfContext && [keyPath isEqualToString:@"highlighted"])
    {
        switch (self.statusItemViewMode) {
            case StatusItemViewModeIcon:
                [self showIcon];
                break;
            case StatusItemViewModeTemperature:
                [self showTemperature:self.temperature withUnit:self.unit];
                break;
            default:
                break;
        }
        
        [self setNeedsDisplay:YES];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)drawRect:(NSRect)rect
{
    [self.statusItem drawStatusBarBackgroundInRect:NSMakeRect(0.0f, 0.0f, rect.size.width, rect.size.height) withHighlight:self.isHighlighted];
}

- (void)dealloc
{
    self.delegate = nil;
    self.statusItem = nil;
    self.target = nil;
    self.clickAction = nil;
    self.imageView = nil;
    self.textField = nil;
}

#pragma mark -
#pragma mark Public Methods

- (void)showIcon
{
    self.statusItemViewMode = StatusItemViewModeIcon;

    NSImage *iconImage = nil;
    if (self.isHighlighted)
    {
        iconImage = [NSImage imageNamed:@"StatusItemIconHighlighted"];
    }
    else
    {
        iconImage = [NSImage imageNamed:@"StatusItemIcon"];
    }
    
    CGRect frame = CGRectMake(TMPUSIconPadding * 0.50f, 0.0f, iconImage.size.width, iconImage.size.height);
    self.imageView.frame = frame;
    self.imageView.image = iconImage;
    self.imageView.alphaValue = 1.0f;
    
    self.textField.alphaValue = 0.0f;
    
    [self preferredLengthChanged:iconImage.size.width + TMPUSIconPadding];
}

- (void)showTemperature:(CGFloat)temperature withUnit:(TMPUSUnit)unit
{
    self.statusItemViewMode = StatusItemViewModeTemperature;
    self.temperature = temperature;
    self.unit = unit;
    
    NSString *title = [NSString stringWithFormat:@"%.1f%@", temperature, [self suffixForUnit:unit]];
    NSRect titleRect = [title boundingRectWithSize:NSMakeSize(MAXFLOAT, TMPUSStatusBarHeight) options:0 attributes:@{ NSFontAttributeName : self.textField.font }];
    titleRect = NSInsetRect(titleRect, -TMPUSTitlePadding, -TMPUSTitlePadding);
    NSSize titleSize = titleRect.size;
    
    NSRect frame = CGRectMake(0.0f, (TMPUSStatusBarHeight - titleSize.height) * 0.50f, titleSize.width, TMPUSStatusBarHeight);
    self.textField.frame = frame;
    self.textField.stringValue = title;
    self.textField.alphaValue = 1.0f;
    
    if (self.isHighlighted)
    {
        self.textField.textColor = [NSColor whiteColor];
    }
    else
    {
        self.textField.textColor = [NSColor blackColor];
    }
    
    self.imageView.alphaValue = 0.0f;
    
    [self preferredLengthChanged:titleSize.width];
}

- (NSString *)suffixForUnit:(TMPUSUnit)unit
{
    NSString *suffix = nil;
    switch (unit) {
        case TMPUSUnitCelcius:
            suffix = @"°C";
            break;
        case TMPUSUnitFahrenheit:
            suffix = @"°F";
            break;
        case TMPUSUnitKelvin:
            suffix = @"K";
            break;
        default:
            break;
    }
    
    return suffix;
}

#pragma mark -
#pragma mark Private Methods

- (void)preferredLengthChanged:(CGFloat)preferredLength
{
    if ([self.delegate respondsToSelector:@selector(statusItemView:preferredLengthChanged:)])
    {
        [self.delegate statusItemView:self preferredLengthChanged:preferredLength];
    }
}

#pragma mark -
#pragma mark Interaction

- (void)mouseDown:(NSEvent *)theEvent
{
    if (self.target && self.clickAction)
    {
        [NSApp sendAction:self.clickAction to:self.target from:self];
    }
}

@end
