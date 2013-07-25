//
//  LXMasterVolume.m
//  LXVolumeController
//
//  Created by Xu Lian on 2013-07-25.
//  Copyright (c) 2013 Beyondcow. All rights reserved.
//

#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioServices.h>

AudioDeviceID defaultOutputDeviceID()
{
    AudioDeviceID	outputDeviceID = kAudioObjectUnknown;
    
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwarePropertyDefaultOutputDevice;
    
    if (!AudioHardwareServiceHasProperty(kAudioObjectSystemObject, &propertyAOPA)){
        return kAudioObjectUnknown;
    }
    
    propertySize = sizeof(AudioDeviceID);
    
    status = AudioHardwareServiceGetPropertyData(kAudioObjectSystemObject, &propertyAOPA, 0, NULL, &propertySize, &outputDeviceID);
    
    if(status != noErr){
        return kAudioObjectUnknown;
    }
    return outputDeviceID;
}


void setMasterVolume(CGFloat volume)
{
    if (volume < 0.0 || volume > 1.0){
        return;
    }
    
    
    AudioDeviceID outputDeviceID = defaultOutputDeviceID();
    if (outputDeviceID == kAudioObjectUnknown){
        NSLog(@"Cannot find default output device!");
        return;
    }
    
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
    
    if (volume < 0.001){
        propertyAOPA.mSelector = kAudioDevicePropertyMute;
     }
    else{
        propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
    }
    
    if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)){
        NSLog(@"Device 0x%0x does not support volume control", outputDeviceID);
        return;
    }
    
    Boolean canSetVolume = NO;
    
    status = AudioHardwareServiceIsPropertySettable(outputDeviceID, &propertyAOPA, &canSetVolume);
    
    if (status || canSetVolume == NO){
        NSLog(@"Device 0x%0x does not support volume control", outputDeviceID);
        return;
    }
    
    if (propertyAOPA.mSelector == kAudioDevicePropertyMute){
        propertySize = sizeof(UInt32);
        UInt32 mute = 1;
        status = AudioHardwareServiceSetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, propertySize, &mute);
    }
    else{
        propertySize = sizeof(Float32);
        Float32 newVolume=(Float32)volume;
        status = AudioHardwareServiceSetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, propertySize, &newVolume);
        
        if (status){
            NSLog(@"Unable to set volume for device 0x%0x", outputDeviceID);
        }
        
        // make sure we're not muted
        propertyAOPA.mSelector = kAudioDevicePropertyMute;
        propertySize = sizeof(UInt32);
        UInt32 mute = 0;
        
        if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)){
            NSLog(@"Device 0x%0x does not support muting", outputDeviceID);
            return;
        }
        
        Boolean canSetMute = NO;
        
        status = AudioHardwareServiceIsPropertySettable(outputDeviceID, &propertyAOPA, &canSetMute);
        
        if (status || !canSetMute){
            NSLog(@"Device 0x%0x does not support muting", outputDeviceID);
            return;
        }
        
        status = AudioHardwareServiceSetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, propertySize, &mute);
    }
    
    if (status) {
        NSLog(@"Unable to set volume for device 0x%0x", outputDeviceID);
    }
}



CGFloat getMasterVolume()
{
    Float32 outputVolume;
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
    
    AudioDeviceID outputDeviceID = defaultOutputDeviceID();
    if (outputDeviceID == kAudioObjectUnknown){
        NSLog(@"Cannot find default output device!");
        return 0.0;
    }
    
    if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)){
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    
    propertySize = sizeof(Float32);
    status = AudioHardwareServiceGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &outputVolume);
    if (status != noErr){
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    if (outputVolume < 0.0 || outputVolume > 1.0) return 0.0;
    return (CGFloat)outputVolume;
}

static OSStatus LXAudioObjectPropertyListenerProc(AudioObjectID                         inObjectID,
                                  UInt32                                inNumberAddresses,
                                  const AudioObjectPropertyAddress      inAddresses[],
                                  void                                  *inClientData)
{
    for(UInt32 addressIndex = 0; addressIndex < inNumberAddresses; ++addressIndex) {
        AudioObjectPropertyAddress currentAddress = inAddresses[addressIndex];
        
        switch(currentAddress.mSelector) {
            case kAudioDevicePropertyVolumeScalar:
            {
                Float32 volume = 0;
                UInt32 dataSize = sizeof(volume);
                OSStatus result = AudioObjectGetPropertyData(inObjectID, &currentAddress, 0, NULL, &dataSize, &volume);
                
                if(kAudioHardwareNoError != result) {
                    // Handle the error
                    continue;
                }
                // Process the volume change
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LXMasterVolumeChangedNotification" object:nil];
                break;
            }
        }
    }
    return noErr;
}

void startMasterVolumeChangeNotification()
{
    AudioObjectPropertyAddress propertyAddress = {
        kAudioDevicePropertyVolumeScalar,
        kAudioDevicePropertyScopeOutput,
        kAudioObjectPropertyElementMaster
    };

    
    AudioDeviceID outputDeviceID = defaultOutputDeviceID();
    if (outputDeviceID == kAudioObjectUnknown){
        NSLog(@"Cannot find default output device!");
        return;
    }
    
    if(AudioObjectHasProperty(outputDeviceID, &propertyAddress)) {
        OSStatus result = AudioObjectAddPropertyListener(outputDeviceID, &propertyAddress, LXAudioObjectPropertyListenerProc, NULL);
        // Error handling omitted
    }
    else {
        // Typically the L and R channels are 1 and 2 respectively, but could be different
        propertyAddress.mElement = 1;
        OSStatus result = AudioObjectAddPropertyListener(outputDeviceID, &propertyAddress, LXAudioObjectPropertyListenerProc, NULL);
        // Error handling omitted
        
        propertyAddress.mElement = 2;
        result = AudioObjectAddPropertyListener(outputDeviceID, &propertyAddress, LXAudioObjectPropertyListenerProc, NULL);
        // Error handling omitted
    }
}

void stopMasterVolumeChangeNotification()
{
    AudioObjectPropertyAddress propertyAddress = {
        kAudioDevicePropertyVolumeScalar,
        kAudioDevicePropertyScopeOutput,
        kAudioObjectPropertyElementMaster
    };
    
    AudioDeviceID outputDeviceID = defaultOutputDeviceID();
    if (outputDeviceID == kAudioObjectUnknown){
        NSLog(@"Cannot find default output device!");
        return;
    }
    
    if(AudioObjectHasProperty(outputDeviceID, &propertyAddress)) {
        OSStatus result = AudioObjectRemovePropertyListener(outputDeviceID, &propertyAddress, LXAudioObjectPropertyListenerProc, NULL);
        // Error handling omitted
    }
    else {
        // Typically the L and R channels are 1 and 2 respectively, but could be different
        propertyAddress.mElement = 1;
        OSStatus result = AudioObjectRemovePropertyListener(outputDeviceID, &propertyAddress, LXAudioObjectPropertyListenerProc, NULL);
        // Error handling omitted
        
        propertyAddress.mElement = 2;
        result = AudioObjectRemovePropertyListener(outputDeviceID, &propertyAddress, LXAudioObjectPropertyListenerProc, NULL);
        // Error handling omitted
    }
}
