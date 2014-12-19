//
//  MorseViewController.m
//  MorseCode
//
//  Created by jodg on 14/12/18.
//  Copyright (c) 2014年 weibolabs. All rights reserved.
//

#import "MorseViewController.h"
#import "Morse.h"
#import "Led.h"

@interface MorseViewController ()

@property (strong, nonatomic) IBOutlet UITextView *morseCode;
@property (strong, nonatomic) UITextView *tempText;
@property (weak, nonatomic) IBOutlet UIButton *light;
@property (strong, nonatomic) IBOutlet UITextView *userText;
@property (strong, nonatomic) Morse *morse;

@property (strong,nonatomic) NSString *morseSpace;   //single string
@property (strong,nonatomic) NSString *textSpace;   //single string
@property (strong,nonatomic) NSMutableAttributedString *morseTextButed;
@property UInt64 unitTime;
@property BOOL lightFlag;
@property int fontSize;
@property BOOL appendLetter;

@end

@implementation MorseViewController

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
    
    self.fontSize = 24;
    self.lightFlag = NO;
    self.appendLetter = YES;
    self.userText.delegate = self;
    self.morse.morseSpace = self.morseSpace;
    self.morse.textSpace = self.textSpace;
    self.morse.text = self.userText.text;
    [self.morse textToMorseCode];
    [self showMorseText];
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
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clean:(UIButton *)sender
{
    self.userText.text = nil;
    self.morseCode.text = nil;
    self.morseCode.attributedText = nil;
    self.morseTextButed = nil;
    [self.morse reset];
    [self resetLight];
}

- (IBAction)sendByLight:(UIButton *)sender
{
    if (self.lightFlag) {
        self.lightFlag = NO;
        [self resetLight];
    }else{
        self.lightFlag = YES;
        [self.morse morseToLight:self selectorOn:@selector(changeLightImgOn) selectorOff:@selector(changeLightImgOff) selectorFinished:@selector(lightSendFinished)];
    }
    
}

-(void)resetLight
{
    self.lightFlag = NO;
    [self.morse stopLight:self selectorOff:@selector(changeLightImgOff)];
}

-(void)lightSendFinished{
    self.lightFlag = NO;
    [self changeLightImgOff];
}

-(void)changeLightImgOff
{
    UIImage *light = [UIImage imageNamed:@"flash_light_filled"];
    
    [self.light setBackgroundImage:light forState:UIControlStateNormal];
}

-(void)changeLightImgOn
{
    UIImage *light = [UIImage imageNamed:@"flash_light"];
    
    [self.light setBackgroundImage:light forState:UIControlStateNormal];
}

- (IBAction)entWorldSpace:(UIButton *)sender {
    self.morse.morseCode = [self.morse.morseCode stringByAppendingFormat:@"%@",self.textSpace];
    [self reloadMorse];
}

- (IBAction)entDash:(UIButton *)sender
{
    self.morse.morseCode = [self.morse.morseCode stringByAppendingFormat:@"%@",@"-"] ;
    [self reloadMorse];
}

- (IBAction)entDa:(UIButton *)sender
{
    self.morse.morseCode = [self.morse.morseCode stringByAppendingFormat:@"%@",@"."] ;
    [self reloadMorse];
}

- (IBAction)entSpace:(UIButton *)sender
{
    self.morse.morseCode = [self.morse.morseCode stringByAppendingFormat:@"%@",self.morseSpace];
    [self reloadMorse];
}

- (IBAction)entBack:(UIButton *)sender
{
    if([self.morse.morseCode length] > 0){
        self.morse.morseCode = [self.morse.morseCode substringToIndex:[self.morse.morseCode length] - 1];
        [self reloadMorse];
    }
}

- (IBAction)changedFontSize:(UIStepper *)sender {
    self.fontSize = sender.value;
    //    NSLog(@"%d",self.font_size);
    [self showMorseText];
}

- (IBAction)isAppendLetter:(UISwitch *)sender
{
    if(sender.on){
        self.appendLetter = YES;
    }else{
        self.appendLetter = NO;
    }
    [self showMorseText];
}

-(void)reloadMorse
{
    [self.morse MorseCodeToText];
    self.userText.text = self.morse.text;
    [self showMorseText];
}

-(void)showMorseText
{
    [self butedMorseText];
//    [[self morse_code]scrollRangeToVisible:self.morse_code.selectedRange];
    self.morseCode.attributedText = self.morseTextButed;
}

-(void)butedMorseText
{
    self.morseTextButed = nil;
    if([self.morse.morseCode length] > 0){
        NSDictionary *attrs_dic = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                    NSBackgroundColorAttributeName: [UIColor blackColor],
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

- (IBAction)upEnter:(UIButton *)sender
{
    
    [self.morse up];
    [self reloadMorse];
}
- (IBAction)downEnter:(UIButton *)sender
{
    [self.morse down];
    //    NSLog(@"down",nil);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.userText isExclusiveTouch]|| ![self.userText isExclusiveTouch]) {
        [self.userText resignFirstResponder];
        [self.morseCode resignFirstResponder];
    }
}

@end

