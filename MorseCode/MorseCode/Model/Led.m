//
//  Led.m
//  MorseCode
//
//  Created by jodg on 14/12/18.
//  Copyright (c) 2014年 weibolabs. All rights reserved.
//

#import "Led.h"

@implementation Led

-(AVCaptureDevice *)device
{
    if (!_device) _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return _device;
}

//关闭手电筒
-(void) turnOffLed
{
    [self switchLed:false];
}

//打开手电筒
-(void) turnOnLed
{
    [self switchLed:true];
}

-(void) switchLed:(bool) action
{
    [self.device lockForConfiguration:nil];
    if (action) {
        [self.device setTorchMode:AVCaptureTorchModeOn];
    }else{
        [self.device setTorchMode: AVCaptureTorchModeOff];
    }
    [self.device unlockForConfiguration];
}

@end

