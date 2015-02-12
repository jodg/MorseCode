//
//  CameraViewController.m
//  MorseCode
//
//  Created by jodg on 1/16/15.
//  Copyright (c) 2015 weibolabs. All rights reserved.
//

#import "CameraViewController.h"
#import "Morse.h"

#pragma mark-

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

#pragma mark-

@interface CameraViewController ()

@property (strong, nonatomic) Morse *morse;
@property (strong,nonatomic) NSString *morseSpace;   //single string
@property (strong,nonatomic) NSString *textSpace;   //single string
@property (strong,nonatomic) NSMutableAttributedString *morseTextButed;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property int fontSize;
@property BOOL appendLetter;
@property BOOL frist;
@property BOOL start;
@end

@implementation CameraViewController

-(Morse *)morse
{
    if (!_morse) _morse = [[Morse alloc]init];
    return _morse;
}

-(NSString *)textSpace
{
    if (!_textSpace) _textSpace = @"\n";
    return _textSpace;
}

-(NSString *)morseSpace
{
    if (!_morseSpace) _morseSpace = @" ";
    return _morseSpace;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    morseCode.layer.borderWidth = 1.0;
    morseCode.layer.borderColor = [UIColor grayColor].CGColor;
    morseCode.layer.cornerRadius = 5.0;
    
    self.startButton.layer.borderWidth = 1.0;
    self.startButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.startButton.layer.cornerRadius = 5.0;
    
    lastRgb = 0.0f;
    variance = 0.0f;
    self.fontSize = 24;
    self.appendLetter = YES;
    self.frist = NO;
    self.start = NO;
    captrueLabel.text = @"to start capture";
    self.morse.morseSpace = self.morseSpace;
    self.morse.textSpace = self.textSpace;
    [self setupAVCapture];
    [super viewWillAppear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [self teardownAVCapture];
    [self endCapture];
    [super viewDidDisappear:animated];
}

// clean up capture setup
- (void)teardownAVCapture
{
    [session stopRunning];
    [previewLayer removeFromSuperlayer];
}

- (void)setupAVCapture
{
    NSError *error = nil;
    
    session = [AVCaptureSession new];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [session setSessionPreset:AVCaptureSessionPresetMedium];
    else
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    // Select a video device, make an input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if ( [session canAddInput:deviceInput] )
        [session addInput:deviceInput];
    
    // Make a still image output
    stillImageOutput = [AVCaptureStillImageOutput new];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil]; // 输出jpeg
    stillImageOutput.outputSettings = outputSettings;

    if ( [session canAddOutput:stillImageOutput] )
        [session addOutput:stillImageOutput];
    
    // Make a video data output
    videoDataOutput = [AVCaptureVideoDataOutput new];
    
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                       [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [videoDataOutput setVideoSettings:rgbOutputSettings];
    
    videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if ( [session canAddOutput:videoDataOutput] )
        [session addOutput:videoDataOutput];
    
    effectiveScale = 1.0;
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    CALayer *rootLayer = [previewView layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:previewLayer];
    [session startRunning];
    [rootLayer addSublayer:[boxView layer]];
}

//-(CGImageRef)imageRefFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    CVPixelBufferLockBaseAddress(imageBuffer, 0);
//    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//    size_t width = CVPixelBufferGetWidth(imageBuffer);
//    size_t height = CVPixelBufferGetHeight(imageBuffer);
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
//    CGImageRef newImage = CGBitmapContextCreateImage(context);
//    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    return newImage;
//}

-(u_long)imageRefFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
//-(UIImage *)imageRefFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGSize boxSize = boxView.bounds.size;
    CGPoint center = CGPointMake(width* effectiveScale * 0.5f, height * effectiveScale * 0.5f);
    CGFloat ratioBox = boxSize.width / previewView.bounds.size.width;
    CGFloat R = width * ratioBox * 0.5f;
    CGFloat box = R * 2;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    
    CGContextRef contextRef = CGBitmapContextCreate(nil, box, box, 8, box*4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextClipToRect(contextRef, CGRectMake(0, 0, box, box));
    CGContextDrawImage(contextRef, CGRectMake(-(center.x - R), -(center.y - R), width * effectiveScale, height * effectiveScale), newImage);
    
//    CGImageRef test = CGBitmapContextCreateImage(contextRef);
//    UIImage* subImage = [[UIImage alloc] initWithCGImage:test
//                                                   scale:1.0
//                                             orientation:UIImageOrientationRight];
    
    unsigned char* data = CGBitmapContextGetData (contextRef);
    if (data == nil){
        return 0.0f;
    }
    
    u_long rgb = 0;
    
    CGFloat boxCount = box*box;
    for (int x = 0; x < boxCount; x++) {
        int offset = 4*x;
        rgb += data[offset];
        rgb += data[offset+1];
        rgb += data[offset+2];
        
    }
    
    
    
    UIGraphicsEndImageContext();
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    CFRelease(newImage);
//    return subImage;
    return rgb / boxCount;
}

//
//-(UIImage *)imageAtRect:(UIImage *)srcImage {
//    CGSize boxSize = boxView.bounds.size;
//    CGSize size = [srcImage size];
//    CGSize cgsize = CGSizeMake(size.width * effectiveScale, size.height * effectiveScale);
//    CGPoint center = CGPointMake(cgsize.width * 0.5f, cgsize.height * 0.5f);
//    CGFloat ratioBox = boxSize.width / previewView.bounds.size.width;
//    CGFloat R = size.width * ratioBox * 0.5f;
//    CGFloat box = R * 2;
//    UIGraphicsBeginImageContext(CGSizeMake( box, box));
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextClearRect(context, CGRectMake(0, 0, box, box));
//    [srcImage drawInRect:CGRectMake(-(center.x - R), -(center.y - R), cgsize.width, cgsize.height)];
//    
//    unsigned char* data = CGBitmapContextGetData (context);
//    
//    
//    
//    if (data == nil) return nil;
//    
//    int redColor = 0,greenColor = 0,blueColor = 0,alphaColor = 0;
//    
//    float maxScore=0;
//    for (int x=0; x<box*box; x++) {
//        int offset = 4*x;
//        int red = data[offset];
//        int green = data[offset+1];
//        int blue = data[offset+2];
//        int alpha =  data[offset+3];
//        
//        if (alpha<25)continue;
//        float h,s,v;
//        RGBtoHSV(red, green, blue, &h, &s, &v);
//        
//        float y = MIN(abs(red*2104+green*4130+blue*802+4096+131072)>>13, 235);
//        y= (y-16)/(235-16);
//        if (y>0.9) {
//            continue;
//        }
//        
//        float score = (s+0.1)*x;
//        if (score>maxScore) {
//            maxScore = score;
//        }
//        
//        redColor = red;
//        greenColor = green;
//        blueColor = blue;
//        alphaColor = alpha;
//    }
//    
//    UIColor *color = [UIColor colorWithRed:(redColor/255.0f) green:(greenColor/255.0f) blue:(blueColor/255.0f) alpha:(alphaColor/255.0f)];
//    
////    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    CGContextRelease(context);
//    
//    
////    CGFloat rgb = 0.0f;
////    for (int i=0; i<[MaxColor count]; i++) {
////        rgb += [MaxColor[i] intValue]/255.0f;
////    }
////    NSLog(@"%f",rgb);
//    
//    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
//    UIGraphicsBeginImageContext(rect.size);
//    context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    CGContextRelease(context);
//    
//    return scaledImage;
//}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (!self.start) {
        return;
    }
    u_long rgb = [self imageRefFromSampleBuffer:sampleBuffer];
//    UIImage *rgb = [self imageRefFromSampleBuffer:sampleBuffer];
    NSLog(@"rgb %lu",rgb);
    
    if (self.frist) {
        variance = rgb;
        self.frist = NO;
        return;
    }else{
        variance = rgb - lastRgb;
    }
    
    lastRgb = rgb;
    BOOL up = NO;
    BOOL down = NO;
//    NSLog(@"variance %f",variance);
    //判断是否有波动.若大于阀值.说明有波动.
    if (abs(variance) > 300) {
        //偏白色.开始接收有信号.
        //偏暗,开始等待信号.
        NSLog(@"%f",variance);
        if(variance> 0){
            down = YES;
        }else{
             up = YES;
        }
    }else{
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (up) {
            [self upEnter];
        }else if(down){
            [self downEnter];
        }
//        startImage.image = rgb;
    });
    
}

- (void)upEnter
{
    [self.morse up];
    [self reloadMorse];
//    NSLog(@"upEnter");
}
- (void)downEnter
{
    [self.morse down];
//    NSLog(@"downEnter");
}

-(void)reloadMorse
{
    [self.morse MorseCodeToText];
    [self showMorseText];
}


-(void)showMorseText
{
    [self butedMorseText];
    //    [[self morse_code]scrollRangeToVisible:self.morse_code.selectedRange];
    morseCode.attributedText = self.morseTextButed;
    [morseCode flashScrollIndicators];
}

-(void)butedMorseText
{
    self.morseTextButed = nil;
    if([self.morse.morseCode length] > 0){
        NSDictionary *attrs_dic = @{
                                    //                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                    //                                    NSBackgroundColorAttributeName: [UIColor blackColor],
                                    NSFontAttributeName:[UIFont systemFontOfSize:self.fontSize]
                                    };
        if (self.appendLetter) {
            NSError *error;
            NSString *reg_text = @"\\(.*?\\)";
            [self.morse appendLetter];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg_text options:NSRegularExpressionCaseInsensitive error:&error];
            NSArray *array_match = [regex matchesInString:self.morse.appendLetterMorseCode options:0 range:NSMakeRange(0, [self.morse.appendLetterMorseCode length])];
            
            self.morseTextButed = [[NSMutableAttributedString alloc]initWithString:self.morse.appendLetterMorseCode attributes:attrs_dic];
            if ([array_match count] > 0) {
                NSDictionary *word_attrs_Dic = @{
                                                 //NSForegroundColorAttributeName: [UIColor whiteColor],
                                                 //                                       NSBackgroundColorAttributeName: [UIColor whiteColor],
                                                 NSFontAttributeName:[UIFont systemFontOfSize:16]
                                                 };
                for (NSTextCheckingResult *match in array_match) {
                    [self.morseTextButed addAttributes:word_attrs_Dic range:match.range];
                    
                }
            }
        }else{
            self.morseTextButed = [[NSMutableAttributedString alloc]initWithString:self.morse.morseCode attributes:attrs_dic];
        }
    }
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        beginGestureScale = effectiveScale;
    }
    return YES;
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender {
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [sender numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [sender locationOfTouch:i inView:previewView];
        CGPoint convertedLocation = [previewLayer convertPoint:location fromLayer:previewLayer.superlayer];
        if ( ! [previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        effectiveScale = beginGestureScale * sender.scale;
        if (effectiveScale < 1.0)
            effectiveScale = 1.0;
        float maxScaleAndCropFactor = 5.0f;
        if (effectiveScale > maxScaleAndCropFactor)
            effectiveScale = maxScaleAndCropFactor;
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [previewLayer setAffineTransform:CGAffineTransformMakeScale(effectiveScale, effectiveScale)];
        [CATransaction commit];
    }
}

- (IBAction)start:(id)sender {
    if (!self.start) {
        [self startCapture];
    }else{
        [self endCapture];
    }
}

-(void)startCapture{
    captrueLabel.text = @"capturing...";
    UIImage *light = [UIImage imageNamed:@"pause"];
    [self.startButton setBackgroundImage:light forState:UIControlStateNormal];
    [self reloadMorse];
    self.frist = YES;
    self.start = YES;
}

-(void)endCapture{
    captrueLabel.text = @"to start capture";
    UIImage *light = [UIImage imageNamed:@"play"];
    [self.startButton setBackgroundImage:light forState:UIControlStateNormal];
    self.frist = NO;
    self.start = NO;
    [self.morse reset];
}
@end
