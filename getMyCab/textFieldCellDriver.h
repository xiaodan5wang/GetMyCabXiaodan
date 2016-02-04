//
//  textFieldCellDriver.h
//  getMyCab
//
//  Created by Xiaodan Wang on 2/1/16.
//  Copyright © 2016 Xiaodan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface textFieldCellDriver : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@property (weak, nonatomic) IBOutlet UITextField *showTextField;

@end
