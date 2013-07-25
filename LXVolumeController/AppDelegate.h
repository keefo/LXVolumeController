//
//  AppDelegate.h
//  LXVolumeController
//
//  Created by Xu Lian on 2013-07-25.
//  Copyright (c) 2013 Beyondcow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *volumeField;
@property (assign) IBOutlet NSSlider *slider;


- (IBAction)setVolume:(NSSlider*)sender;
- (IBAction)toggleNotice:(id)sender;

@end
