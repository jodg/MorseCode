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
    //    NSLog(@"off",nil);
    [self.device lockForConfiguration:nil];
    [self.device setTorchMode: AVCaptureTorchModeOff];
    [self.device unlockForConfiguration];
}
//打开手电筒
-(void) turnOnLed
{
    //    NSLog(@"on",nil);
    [self.device lockForConfiguration:nil];
    [self.device setTorchMode:AVCaptureTorchModeOn];
    [self.device unlockForConfiguration];
}

@end

