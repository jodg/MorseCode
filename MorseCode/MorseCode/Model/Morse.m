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
@property   (nonatomic) uint64_t send_time;
@property   (nonatomic) uint64_t wait_time;
@property   (nonatomic) uint64_t unit_time;
@property   (strong,nonatomic)  NSString *last_match;
@end

@implementation Morse

-(instancetype)init
{
    self = [super init];
    self.unit = 0.4;
    self.unit_input = self.unit * 1000;
    self.range_unit_input = self.unit/2*1000;
    return self;
}

-(void)reset
{
    self.last_match = @"";
    self.wait_time = 0;
    self.send_time = 0;
    self.unit_time = 0;
    self.morse_code = @"";
    self.last_match = @"";
    self.text = @"";
}

-(NSMutableArray *)time
{
    if (!_time) {
        _time = [[NSMutableArray alloc]init];
    }
    return _time;
}

-(NSString *)append_letter_morse_code
{
    if(!_append_letter_morse_code) _append_letter_morse_code = @"";
    return _append_letter_morse_code;
}

-(NSString *)text
{
    if(!_text) _text = nil;
    return _text;
}

-(NSString *)last_match
{
    if(!_last_match) _last_match = @"";
    return _last_match;
}

-(NSString *)morse_code
{
    if(!_morse_code) _morse_code = @"";
    return _morse_code;
}

-(NSString *)text_space
{
    if(!_text_space) _text_space = @"\n";
    return _text_space;
}

-(NSString *)morse_space
{
    if(!_morse_space) _morse_space = @" ";
    return _morse_space;
}

-(uint64_t)sysTime{
    return [[NSDate date] timeIntervalSinceReferenceDate]*1000;
}

-(void)down
{
    self.send_time = [self sysTime];
    //    NSLog(@"send_time: %llu",self.send_time);
    if (self.wait_time) {
        NSString *match;
        self.wait_time = [self sysTime] - self.wait_time;
        match = [self matchMorseSpace];
        
        if (match) {
            //            NSLog(@"last_match %@",self.last_match);
            if ([self.last_match isEqualToString:self.morse_space] || [self.last_match isEqualToString:self.text_space]) {
                //                NSLog(@"1 morse_code %@",self.morse_code);
                if ([self.morse_code length] > 0) {
                    self.morse_code = [self.morse_code substringToIndex:[self.morse_code length] - 1];
                }
                //                NSLog(@"2 morse_code %@",self.morse_code);
                if ([match isEqualToString:self.text_space] || [self.last_match isEqualToString:self.text_space]){
                    match = self.text_space;
                }else{
                    match = self.morse_space;
                }
            }
            self.last_match = match;
            self.morse_code = [self.morse_code stringByAppendingFormat:@"%@",match];
        }
    }
}

-(void)up
{
    NSString *match;
    self.send_time = [self sysTime] - self.send_time;
    self.wait_time = [self sysTime];
    [self countUnit];
    
    match = [self matchMorseChat];
    if (match) {
        self.last_match = match;
        self.morse_code = [self.morse_code stringByAppendingFormat:@"%@",match];
    }
}

-(NSString *)matchMorseSpace
{
    NSString *match;
    match = nil;
    //    NSLog(@"matchMorseSpace wait_time: %llu,unit_time: %llu",self.wait_time,self.unit_time);
    if (self.unit_time * 3 + self.range_unit_input <= self.wait_time && self.wait_time <= self.unit_time * 7 - self.range_unit_input) {
        match = self.morse_space;
    }else if (self.unit_time * 8 + self.range_unit_input <= self.wait_time){
        match = self.text_space;
    }
    return match;
}

-(NSString *)matchMorseChat
{
    //    NSLog(@"matchMorseChat send_time: %llu,unit_time: %llu",self.send_time,self.unit_time);
    NSString *match;
    match = nil;
    if (self.unit_time - self.range_unit_input <= self.send_time && self.send_time <= self.unit_time + self.range_unit_input) {
        match = @".";
    }else if (self.unit_time * 3 - self.range_unit_input <= self.send_time){
        match =  @"-";
    }
    return match;
}

-(void)countUnit
{
    uint64_t last_unit_time;
    
    if (self.unit_time == 0) {
        self.morse_code = @"";
        //        self.touch_times = 1;
        last_unit_time = self.unit_input;
    }else{
        if (self.unit_time < self.range_unit_input) {
            self.unit_time = self.range_unit_input;
        }
        last_unit_time = self.unit_time;
    }
    //    NSLog(@"countUnitTime last_unit_time: %llu,unit_time: %llu",last_unit_time,self.unit_time);
    
    if (last_unit_time - self.range_unit_input <= self.send_time && self.send_time <= last_unit_time + self.range_unit_input) {
        
        self.unit_time = self.send_time;
        
    }else if(self.send_time > last_unit_time + self.range_unit_input){
        if (self.unit_time == 0) {
            
            self.unit_time = last_unit_time * 3 ;
            
        }
    }
    //    NSLog(@"countUnitTime last_unit_time: %d,unit_time: %d",last_unit_time,self.unit_time);
    //    self.unit_time = (last_unit_time + self.unit_time) / 2;
}

-(NSString *)textToMorseCode
{
    self.morse_code = @"";
    if ([self.text length] > 0) {
        BOOL end = NO;
        NSString *space,*c;
        NSDictionary *morseDic = [self morseDic];
        for (int i = 0; i < [self.text length]; i++) {
            NSString *s = [self.text substringWithRange:NSMakeRange(i, 1)];
            c = space = @"";
            NSString *s_low = [s lowercaseString];
            if ([morseDic objectForKey:s_low]) {
                c = [morseDic objectForKey:s_low];
                space = self.morse_space;
            }else if([s isEqualToString:@" "]){
                c = self.text_space;
                end = YES;
            }
            if (c) {
                self.morse_code = [self.morse_code stringByAppendingFormat:@"%@%@",space,c];
            }
        }
        
        if([[self.morse_code
             substringWithRange:NSMakeRange(0, 1)]
            isEqualToString:self.morse_space]){
            self.morse_code = [self.morse_code substringFromIndex:1];
        }
    }
    
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //    AudioServicesPlaySystemSound(1109);
    return self.morse_code;
}

-(NSString *)MorseCodeToText
{
    self.text = @"";
    if([self.morse_code length] > 0){
        NSString *match,*c;
        NSDictionary *worldDic = [self worldDic];
        c = match = @"";
        for (int i = 0; i < [self.morse_code length]; i++) {
            
            NSString *s = [self.morse_code substringWithRange:NSMakeRange(i, 1)];
            
            if([s isEqualToString:self.morse_space]){
                if ([worldDic objectForKey:c]) {
                    match = [worldDic objectForKey:c];
                    self.text = [self.text stringByAppendingString:match];
                    //                    NSLog(@"text %@", self.text);
                }
                c = @"";
                continue;
            }else if ([s isEqualToString:self.text_space]) {
                if ([worldDic objectForKey:c]) {
                    match = [worldDic objectForKey:c];
                    self.text = [self.text stringByAppendingString:match];
                    //                    NSLog(@"text %@", self.text);
                }
                self.text = [self.text stringByAppendingString:self.morse_space];
                c = @"";
                continue;
            }
            
            c = [c stringByAppendingString:s];
            
            if(i == [self.morse_code length] - 1){
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
    self.append_letter_morse_code = @"";
    if([self.morse_code length] > 0){
        NSString *match,*c;
        NSDictionary *worldDic = [self worldDic];
        c = match = @"";
        for (int i = 0; i < [self.morse_code length]; i++) {
            NSString *s = [self.morse_code substringWithRange:NSMakeRange(i, 1)];
            
            if([s isEqualToString:self.morse_space]){
                if ([worldDic objectForKey:c]) {
                    match = [worldDic objectForKey:c];
                    self.append_letter_morse_code = [self.append_letter_morse_code stringByAppendingFormat:@"( %@ )%@", match,s];
                }
                c = @"";
            }else if ([s isEqualToString:self.text_space]) {
                if ([worldDic objectForKey:c]) {
                    match = [worldDic objectForKey:c];
                    self.append_letter_morse_code = [self.append_letter_morse_code stringByAppendingFormat:@"( %@ )%@", match,s];
                }
                c = @"";
            }else{
                c = [c stringByAppendingString:s];
            }
            
            self.append_letter_morse_code = [self.append_letter_morse_code stringByAppendingString:s];
            if(i == [self.morse_code length] - 1){
                if ([worldDic objectForKey:c]) {
                    match = [worldDic objectForKey:c];
                    self.append_letter_morse_code = [self.append_letter_morse_code stringByAppendingFormat:@"( %@ )", match];
                }
            }
            
        }
        
    }
    return self.append_letter_morse_code;
}

-(void)morseToSound
{
    if (self.morse_code) {
        for (int i = 0; i < [self.morse_code length]; i++) {
            AudioServicesPlaySystemSound(1109);
        }
    }
}

-(void) morseToLight:(id)sender selectorOn:(SEL)selectorOn selectorOff:(SEL)selectorOff
{
    float totle_time;
    totle_time = 0.0;
    if ([self.morse_code length] > 0) {
        float time;
        NSString *s;
        BOOL off,skip;
        Led *led = [[Led alloc]init];
        NSDictionary *morseTimeDic = [self morseTimeDic];
        skip = NO;
        for (int i = 0; i < [self.morse_code length]; i++) {
            time = 0.0;
            off = NO;
            s = [self.morse_code substringWithRange:NSMakeRange(i, 1)];
            
            time = [[morseTimeDic objectForKey:s]floatValue];
            if ([s isEqualToString:self.morse_space]) {
                off = YES;
            }
            
            if (!off) {
                [self.time addObject:[NSTimer scheduledTimerWithTimeInterval:totle_time target:led selector:@selector(turnOnLed) userInfo:nil repeats:NO]];
                if (sender) {
                    [self.time addObject:[NSTimer scheduledTimerWithTimeInterval:totle_time target:sender selector:selectorOn userInfo:nil repeats:NO]];
                }
                
            }
            
            totle_time += time;
            [self.time addObject:[NSTimer scheduledTimerWithTimeInterval:totle_time target:led selector:@selector(turnOffLed) userInfo:nil repeats:NO]];
            if (sender) {
                [self.time addObject:[NSTimer scheduledTimerWithTimeInterval:totle_time target:sender selector:selectorOff userInfo:nil repeats:NO]];
            }
            totle_time += self.unit;
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
    NSNumber *t_space = [NSNumber numberWithFloat:self.unit * 7];
    NSDictionary *morse_time = @{@".":dot,
                                 @"-":dash,
                                 self.morse_space:space,
                                 self.text_space:t_space};
    return morse_time;
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