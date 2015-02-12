//
//  TextToMorseViewController.m
//  MorseCode
//
//  Created by jodg on 2/9/15.
//  Copyright (c) 2015 weibolabs. All rights reserved.
//

#import "TextToMorseViewController.h"
#import "Morse.h"
#import "Led.h"

@interface TextToMorseViewController ()

@property (weak, nonatomic) IBOutlet UITextView *morseCode;
@property (weak, nonatomic) UITextView *tempText;
@property (weak, nonatomic) IBOutlet UIButton *light;
@property (weak, nonatomic) IBOutlet UITextView *userText;
@property (weak, nonatomic) IBOutlet UIButton *screen;
@property (strong, nonatomic) Morse *morse;
@property (strong, nonatomic) Led *led;
@property (strong, nonatomic) UIView *lightView;

@property (weak,nonatomic) NSString *morseSpace;   //single string
@property (weak,nonatomic) NSString *textSpace;   //single string
@property (strong,nonatomic) NSMutableAttributedString *morseTextButed;
@property UInt64 unitTime;
@property BOOL lightFlag;
@property int fontSize;
@property BOOL appendLetter;

@end

@implementation TextToMorseViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[self morseCode]setEditable:NO];
    //    self.morse_code.canCancelContentTouches = NO;
    self.morseCode.layer.borderWidth = 1.0;
    self.morseCode.layer.borderColor = [UIColor grayColor].CGColor;
    self.morseCode.layer.cornerRadius = 5.0;
    
    self.userText.layer.borderWidth = 1.0;
    self.userText.layer.borderColor = [UIColor grayColor].CGColor;
    self.userText.layer.cornerRadius = 5.0;
    
    self.light.layer.borderWidth = 1.0;
    self.light.layer.borderColor = [UIColor grayColor].CGColor;
    self.light.layer.cornerRadius = 5.0;
    
    self.screen.layer.borderWidth = 1.0;
    self.screen.layer.borderColor = [UIColor grayColor].CGColor;
    self.screen.layer.cornerRadius = 5.0;
    
    self.fontSize = 14;
    self.lightFlag = NO;
    self.appendLetter = YES;
    self.userText.delegate = self;
    self.morse.morseSpace = self.morseSpace;
    self.morse.textSpace = self.textSpace;
    self.morse.text = self.userText.text;
    [self.morse textToMorseCode];
    [self showMorseText];
    self.led = [[Led alloc]init];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self.userText resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView == self.userText) {
        self.morse.text = self.userText.text;
        [self.morse textToMorseCode];
        [self showMorseText];
    }
}

//-(void)textViewDidBeginEditing:(UITextView *)textView
//{
//    self.temp_text = textView;
//}

- (void)didReceiveMemoryWarning
{
//    NSLog(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)sendByLight:(UIButton *)sender
{
    if (self.lightFlag) {
        self.lightFlag = NO;
        [self resetLight];
    }else{
        self.lightFlag = YES;
        [self.morse morseToLight:self selectorOn:@selector(changeLightImgOn) selectorOff:@selector(changeLightImgOff) selectorFinished:@selector(resetLight) waitTime:0.0];
    }
    
    
}

- (IBAction)sendByScreen:(UIButton *)sender {
    if (self.lightFlag) {
        self.lightFlag = NO;
        [self resetLightView];
    }else{
        self.lightView = [[UIView alloc]initWithFrame:self.view.bounds];
        [self.lightView  setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:self.lightView];
        
        [self.morse morseToLight:self selectorOn:@selector(changeLightViewImgOn) selectorOff:@selector(changeLightViewImgOff) selectorFinished:@selector(resetLightView) waitTime:4.0];
    }
}


-(void)resetLight
{
//    NSLog(@"resetLight");
    self.lightFlag = NO;
    [self.morse stopLight:self selectorOff:@selector(changeLightImgOff)];
}

-(void)lightSendFinished{
    self.lightFlag = NO;
    [self changeLightImgOff];
}

-(void)changeLightImgOff
{
//    NSLog(@"changeLightImgOff");
    [self.led turnOffLed];
    UIImage *light = [UIImage imageNamed:@"flash_light_filled"];
    [self.light setBackgroundImage:light forState:UIControlStateNormal];
}

-(void)changeLightImgOn
{
//    NSLog(@"changeLightImgOn");
    [self.led turnOnLed];
    UIImage *light = [UIImage imageNamed:@"flash_light"];
    [self.light setBackgroundImage:light forState:UIControlStateNormal];
}

-(void)resetLightView
{
    [self.lightView removeFromSuperview];
    self.lightFlag = NO;
    [self.morse stopLight:self selectorOff:@selector(changeLightImgOff)];
}

-(void)LightViewSendFinished{
    self.lightFlag = NO;
    [self changeLightImgOff];
}

-(void)changeLightViewImgOff
{
    [self.lightView  setBackgroundColor:[UIColor blackColor]];
}

-(void)changeLightViewImgOn
{
    [self.lightView  setBackgroundColor:[UIColor whiteColor]];
}

-(void)showMorseText
{
    [self butedMorseText];
    //    [[self morse_code]scrollRangeToVisible:self.morse_code.selectedRange];
    self.morseCode.attributedText = self.morseTextButed;
    [self.morseCode flashScrollIndicators];
    [self.userText flashScrollIndicators];
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.userText isExclusiveTouch]|| ![self.userText isExclusiveTouch]) {
        [self.userText resignFirstResponder];
        [self.morseCode resignFirstResponder];
    }
}


@end
