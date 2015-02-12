//
//  MorseToTextViewController.m
//  MorseCode
//
//  Created by jodg on 2/9/15.
//  Copyright (c) 2015 weibolabs. All rights reserved.
//

#import "MorseToTextViewController.h"
#import "Morse.h"
#import "Led.h"

@interface MorseToTextViewController ()

@property (weak, nonatomic) IBOutlet UITextView *morseCode;
@property (weak, nonatomic) UITextView *tempText;
@property (weak, nonatomic) IBOutlet UITextView *userText;
@property (weak, nonatomic) IBOutlet UIButton *da;
@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UIButton *dah;
@property (weak, nonatomic) IBOutlet UIButton *word_space;
@property (weak, nonatomic) IBOutlet UIButton *morse_space;
@property (strong, nonatomic) Morse *morse;


@property (weak,nonatomic) NSString *morseSpace;   //single string
@property (weak,nonatomic) NSString *textSpace;   //single string
@property (strong,nonatomic) NSMutableAttributedString *morseTextButed;
@property UInt64 unitTime;
@property int fontSize;
@property BOOL appendLetter;

@end

@implementation MorseToTextViewController

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
    
    self.da.layer.borderWidth = 1.0;
    self.da.layer.borderColor = [UIColor grayColor].CGColor;
    self.da.layer.cornerRadius = 5.0;
    
    self.dah.layer.borderWidth = 1.0;
    self.dah.layer.borderColor = [UIColor grayColor].CGColor;
    self.dah.layer.cornerRadius = 5.0;
    
    self.back.layer.borderWidth = 1.0;
    self.back.layer.borderColor = [UIColor grayColor].CGColor;
    self.back.layer.cornerRadius = 5.0;
    
    self.word_space.layer.borderWidth = 1.0;
    self.word_space.layer.borderColor = [UIColor grayColor].CGColor;
    self.word_space.layer.cornerRadius = 5.0;
    
    self.morse_space.layer.borderWidth = 1.0;
    self.morse_space.layer.borderColor = [UIColor grayColor].CGColor;
    self.morse_space.layer.cornerRadius = 5.0;
    
    self.fontSize = 14;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.morseCode flashScrollIndicators];
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
