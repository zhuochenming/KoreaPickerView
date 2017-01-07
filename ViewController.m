//
//  ViewController.m
//  KoreaPickerView
//
//  Created by Zhuochenming on 2017/1/7.
//  Copyright © 2017年 Zhuochenming. All rights reserved.
//

#import "ViewController.h"
#import "KoreaPickerView.h"

@interface ViewController ()<KoreaPickerViewDelegate>

@property (nonatomic, assign) BOOL isChanged;

@property (nonatomic, assign) NSInteger whichProvince;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"韩国选择器";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 100, 30);
    button.backgroundColor = [UIColor redColor];
    button.center = self.view.center;
    [button addTarget:self action:@selector(buttonTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)buttonTouch {
    _isChanged = !_isChanged;
    if (_isChanged) {
        KoreaPickerView *view = [[KoreaPickerView alloc] initWithTitle:@"biaoge" delegate:self];
        view.type = 0;
        view.whichProvince = _whichProvince;
        [view showInView:self.view];
    } else {
        KoreaPickerView *view = [[KoreaPickerView alloc] initWithTitle:@"biaoge" delegate:self];
        view.type = 1;
        [view showInView:self.view];
    }
}

- (void)pickerViewSelectAreaOfCode:(NSString *)code name:(NSString *)name whichProvince:(NSInteger)whichProvince {
    self.whichProvince = whichProvince;
    NSLog(@"%@, %@, %ld", code, name, whichProvince);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
