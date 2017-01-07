//
//  KoreaPickerView.m
//  AreaPickerView
//
//  Created by Zhuochenming on 2016/12/27.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import "KoreaPickerView.h"

static CGFloat const TopToobarHeight = 40.0;

@interface AreaModel : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *code;

@end

@implementation AreaModel

@end


static NSMutableArray *provinceArray;

static NSMutableArray *cityArray;



@interface KoreaPickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign) UIPickerView *pickerView;

@property (nonatomic, assign) id<KoreaPickerViewDelegate> delegate;

@property (nonatomic, assign) NSInteger selectedWhichRow;

@property (nonatomic, assign) UIView *bacView;

@end

@implementation KoreaPickerView

- (instancetype)initWithTitle:(NSString *)title delegate:(id<KoreaPickerViewDelegate>) delegate {
    if (self = [super init]) {
        
        self.delegate = delegate;
        
        self.backgroundColor = [UIColor whiteColor];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"koreaCity.json" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
            NSArray *jsonArray = [self toArrayOrNSDictionary:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
            
            provinceArray = [NSMutableArray array];
            
            cityArray = [NSMutableArray array];

            for (NSInteger i = 0; i < jsonArray.count; i++) {
                NSDictionary *proDic = jsonArray[i];
                AreaModel *proModel = [AreaModel new];
                proModel.name = proDic[@"name"];
                proModel.code = proDic[@"code"];
                [provinceArray addObject:proModel];
                
                NSArray *citys = proDic[@"list"];
                
                NSMutableArray *mArray = [NSMutableArray array];
                for (NSInteger j = 0; j < citys.count; j++) {
                    AreaModel *cityModel = [AreaModel new];
                    
                    NSDictionary *cityDic = citys[j];
                    cityModel.name = cityDic[@"name"];
                    cityModel.code = cityDic[@"code"];
                    [mArray addObject:cityModel];
                }
                [cityArray addObject:mArray];
            }
        });
        
        
        CGFloat kWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        
        UIPickerView *locatePicker = [[UIPickerView alloc] init];
        
        CGRect pickerFrame = locatePicker.frame;
        pickerFrame.origin.y = TopToobarHeight;
        pickerFrame.size.width = kWidth;
        locatePicker.frame = pickerFrame;
        
        locatePicker.backgroundColor = [UIColor whiteColor];
        locatePicker.dataSource = self;
        locatePicker.delegate = self;
        [self addSubview:locatePicker];
        _pickerView = locatePicker;
        
        [self toolBarUIWithTitle:title];
    }
    return self;
}

// 将JSON串转化为字典或者数组
- (id)toArrayOrNSDictionary:(NSData *)jsonData {
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    if (jsonObject != nil && error == nil){
        return jsonObject;
    } else {
        return nil;
    }
}

- (void)toolBarUIWithTitle:(NSString *)title {
    CGFloat height = CGRectGetHeight(_pickerView.frame) + TopToobarHeight;
    CGFloat top = CGRectGetHeight([UIScreen mainScreen].bounds) - height;
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, top, width, height);
    
    CGFloat buttonWidth = 50;
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(20, 0, buttonWidth, TopToobarHeight);
    [leftButton setTitle:@"취소" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithRed:49 / 255.0 green:50 / 255.0 blue:50 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [leftButton addTarget:self action:@selector(cancelPicker) forControlEvents:UIControlEventTouchUpInside];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:leftButton];
    
    CGFloat left = (CGRectGetWidth(self.frame) - 150) / 2.0;
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(left, 0, 150, TopToobarHeight)];
    lable.text = title;
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor colorWithRed:171 / 255.0 green:170 / 255.0 blue:170 / 255.0 alpha:1.0];
    lable.font = [UIFont systemFontOfSize:14];
    
    [self addSubview:lable];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 20 - buttonWidth, 0, buttonWidth, TopToobarHeight);
    [rightButton setTitle:@"확인" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithRed:49 / 255.0 green:50 / 255.0 blue:50 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:rightButton];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, TopToobarHeight - 0.5, width, 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:242 / 255.0 green:242 / 255.0 blue:242 / 255.0 alpha:242 / 255.0];
    [self addSubview:lineView];
}

#pragma mark - pickerView代理
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (_type == 0) {
        return provinceArray.count;
    } else {
        NSMutableArray *modelArray = cityArray[_whichProvince];
        return modelArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (_type == 0) {
        AreaModel *model = provinceArray[row];
        return model.name;
    } else {
        NSMutableArray *modelArray = cityArray[_whichProvince];
        AreaModel *model = modelArray[row];
        return model.name;
    }
}

#pragma mark - 定制
- (void)pickerViewSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.pickerView selectRow:row inComponent:component animated:YES];
    [self.pickerView reloadComponent:component];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 200;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    UILabel *lable = [[UILabel alloc] init];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.frame = CGRectMake(0.0, 0.0, 200, 30);
    lable.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    lable.font = [UIFont systemFontOfSize:14];
    return lable;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedWhichRow = row;
}

- (void)selectDefaultRow:(NSInteger)row {
    
}

- (void)showInView:(UIView *)view {
    
    [self.pickerView reloadAllComponents];

    UIView *bacView = [[UIView alloc] initWithFrame:view.frame];
    bacView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [bacView addSubview:self];
    [view addSubview:bacView];
    _bacView = bacView;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)doneClick {
    if (_type == 0) {
        AreaModel *model = provinceArray[_selectedWhichRow];
        [self.delegate pickerViewSelectAreaOfCode:model.code name:model.name whichProvince:_selectedWhichRow];
    } else {
        NSMutableArray *modelArray = cityArray[_whichProvince];
        AreaModel *model = modelArray[_selectedWhichRow];
        [self.delegate pickerViewSelectAreaOfCode:model.code name:model.name whichProvince:_selectedWhichRow];
    }
    [self cancelPicker];
}

- (void)cancelPicker {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished){
        [self.bacView removeFromSuperview];
    }];
}

@end
