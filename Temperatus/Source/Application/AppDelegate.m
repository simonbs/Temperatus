//
//  AppDelegate.m
//  Temperatus
//
//  Created by Simon Støvring on 21/01/14.
//  Copyright (c) 2014 intuitaps. All rights reserved.
//

#import "AppDelegate.h"
#import <ThermodoSDK/THMThermodo.h>
#import "BSAudioDeviceManager.h"
#import "StatusItemView.h"

#define TMPUSCelciusToKelvin(x) x + 273.15f
#define TMPUSCelciusToFahrenheit(x) (x * 1.80f) + 32.0f
#define TMPUSTwitterUsername @"simonbs"
#define TMPUSTweetbotAppBundleId "com.tapbots.TweetbotMac" // osascript -e 'id of app "Tweetbot"'

@interface AppDelegate () <THMThermodoDelegate, BSAudioDeviceManagerDelegate, StatusItemViewDelegate, NSMenuDelegate>
@property (nonatomic, strong) BSAudioDeviceManager *audioDeviceManager;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) StatusItemView *statusItemView;
@property (nonatomic, strong) NSMenuItem *celciusMenuItem;
@property (nonatomic, strong) NSMenuItem *fahrenheitMenuItem;
@property (nonatomic, strong) NSMenuItem *kelvinMenuItem;
@property (nonatomic, assign) BOOL hasTemperature;
@property (nonatomic, assign) CGFloat currentTemperature;
@end

@implementation AppDelegate

#pragma mark -
#pragma mark Lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self configureStatusItem];
    [self startAudioDeviceManager];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self stopAudioDeviceManager];
    [self stopThermodo];
}

- (void)dealloc
{
    self.audioDeviceManager = nil;
    self.statusItem = nil;
    self.statusItemView = nil;
    self.celciusMenuItem = nil;
    self.fahrenheitMenuItem = nil;
    self.kelvinMenuItem = nil;
}

#pragma mark -
#pragma mark Private Methods

- (void)startAudioDeviceManager
{
    if (!self.audioDeviceManager)
    {
        self.audioDeviceManager = [BSAudioDeviceManager new];
        self.audioDeviceManager.delegate = self;
    }
    
    [self.audioDeviceManager start];
}

- (void)stopAudioDeviceManager
{
    [self.audioDeviceManager stop];
}

- (void)startThermodo
{
    if (![THMThermodo sharedThermodo].isMeasuring)
    {
        [THMThermodo sharedThermodo].delegate = self;
        [[THMThermodo sharedThermodo] start];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [[THMThermodo sharedThermodo] performSelector:@selector(startMeasuring) withObject:nil];
#pragma clang diagnostic pop
    }
}

- (void)stopThermodo
{
//    if ([THMThermodo sharedThermodo].isMeasuring)
//    {
//        [[THMThermodo sharedThermodo] stop];
//    }
    
    // This is a hack!!
    // This version of the Thermodo SDK causes a crash when -stop is invoked on the shared instance of THMThermodo
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [[THMThermodo sharedThermodo] performSelector:@selector(stopMeasuring) withObject:nil];
#pragma clang diagnostic pop
}

- (void)updateTemperature
{
    TMPUSUnit unit = [GVUserDefaults standardUserDefaults].unit;
    CGFloat temperature = self.currentTemperature;
    
    switch (unit) {
        case TMPUSUnitCelcius:
            temperature = self.currentTemperature;
            break;
        case TMPUSUnitFahrenheit:
            temperature = TMPUSCelciusToFahrenheit(self.currentTemperature);
            break;
        case TMPUSUnitKelvin:
            temperature = TMPUSCelciusToKelvin(self.currentTemperature);
            break;
        default:
            break;
    }
    
    [self.statusItemView showTemperature:temperature withUnit:unit];
}

- (void)configureStatusItem
{
    self.celciusMenuItem = [[NSMenuItem alloc] initWithTitle:@"Celcius" action:@selector(useCelcius:) keyEquivalent:@""];
    self.celciusMenuItem.state = [GVUserDefaults standardUserDefaults].unit == TMPUSUnitCelcius;
    
    self.fahrenheitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Fahrenheit" action:@selector(useFahrenheit:) keyEquivalent:@""];
    self.fahrenheitMenuItem.state = [GVUserDefaults standardUserDefaults].unit == TMPUSUnitFahrenheit;
    
    self.kelvinMenuItem = [[NSMenuItem alloc] initWithTitle:@"Kelvin" action:@selector(useKelvin:) keyEquivalent:@""];
    self.kelvinMenuItem.state = [GVUserDefaults standardUserDefaults].unit == TMPUSUnitKelvin;
    
    NSMenu *menu = [NSMenu new];
    menu.delegate = self;
    [menu addItem:self.celciusMenuItem];
    [menu addItem:self.fahrenheitMenuItem];
    [menu addItem:self.kelvinMenuItem];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit" action:@selector(quitApp:) keyEquivalent:@"Q"];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:[NSString stringWithFormat:@"Developed by @%@", TMPUSTwitterUsername] action:@selector(openTwitter:) keyEquivalent:@""];
    
    self.statusItemView = [StatusItemView new];
    self.statusItemView.target = self;
    self.statusItemView.clickAction = @selector(statusItemClicked);
    self.statusItemView.delegate = self;
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.view = self.statusItemView;
    self.statusItem.menu = menu;
    self.statusItem.highlightMode = YES;
    
    self.statusItemView.statusItem = self.statusItem;
    
    [self.statusItem addObserver:self forKeyPath:@"isHighlighted" options:0 context:NULL];
    
    [self.statusItemView showIcon];
}

- (void)useCelcius:(id)sender
{
    [self changeUnit:TMPUSUnitCelcius];
}

- (void)useFahrenheit:(id)sender
{
    [self changeUnit:TMPUSUnitFahrenheit];
}

- (void)useKelvin:(id)sender
{
    [self changeUnit:TMPUSUnitKelvin];
}

- (void)changeUnit:(TMPUSUnit)unit
{
    self.celciusMenuItem.state = (unit == TMPUSUnitCelcius);
    self.fahrenheitMenuItem.state = (unit == TMPUSUnitFahrenheit);
    self.kelvinMenuItem.state = (unit == TMPUSUnitKelvin);
    
    [GVUserDefaults standardUserDefaults].unit = unit;
    
    if (self.hasTemperature)
    {
        [self updateTemperature];
    }
}

- (void)quitApp:(id)sender
{
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0f];
}

- (void)openTwitter:(id)sender
{
    OSStatus result = LSFindApplicationForInfo(kLSUnknownCreator, CFSTR(TMPUSTweetbotAppBundleId), NULL, NULL, NULL);
    switch (result) {
        case noErr:
            [self openTwitterInTweetbot];
            break;
        case kLSApplicationNotFoundErr:
            [self openTwitterInBrowser];
            break;
        default:
            break;
    }
}

- (void)openTwitterInTweetbot
{
    NSString *urlString = [NSString stringWithFormat:@"tweetbot:///user_profile/%@", TMPUSTwitterUsername];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

- (void)openTwitterInBrowser
{
    NSString *urlString = [NSString stringWithFormat:@"http://twitter.com/%@", TMPUSTwitterUsername];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

- (void)statusItemClicked
{
    [self.statusItem popUpStatusItemMenu:self.statusItem.menu];
}

#pragma mark -
#pragma mark Thermodo Delegate

- (void)thermodo:(THMThermodo *)thermodo didGetTemperature:(CGFloat)temperature
{
    self.hasTemperature = YES;
    self.currentTemperature = temperature;
    [self updateTemperature];
}

- (void)thermodoDidStopMeasuring:(THMThermodo *)thermodo
{
    [self.statusItemView showIcon];
}

#pragma mark -
#pragma mark Audio Device Manager

- (void)audioDeviceManager:(BSAudioDeviceManager *)manager deviceChanged:(BOOL)isInternalSpeakers
{
    if (isInternalSpeakers)
    {
        [self.statusItemView showIcon];
        [self stopThermodo];
    }
    else
    {
        [self startThermodo];
    }
}

#pragma mark -
#pragma mark Status Item View Delegate

- (void)statusItemView:(StatusItemView *)view preferredLengthChanged:(CGFloat)preferredLength
{
    self.statusItem.length = preferredLength;
}

#pragma mark -
#pragma mark Menu Delegate

- (void)menuWillOpen:(NSMenu *)menu
{
    self.statusItemView.highlighted = YES;
}

- (void)menuDidClose:(NSMenu *)menu
{
    self.statusItemView.highlighted = NO;
}

@end
