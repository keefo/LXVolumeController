//
//  LXMasterVolume.h
//  LXVolumeController
//
//  Created by Xu Lian on 2013-07-25.
//  Copyright (c) 2013 Beyondcow. All rights reserved.
//

#ifndef LXMasterVolume_h
#define LXMasterVolume_h

//set master volume
void setMasterVolume(CGFloat volume);//0.0~1.0

//get master volume
CGFloat getMasterVolume();//0.0~1.0

//volume change notification name is LXMasterVolumeChangedNotification
//[[NSNotificationCenter defaultCenter] addObserver:self
//                                         selector:@selector(volumeChanged:)
//                                             name:@"LXMasterVolumeChangedNotification"
//                                           object:nil];
//to get volume change notification
void startMasterVolumeChangeNotification();
void stopMasterVolumeChangeNotification();

#endif
