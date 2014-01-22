//
//  BSAudioDeviceManager.m
//  BSAudioDeviceManager
//
//  Created by Simon Støvring on 06/12/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BSAudioDeviceManager.h"
#import <CoreAudio/CoreAudio.h>

@interface BSAudioDeviceManager ()
{
    AudioDeviceID deviceID;
    AudioObjectPropertyListenerBlock listenerBlock;
}
@end

@implementation BSAudioDeviceManager

#pragma mark -
#pragma mark Lifecycle

- (void)dealloc
{
    [self stop];
    
    self.delegate = nil;
    listenerBlock = nil;
}

#pragma mark -
#pragma mark Public Methods

- (void)start
{
    AudioObjectPropertyAddress outputDeviceAddress = {
        kAudioHardwarePropertyDefaultSystemOutputDevice,
        kAudioObjectPropertyScopeGlobal,
		kAudioObjectPropertyElementMaster
    };
    
    UInt32 size = sizeof(AudioDeviceID);
    OSStatus errorCode = AudioObjectGetPropertyData(kAudioObjectSystemObject, &outputDeviceAddress, 0, NULL, &size, &deviceID);
    
    if (errorCode != noErr)
    {
        if ([self.delegate respondsToSelector:@selector(audioDeviceManager:failedStarting:)])
        {
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:errorCode userInfo:nil];
            [self.delegate audioDeviceManager:self failedStarting:error];
            return;
        }
    }
    
    AudioObjectPropertyAddress dataSourceAddress = {
        kAudioDevicePropertyDataSource,
        kAudioDevicePropertyScopeOutput,
        kAudioObjectPropertyElementMaster
    };
    
    if ([self.delegate respondsToSelector:@selector(audioDeviceManagerDidStart:)])
    {
        [self.delegate audioDeviceManagerDidStart:self];
    }
    
    [self checkDevice];
    
    __weak typeof(self) weakSelf = self;
    listenerBlock = ^(UInt32 inNumberAddresses, const AudioObjectPropertyAddress *inAddresses) {
        [weakSelf checkDevice];
    };
    
    AudioObjectAddPropertyListenerBlock(deviceID, &dataSourceAddress, dispatch_get_main_queue(), listenerBlock);
}

- (void)stop
{
    AudioObjectPropertyAddress dataSourceAddress = {
        kAudioDevicePropertyDataSource,
        kAudioDevicePropertyScopeOutput,
        kAudioObjectPropertyElementMaster
    };
    
    OSStatus errorCode = AudioObjectRemovePropertyListenerBlock(deviceID, &dataSourceAddress, dispatch_get_main_queue(), listenerBlock);
    if (errorCode != noErr)
    {
        if ([self.delegate respondsToSelector:@selector(audioDeviceManager:failedStopping:)])
        {
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:errorCode userInfo:nil];
            [self.delegate audioDeviceManager:self failedStopping:error];
        }
    }
    else
    {
        listenerBlock = nil;
        
        if ([self.delegate respondsToSelector:@selector(audioDeviceManagerDidStop:)])
        {
            [self.delegate audioDeviceManagerDidStop:self];
        }
    }
}

#pragma mark -
#pragma mark Private Methods

- (void)checkDevice
{
    AudioObjectPropertyAddress dataSourceAddress = {
        kAudioDevicePropertyDataSource,
        kAudioDevicePropertyScopeOutput,
        kAudioObjectPropertyElementMaster
    };
    
    UInt32 size = sizeof(UInt32);
    UInt32 dataSource;
    OSStatus errorCode = AudioObjectGetPropertyData(deviceID, &dataSourceAddress, 0, NULL, &size, &dataSource);
    
    if (errorCode != noErr)
    {
        if ([self.delegate respondsToSelector:@selector(audioDeviceManager:failedCheckingDevice:)])
        {
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:errorCode userInfo:nil];
            [self.delegate audioDeviceManager:self failedCheckingDevice:error];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(audioDeviceManager:deviceChanged:)])
        {
            BOOL internalSpeakers = (dataSource == 'ispk');
            [self.delegate audioDeviceManager:self deviceChanged:internalSpeakers];
        }
    }
}

@end
