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

@property (strong, nonatomic) IBOutlet UITextView *morse_code;
@property (strong, nonatomic) UITextView *temp_text;
@property (weak, nonatomic) IBOutlet UIButton *light;
@property (strong, nonatomic) IBOutlet UITextView *user_text;
@property (strong, nonatomic) Morse *morse;

@property (strong,nonatomic) NSString *morse_space;   //single string
@property (strong,nonatomic) NSString *text_space;   //single string
@property (strong,nonatomic) NSMutableAttributedString *morse_text_buted;
@property UInt64 unit_time;
@property BOOL light_flag;
@property int font_size;
@property BOOL append_letter;

@end

@implementation MorseViewController

-(Morse *)morse
{
    if (!_morse) _morse = [[Morse alloc]init];
    return _morse;
}

-(NSString *)text_space
{
    if (!_text_space) _text_space = @"\n";
    return _text_space;
}

-(NSString *)morse_space
{
    if (!_morse_space) _morse_space = @" ";
    return _morse_space;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[self morse_code]setEditable:NO];
//    self.morse_code.canCancelContentTouches = NO;
    
    self.font_size = 24;
    self.light_flag = NO;
    self.append_letter = YES;
    self.user_text.delegate = self;
    self.morse.morse_space = self.morse_space;
    self.morse.text_space = self.text_space;
    self.morse.text = self.user_text.text;
    [self.morse textToMorseCode];
    [self showMorseText];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self.user_text resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView == self.user_text) {
        self.morse.text = self.user_text.text;
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
    self.user_text.text = nil;
    self.morse_code.text = nil;
    self.morse_code.attributedText = nil;
    self.morse_text_buted = nil;
    [self.morse reset];
    [self resetLight];
}

- (IBAction)sendByLight:(UIButton *)sender
{
    if (self.light_flag) {
        self.light_flag = NO;
        [self resetLight];
    }else{
        self.light_flag = YES;
        [self.morse morseToLight:self selectorOn:@selector(changeLightImgOn) selectorOff:@selector(changeLightImgOff) selectorFinished:@selector(lightSendFinished)];
    }
    
}

-(void)resetLight
{
    self.light_flag = NO;
    [self.morse stopLight:self selectorOff:@selector(changeLightImgOff)];
}

-(void)lightSendFinished{
    self.light_flag = NO;
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
    self.morse.morse_code = [self.morse.morse_code stringByAppendingFormat:@"%@",self.text_space];
    [self reloadMorse];
}

- (IBAction)entDash:(UIButton *)sender
{
    self.morse.morse_code = [self.morse.morse_code stringByAppendingFormat:@"%@",@"-"] ;
    [self reloadMorse];
}

- (IBAction)entDa:(UIButton *)sender
{
    self.morse.morse_code = [self.morse.morse_code stringByAppendingFormat:@"%@",@"."] ;
    [self reloadMorse];
}

- (IBAction)entSpace:(UIButton *)sender
{
    self.morse.morse_code = [self.morse.morse_code stringByAppendingFormat:@"%@",self.morse_space];
    [self reloadMorse];
}

- (IBAction)entBack:(UIButton *)sender
{
    if([self.morse.morse_code length] > 0){
        self.morse.morse_code = [self.morse.morse_code substringToIndex:[self.morse.morse_code length] - 1];
        [self reloadMorse];
    }
}

- (IBAction)changedFontSize:(UIStepper *)sender {
    self.font_size = sender.value;
    //    NSLog(@"%d",self.font_size);
    [self showMorseText];
}

- (IBAction)isAppendLetter:(UISwitch *)sender
{
    if(sender.on){
        self.append_letter = YES;
    }else{
        self.append_letter = NO;
    }
    [self showMorseText];
}

-(void)reloadMorse
{
    [self.morse MorseCodeToText];
    self.user_text.text = self.morse.text;
    [self showMorseText];
}

-(void)showMorseText
{
    [self butedMorseText];
//    [[self morse_code]scrollRangeToVisible:self.morse_code.selectedRange];
    self.morse_code.attributedText = self.morse_text_buted;
}

-(void)butedMorseText
{
    self.morse_text_buted = nil;
    if([self.morse.morse_code length] > 0){
        NSDictionary *attrs_dic = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                    NSBackgroundColorAttributeName: [UIColor blackColor],
                                    NSFontAttributeName:[UIFont systemFontOfSize:self.font_size]
                                    };
        if (self.append_letter) {
            NSError *error;
            NSString *reg_text = @"\\(.*?\\)";
            [self.morse appendLetter];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg_text options:NSRegularExpressionCaseInsensitive error:&error];
            NSArray *array_match = [regex matchesInString:self.morse.append_letter_morse_code options:0 range:NSMakeRange(0, [self.morse.append_letter_morse_code length])];
            
            self.morse_text_buted = [[NSMutableAttributedString alloc]initWithString:self.morse.append_letter_morse_code attributes:attrs_dic];
            if ([array_match count] > 0) {
                NSDictionary *word_attrs_Dic = @{
                                                 //NSForegroundColorAttributeName: [UIColor whiteColor],
                                                 //                                       NSBackgroundColorAttributeName: [UIColor whiteColor],
                                                 NSFontAttributeName:[UIFont systemFontOfSize:16]
                                                 };
                for (NSTextCheckingResult *match in array_match) {
                    [self.morse_text_buted addAttributes:word_attrs_Dic range:match.range];
                    
                }
            }
        }else{
            self.morse_text_buted = [[NSMutableAttributedString alloc]initWithString:self.morse.morse_code attributes:attrs_dic];
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
    if (![self.user_text isExclusiveTouch]|| ![self.user_text isExclusiveTouch]) {
        [self.user_text resignFirstResponder];
        [self.morse_code resignFirstResponder];
    }
}

@end

