//
//  KoreaPickerView.h
//  AreaPickerView
//
//  Created by Zhuochenming on 2016/12/27.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KoreaPickerViewDelegate <NSObject>

@required
- (void)pickerViewSelectAreaOfCode:(NSString *)code name:(NSString *)name whichProvince:(NSInteger)whichProvince;

@end

@interface KoreaPickerView : UIView

- (instancetype)initWithTitle:(NSString *)title delegate:(id<KoreaPickerViewDelegate>) delegate;

/**  type == 0 选择省份；type == 1 选择城市
 *
 *  whichProvince 是选择过的省份 选择城市的时候要先选城市
 *
 **/
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger whichProvince;

- (void)showInView:(UIView *)view;

@end
