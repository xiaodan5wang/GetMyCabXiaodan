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
#import "MapViewController.h"

@interface LoginViewController ()
- (IBAction)signupButtonTapped:(id)sender;
- (IBAction)loginButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;

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
 
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getURLRequestForRegistration] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSString* respondStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self loginStatus:respondStr];
            });
        }
    }] resume];

}

- (NSURLRequest *)getURLRequestForRegistration{
    NSURL * url;
    if (_tagFlag==1) {
        url=[NSURL URLWithString:[NSString stringWithFormat:@"http://rjtmobile.com/ansari/dbConnect.php?mobile=%@&password=%@",_usernameTextfield.text,_passwordTextfield.text]];
    }else {
        url=[NSURL URLWithString:[NSString stringWithFormat:@"http://rjtmobile.com/ansari/driver_login.php?mobile=%@&password=%@",_usernameTextfield.text,_passwordTextfield.text]];
    }
    
    NSMutableURLRequest * urlRequest=[NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:180];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    return urlRequest;
}

- (void)loginStatus:(NSString*)string{
    NSLog(@"response string from server:%@",string);
    if ([string isEqualToString:@"success"]) {
        MapViewController * mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
        [self.navigationController pushViewController:mapVC animated:YES];
    }
}

@end
