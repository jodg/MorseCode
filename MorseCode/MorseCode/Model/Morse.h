//
//  Morse.h
//  MorseCode
//
//  Created by jodg on 14/12/18.
//  Copyright (c) 2014年 weibolabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface Morse : NSObject
@property   (strong,nonatomic) NSString *text;
@property   (strong,nonatomic) NSString *morse_code;
@property   (strong,nonatomic) NSString *append_letter_morse_code;
@property   (strong,nonatomic) NSString *morse_space;   //single string
@property   (strong,nonatomic) NSString *text_space;    //single string
@property   (nonatomic) float unit;
@property   (nonatomic) NSUInteger unit_input;
@property   (nonatomic) NSUInteger range_unit_input;

-(instancetype)init;
-(NSString *)textToMorseCode;
-(NSString *)MorseCodeToText;
-(void)morseToSound;
-(void)morseToLight:(id)sender selectorOn:(SEL)selectorOn selectorOff:(SEL)selectorOff;
-(void)stopLight:(id)sender selectorOff:(SEL)selectorOff;
-(void)down;
-(void)up;
-(void)reset;
-(NSString *)appendLetter;


@end