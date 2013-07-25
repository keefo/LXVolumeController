//
//  AppDelegate.m
//  LXVolumeController
//
//  Created by Xu Lian on 2013-07-25.
//  Copyright (c) 2013 Beyondcow. All rights reserved.
//

#import "AppDelegate.h"
#import "LXMasterVolume.h"

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:@"LXMasterVolumeChangedNotification"
                                               object:nil];
    [self volumeChanged:nil];
    startMasterVolumeChangeNotification();
}

- (void)volumeChanged:(NSNotification*)n
{
    CGFloat volume=getMasterVolume()*100.0;
    [_volumeField setStringValue:[NSString stringWithFormat:@"🔊 %.0f%%", volume]];
    [_slider setFloatValue:volume];
}

- (IBAction)setVolume:(NSSlider*)sender;{
    CGFloat volume=[sender floatValue]/100.0;
    setMasterVolume(volume);
    [self volumeChanged:nil];
}

- (IBAction)toggleNotice:(NSButton*)sender;
{
    if (sender.state==NSOnState) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeChanged:)
                                                     name:@"LXMasterVolumeChangedNotification"
                                                   object:nil];
        startMasterVolumeChangeNotification();
    }
    else{
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"LXMasterVolumeChangedNotification"
                                                      object:nil];
        stopMasterVolumeChangeNotification();
    }
}

@end
