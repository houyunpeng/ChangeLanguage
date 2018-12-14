//
//  SecViewController.m
//  ChangeLanguage
//
//  Created by hyp on 2018/12/14.
//  Copyright © 2018年 hyp. All rights reserved.
//

#import "SecViewController.h"

@interface SecViewController ()

@end

@implementation SecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    UILabel* label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.center = CGPointMake(CGRectGetMidX(self.view.frame), 100);
    label.bounds = CGRectMake(0, 0, 180, 40);
    [self.view addSubview:label];
    LanguageSet(@"label_origin_text", {
        label.text = text;
    })
    
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.center = CGPointMake(CGRectGetMidX(self.view.frame), 160);
    btn.bounds = CGRectMake(0, 0, 180, 40);
    [btn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [self.view addSubview:btn];
    LanguageSet(@"btn_origin_text", {
        [btn setTitle:text forState:UIControlStateNormal];
    })
    
    
    UIButton* changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeBtn.center = CGPointMake(CGRectGetMidX(self.view.frame), 250);
    changeBtn.bounds = CGRectMake(0, 0, 180, 40);
    [self.view addSubview:changeBtn];
    [changeBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [changeBtn setTitle:@"change language" forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];

    
    
}
-(void)click:(UIButton*)sender
{
    Lang.currentLang = sender.selected ? @"zh-CN" : @"en-US";
    sender.selected = !sender.selected;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.navigationController pushViewController:SecViewController.new animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
