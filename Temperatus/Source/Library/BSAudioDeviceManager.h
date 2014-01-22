//
//  BSAudioDeviceManager.h
//  BSAudioDeviceManager
//
//  Created by Simon Støvring on 06/12/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BSAudioDeviceManagerDelegate;

@interface BSAudioDeviceManager : NSObject

@property (nonatomic, weak) id<BSAudioDeviceManagerDelegate> delegate;

- (void)start;
- (void)stop;

@end

@protocol BSAudioDeviceManagerDelegate <NSObject>
@optional
- (void)audioDeviceManagerDidStart:(BSAudioDeviceManager *)manager;
- (void)audioDeviceManager:(BSAudioDeviceManager *)manager failedStarting:(NSError *)error;
- (void)audioDeviceManagerDidStop:(BSAudioDeviceManager *)manager;
- (void)audioDeviceManager:(BSAudioDeviceManager *)manager failedStopping:(NSError *)error;
- (void)audioDeviceManager:(BSAudioDeviceManager *)manager deviceChanged:(BOOL)isInternalSpeakers;
- (void)audioDeviceManager:(BSAudioDeviceManager *)manager failedCheckingDevice:(NSError *)error;
@end
