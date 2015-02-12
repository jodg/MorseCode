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
@property   (strong,nonatomic) NSString *morseCode;
@property   (strong,nonatomic) NSString *appendLetterMorseCode;
@property   (strong,nonatomic) NSString *morseSpace;   //single string
@property   (strong,nonatomic) NSString *textSpace;    //single string
@property   (nonatomic) float unit;
@property   (nonatomic) NSUInteger unitInput;
@property   (nonatomic) NSUInteger rangeUnitInput;

-(instancetype)init;
-(NSString *)textToMorseCode;
-(NSString *)MorseCodeToText;
-(void)morseToSound;
-(void)morseToLight:(id)sender selectorOn:(SEL)selectorOn selectorOff:(SEL)selectorOff selectorFinished:(SEL)selectorFinished waitTime:(float)waitTime;
-(void)stopLight:(id)sender selectorOff:(SEL)selectorOff;
-(void)down;
-(void)up;
-(void)reset;
-(NSString *)appendLetter;


@end