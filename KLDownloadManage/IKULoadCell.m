//
//  IKULoadCell.m
//  AIKU
//
//  Created by Glen on 13-12-16.
//  Copyright (c) 2013年 koolearn. All rights reserved.
//

#import "IKULoadCell.h"

@implementation IKULoadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(200, 15, 40, 20)];
        [_progressLabel setBackgroundColor:[UIColor clearColor]];
        [_progressLabel setFont:[UIFont systemFontOfSize:10.f]];
        [_progressLabel setTextColor:[UIColor whiteColor]];
        [_progressLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_progressLabel];
        
        self.totalLabel = [[UILabel alloc]initWithFrame:CGRectMake(240, 15, 50, 20)];
        [self.totalLabel setBackgroundColor:[UIColor clearColor]];
        [self.totalLabel setFont:[UIFont systemFontOfSize:10.f]];
        [self.totalLabel setUserInteractionEnabled:NO];
        [self addSubview:self.totalLabel];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,15,182, 20)];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:13.f]];
        [self.titleLabel setUserInteractionEnabled:NO];
        [self addSubview:self.titleLabel];
        
        self.accessButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.accessButton setFrame:CGRectMake(0, 0, 40, 60)];
        [self.accessButton setCenter:CGPointMake(self.frame.size.width-20,30)];
        [self.accessButton addTarget:self action:@selector(onClickedAccessButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.accessButton];
        
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(15, 40, 536/2, 5)];
        [_progressView setProgress:0.0];
        [self addSubview:_progressView];
    }
    return self;
}

- (void)onClickedAccessButtonAction:(id)sender
{
//    [super onClickedAccessButtonAction:sender];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
