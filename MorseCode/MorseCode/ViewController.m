//
//  ViewController.m
//  MorseCode
//
//  Created by jodg on 14/12/18.
//  Copyright (c) 2014年 weibolabs. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) ADBannerView *adView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    self.adView.delegate = self;
    float adViewHeight;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version < 7.0f) {
        adViewHeight = 0;
    }else{
        adViewHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    self.adView.frame = CGRectOffset(self.adView.frame,
                                     0,
                                     adViewHeight);
    [self.view addSubview:self.adView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
}

@end
