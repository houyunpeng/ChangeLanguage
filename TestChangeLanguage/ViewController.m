//
//  ViewController.m
//  TestChangeLanguage
//
//  Created by hyp on 2018/12/12.
//  Copyright © 2018年 hyp. All rights reserved.
//

#import "ViewController.h"
#import "SecViewController.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    LanguageSet(@"label_origin_text", {
        _label.text = text;
    });
    
    LanguageSet(@"btn_origin_text", {
        [_btn setTitle:text forState:UIControlStateNormal];
    });
}

-(void)dealloc
{
    
}

- (IBAction)changeLanguageAction:(UIButton*)sender {
    
    Lang.currentLang = sender.selected ? @"zh-CN" : @"en-US";
    
    sender.selected = !sender.selected;
    
    
    
}
- (IBAction)push:(id)sender {
    
    [self.navigationController pushViewController:SecViewController.new animated:YES];
    
}



@end
