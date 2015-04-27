//
//  CameraViewController.h
//  MorseCode
//
//  Created by jodg on 1/16/15.
//  Copyright (c) 2015 weibolabs. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController : ViewController <UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    
    __weak IBOutlet UIView *previewView;
    __weak IBOutlet UIImageView *boxView;
    __weak IBOutlet UITextView *morseCode;
    __weak IBOutlet UILabel *captrueLabel;
    __weak IBOutlet UIImageView *startImage;
    
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureVideoDataOutput *videoDataOutput;
    dispatch_queue_t videoDataOutputQueue;
    AVCaptureStillImageOutput *stillImageOutput;
    CGFloat beginGestureScale;
    CGFloat effectiveScale;
    CGFloat lastRgb;
    CGFloat variance;
    
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender;

@end
