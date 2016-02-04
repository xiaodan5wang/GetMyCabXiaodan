//
//  LoginViewController.m
//  getMyCab
//
//  Created by Xiaodan Wang on 2/1/16.
//  Copyright © 2016 Xiaodan Wang. All rights reserved.
//

#import "LoginViewController.h"
#import "custRegiViewController.h"
#import "driverRegiViewController.h"

@interface LoginViewController ()
- (IBAction)signupButtonTapped:(id)sender;
- (IBAction)loginButtonTapped:(id)sender;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_tagFlag==1) {
        self.title=@"Welcome, customer!";
    }else {
        self.title=@"Welcome, driver!";
    }
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)signupButtonTapped:(id)sender {
    if (_tagFlag==1) {
        custRegiViewController * custVC = [self.storyboard instantiateViewControllerWithIdentifier:@"custRegiViewController"];
        [self.navigationController pushViewController:custVC animated:YES];
    } else {
        driverRegiViewController * driverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"driverRegiViewController"];
        [self.navigationController pushViewController:driverVC animated:YES];
    }
    
}

- (IBAction)loginButtonTapped:(id)sender {
}
@end
