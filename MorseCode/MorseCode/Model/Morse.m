//
//  Morse.m
//  MorseCode
//
//  Created by jodg on 14/12/18.
//  Copyright (c) 2014年 weibolabs. All rights reserved.
//


#import "Morse.h"
#import "Led.h"

@interface Morse()
@property   (strong,nonatomic)  NSMutableArray *time;
@property   (nonatomic) uint64_t sendTime;
@property   (nonatomic) uint64_t waitTime;
@property   (nonatomic) uint64_t unitTime;
@property   (strong,nonatomic)  NSString *lastMatch;
@end

@implementation Morse

-(instancetype)init
{
    self = [super init];
    self.unit = 0.4;
    self.unitInput = self.unit * 1000;
    self.rangeUnitInput = self.unit/2*1000;
    return self;
}

-(void)reset
{
    self.lastMatch = @"";
    self.waitTime = 0;
    self.sendTime = 0;
    self.unitTime = 0;
    self.morseCode = @"";
    self.lastMatch = @"";
    self.text = @"";
}

-(NSMutableArray *)time
{
    if (!_time) {
        _time = [[NSMutableArray alloc]init];
    }
    return _time;
}

-(NSString *)appendLetterMorseCode
{
    if(!_appendLetterMorseCode) _appendLetterMorseCode = @"";
    return _appendLetterMorseCode;
}

-(NSString *)text
{
    if(!_text) _text = nil;
    return _text;
}

-(NSString *)lastMatch
{
    if(!_lastMatch) _lastMatch = @"";
    return _lastMatch;
}

-(NSString *)morseCode
{
    if(!_morseCode) _morseCode = @"";
    return _morseCode;
}

-(NSString *)textSpace
{
    if(!_textSpace) _textSpace = @"\n";
    return _textSpace;
}

-(NSString *)morseSpace
{
    if(!_morseSpace) _morseSpace = @" ";
    return _morseSpace;
}

-(uint64_t)sysTime{
    return [[NSDate date] timeIntervalSinceReferenceDate]*1000;
}

-(void)down
{
    self.sendTime = [self sysTime];
    //    NSLog(@"send_time: %llu",self.send_time);
    if (self.waitTime) {
        NSString *match;
        self.waitTime = [self sysTime] - self.waitTime;
        match = [self matchMorseSpace];
        
        if (match) {
            //            NSLog(@"last_match %@",self.last_match);
            if ([self.lastMatch isEqualToString:self.morseSpace] || [self.lastMatch isEqualToString:self.textSpace]) {
                //                NSLog(@"1 morse_code %@",self.morse_code);
                if ([self.morseCode length] > 0) {
                    self.morseCode = [self.morseCode substringToIndex:[self.morseCode length] - 1];
                }
                //                NSLog(@"2 morse_code %@",self.morse_code);
                if ([match isEqualToString:self.textSpace] || [self.lastMatch isEqualToString:self.textSpace]){
                    match = self.textSpace;
                }else{
                    match = self.morseSpace;
                }
            }
            self.lastMatch = match;
            self.morseCode = [self.morseCode stringByAppendingFormat:@"%@",match];
        }
    }
}

-(void)up
{
    NSString *match;
    self.sendTime = [self sysTime] - self.sendTime;
    self.waitTime = [self sysTime];
    [self countUnit];
    
    match = [self matchMorseChat];
    if (match) {
        self.lastMatch = match;
        self.morseCode = [self.morseCode stringByAppendingFormat:@"%@",match];
    }
}

-(NSString *)matchMorseSpace
{
    NSString *match;
    match = nil;
    //    NSLog(@"matchMorseSpace wait_time: %llu,unit_time: %llu",self.wait_time,self.unit_time);
    if (self.unitTime * 3 + self.rangeUnitInput <= self.waitTime && self.waitTime <= self.unitTime * 7 - self.rangeUnitInput) {
        match = self.morseSpace;
    }else if (self.unitTime * 8 + self.rangeUnitInput <= self.waitTime){
        match = self.textSpace;
    }
    return match;
}

-(NSString *)matchMorseChat
{
    //    NSLog(@"matchMorseChat send_time: %llu,unit_time: %llu",self.send_time,self.unit_time);
    NSString *match;
    match = nil;
    if (self.unitTime - self.rangeUnitInput <= self.sendTime && self.sendTime <= self.unitTime + self.rangeUnitInput) {
        match = @".";
    }else if (self.unitTime * 3 - self.rangeUnitInput <= self.sendTime){
        match =  @"-";
    }
    return match;
}

-(void)countUnit
{
    uint64_t lastUnitTime;
    
    if (self.unitTime == 0) {
        self.morseCode = @"";
        //        self.touch_times = 1;
        lastUnitTime = self.unitInput;
    }else{
        if (self.unitTime < self.rangeUnitInput) {
            self.unitTime = self.rangeUnitInput;
        }
        lastUnitTime = self.unitTime;
    }
    //    NSLog(@"countUnitTime last_unit_time: %llu,unit_time: %llu",last_unit_time,self.unit_time);
    
    if (lastUnitTime - self.rangeUnitInput <= self.sendTime && self.sendTime <= lastUnitTime + self.rangeUnitInput) {
        
        self.unitTime = self.sendTime;
        
    }else if(self.sendTime > lastUnitTime + self.rangeUnitInput){
        if (self.unitTime == 0) {
            
            self.unitTime = lastUnitTime * 3 ;
            
        }
    }
    //    NSLog(@"countUnitTime last_unit_time: %d,unit_time: %d",last_unit_time,self.unit_time);
    //    self.unit_time = (last_unit_time + self.unit_time) / 2;
}

-(NSString *)textToMorseCode
{
    self.morseCode = @"";
    if ([self.text length] > 0) {
        NSString *space,*c;
        NSDictionary *morseDic = [self morseDic];
        
        for (int i = 0; i < [self.text length]; i++) {
            NSString *s = [self.text substringWithRange:NSMakeRange(i, 1)];
            c = space = @"";
            NSString *s_low = [s lowercaseString];
            if ([morseDic objectForKey:s_low]) {
                c = [morseDic objectForKey:s_low];
                space = self.morseSpace;
            }else if([s isEqualToString:@" "]){
                c = self.textSpace;
            }
            
            if (c) {
                self.morseCode = [self.morseCode stringByAppendingFormat:@"%@%@",space,c];
            }
        }
        
        if([self.morseCode length] > 0 && [[self.morseCode substringWithRange:NSMakeRange(0, 1)]isEqualToString:self.morseSpace]){
            self.morseCode = [self.morseCode substringFromIndex:1];
        }
    }
    
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //    AudioServicesPlaySystemSound(1109);
    return self.morseCode;
}

-(NSString *)MorseCodeToText
{
    self.text = @"";
    if([self.morseCode length] > 0){
        NSString *match,*c;
        NSDictionary *worldDic = [self worldDic];
        c = match = @"";
        for (int i = 0; i < [self.morseCode length]; i++) {
            
            NSString *s = [self.morseCode substringWithRange:NSMakeRange(i, 1)];
            
            if([s isEqualToString:self.morseSpace]){
                if ([worldDic objectForKey:c]) {
                    match = [worldDic objectForKey:c];
                    self.text = [self.text stringByAppendingString:match];
                    //                    NSLog(@"text %@", self.text);
                }
                c = @"";
                continue;
            }else if ([s isEqualToString:self.textSpace]) {
                if ([worldDic objectForKey:c]) {
                    match = [worldDic objectForKey:c];
                    self.text = [self.text stringByAppendingString:match];
                    //                    NSLog(@"text %@", self.text);
                }
                self.text = [self.text stringByAppendingString:self.morseSpace];
                c = @"";
                continue;
            }
            
            c = [c stringByAppendingString:s];
            
            if(i == [self.morseCode length] - 1){
                if ([worldDic objectForKey:c]) {
                    match = [worldDic objectForKey:c];
                    self.text = [self.text stringByAppendingString:match];
                    //                    NSLog(@"text %@", self.text);
                }
            }
            //            NSLog(@"c %@", c);
            
        }
    }
    return self.text;
}

-(NSString *)appendLetter
{
    self.appendLetterMorseCode = @"";
    if([self.morseCode length] > 0){
        NSString *match,*c;
        NSDictionary *worldDic = [self worldDic];
        c = match = @"";
        for (int i = 0; i < [self.morseCode length]; i++) {
            NSString *s = [self.morseCode substringWithRange:NSMakeRange(i, 1)];
            
            if([s isEqualToString:self.morseSpace]){
                if ([worldDic objectForKey:c]) {
                    match = [worldDic objectForKey:c];
                    self.appendLetterMorseCode = [self.appendLetterMorseCode stringByAppendingFormat:@"( %@ )", match];
                }
                c = @"";
            }else if ([s isEqualToString:self.textSpace]) {
                if ([worldDic objectForKey:c]) {
                    match = [worldDic objectForKey:c];
                    self.appendLetterMorseCode = [self.appendLetterMorseCode stringByAppendingFormat:@"( %@ )", match];
                }
                c = @"";
            }else{
                c = [c stringByAppendingString:s];
            }
            
            self.appendLetterMorseCode = [self.appendLetterMorseCode stringByAppendingString:s];
            if(i == [self.morseCode length] - 1){
                if ([worldDic objectForKey:c]) {
                    match = [worldDic objectForKey:c];
                    self.appendLetterMorseCode = [self.appendLetterMorseCode stringByAppendingFormat:@"( %@ )", match];
                }
            }
            
        }
        
    }
    return self.appendLetterMorseCode;
}

-(void)morseToSound
{
    if (self.morseCode) {
        for (int i = 0; i < [self.morseCode length]; i++) {
            AudioServicesPlaySystemSound(1109);
        }
    }
}

-(void) morseToLight:(id)sender selectorOn:(SEL)selectorOn selectorOff:(SEL)selectorOff selectorFinished:(SEL)selectorFinished
{
    float totleTime;
    totleTime = 0.0;
    if ([self.morseCode length] > 0) {
        float time;
        NSString *s;
        BOOL off,skip;
        Led *led = [[Led alloc]init];
        NSDictionary *morseTimeDic = [self morseTimeDic];
        skip = NO;
        for (int i = 0; i < [self.morseCode length]; i++) {
            time = 0.0;
            off = NO;
            s = [self.morseCode substringWithRange:NSMakeRange(i, 1)];
            
            time = [[morseTimeDic objectForKey:s]floatValue];
            if ([s isEqualToString:self.morseSpace]) {
                off = YES;
            }
            
            if (!off) {
                [self.time addObject:[NSTimer scheduledTimerWithTimeInterval:totleTime target:led selector:@selector(turnOnLed) userInfo:nil repeats:NO]];
                if (sender) {
                    [self.time addObject:[NSTimer scheduledTimerWithTimeInterval:totleTime target:sender selector:selectorOn userInfo:nil repeats:NO]];
                }
                
            }
            
            totleTime += time;
            [self.time addObject:[NSTimer scheduledTimerWithTimeInterval:totleTime target:led selector:@selector(turnOffLed) userInfo:nil repeats:NO]];
            if (sender) {
                [self.time addObject:[NSTimer scheduledTimerWithTimeInterval:totleTime target:sender selector:selectorOff userInfo:nil repeats:NO]];
            }
            totleTime += self.unit;
        }
        if (sender) {
            [self.time addObject:[NSTimer scheduledTimerWithTimeInterval:totleTime target:sender selector:selectorFinished userInfo:nil repeats:NO]];
        }
    }
}

-(void)stopLight:(id)sender selectorOff:(SEL)selectorOff
{
    if ([self.time count] > 0) {
        for (id time in self.time) {
            [time invalidate];
        }
        self.time = nil;
        [[[Led alloc]init]turnOffLed];
        [sender performSelector:selectorOff];
    }
}



-(NSDictionary *)morseTimeDic
{
    NSNumber *dot = [NSNumber numberWithFloat:self.unit];
    NSNumber *dash = [NSNumber numberWithFloat:self.unit * 3];
    NSNumber *space = [NSNumber numberWithFloat:self.unit * 3];
    NSNumber *textSpace = [NSNumber numberWithFloat:self.unit * 7];
    NSDictionary *morseTime = @{@".":dot,
                                 @"-":dash,
                                 self.morseSpace:space,
                                 self.textSpace:textSpace};
    return morseTime;
}

-(NSDictionary *)morseDic
{
    NSDictionary *morse = @{@"a":@".-",
                            @"b":@"-...",
                            @"c":@"-.-.",
                            @"d":@"-..",
                            @"e":@".",
                            @"f":@"..-.",
                            @"g":@"--.",
                            @"h":@"....",
                            @"i":@"..",
                            @"j":@".---",
                            @"k":@"-.-",
                            @"l":@".-..",
                            @"m":@"--",
                            @"n":@"-.",
                            @"o":@"---",
                            @"p":@".--.",
                            @"q":@"--.-",
                            @"r":@".-.",
                            @"s":@"...",
                            @"t":@"-",
                            @"u":@"..-",
                            @"v":@"...-",
                            @"w":@".--",
                            @"x":@"-..-",
                            @"y":@"-.--",
                            @"z":@"--.-",
                            @"1":@".----",
                            @"2":@"..---",
                            @"3":@"...--",
                            @"4":@"....-",
                            @"5":@".....",
                            @"6":@"-....",
                            @"7":@"--...",
                            @"8":@"---..",
                            @"9":@"----.",
                            @"0":@"-----"};
    return morse;
}

-(NSDictionary *)worldDic
{
    NSDictionary *world = @{@".-":@"a",
                            @"-...":@"b",
                            @"-.-.":@"c",
                            @"-..":@"d",
                            @".":@"e",
                            @"..-.":@"f",
                            @"--.":@"g",
                            @"....":@"h",
                            @"..":@"i",
                            @".---":@"j",
                            @"-.-":@"k",
                            @".-..":@"l",
                            @"--":@"m",
                            @"-.":@"n",
                            @"---":@"o",
                            @".--.":@"p",
                            @"--.-":@"q",
                            @".-.":@"r",
                            @"...":@"s",
                            @"-":@"t",
                            @"..-":@"u",
                            @"...-":@"v",
                            @".--":@"w",
                            @"-..-":@"x",
                            @"-.--":@"y",
                            @"--.-":@"z",
                            @".----":@"1",
                            @"..---":@"2",
                            @"...--":@"3",
                            @"....-":@"4",
                            @".....":@"5",
                            @"-....":@"6",
                            @"--...":@"7",
                            @"---..":@"8",
                            @"----.":@"9",
                            @"-----":@"0"};
    return world;
}

@end