//
//  photoCellDriver.m
//  getMyCab
//
//  Created by Xiaodan Wang on 2/1/16.
//  Copyright © 2016 Xiaodan Wang. All rights reserved.
//

#import "photoCellDriver.h"

@implementation photoCellDriver

- (void)awakeFromNib {
    // Initialization code
    [self.showImage.layer setBorderWidth:1];
    [self.showImage.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.showImage.layer setCornerRadius:5.0f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
