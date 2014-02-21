//
//  IKULoadCell.h
//  AIKU
//
//  Created by Glen on 13-12-16.
//  Copyright (c) 2013年 koolearn. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface IKULoadCell :UITableViewCell
@property (nonatomic , strong) UIProgressView *progressView;
@property (nonatomic , strong) UILabel *progressLabel;
@property (nonatomic , strong) UILabel *totalLabel;
@property (nonatomic , strong) UILabel *titleLabel;
@property (nonatomic , strong) UIButton *accessButton;
@end
