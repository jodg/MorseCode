//
//  Led.h
//  MorseCode
//
//  Created by jodg on 14/12/18.
//  Copyright (c) 2014年 weibolabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Led : NSObject

@property(strong,nonatomic)AVCaptureDevice *device;
//关闭手电筒
-(void) turnOffLed;
//打开手电筒
-(void) turnOnLed;

@end
