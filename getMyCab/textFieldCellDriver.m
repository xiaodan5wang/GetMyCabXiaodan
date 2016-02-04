//
//  textFieldCellDriver.m
//  getMyCab
//
//  Created by Xiaodan Wang on 2/1/16.
//  Copyright © 2016 Xiaodan Wang. All rights reserved.
//

#import "textFieldCellDriver.h"

@implementation textFieldCellDriver

- (void)awakeFromNib {
    // Initialization code
    _showTextField.delegate=self;
    _showTextField.returnKeyType=UIReturnKeyDone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
