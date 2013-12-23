LXVolumeController
==================

Under OSX programmatically control the master volume as well as register the volume change notification.

![volumeControl1.jpg](http://lianxu.me/wp-content/uploads/2013/07/volumeControl1.jpg "Volume Control")

##The API header file

```objective-c
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
```

##Get the system volume

```objective-c
CGFloat volume=getMasterVolume();//range 0.0~1.0 
```

##Set the system volume

```objective-c
setMasterVolume(volume);//range 0.0~1.0 
```


##Get volume change notification

```objective-c
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:@"LXMasterVolumeChangedNotification"
                                               object:nil];
    startMasterVolumeChangeNotification();
}

- (void)volumeChanged:(NSNotification*)n
{
    CGFloat volume=getMasterVolume();
    //volume changed
}
```

##Stop volume change notification

```objective-c
stopMasterVolumeChangeNotification();  
[[NSNotificationCenter defaultCenter] removeObserver:self
												name:@"LXMasterVolumeChangedNotification"
											  object:nil];
```


