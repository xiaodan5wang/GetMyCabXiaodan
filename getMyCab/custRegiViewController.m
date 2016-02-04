//
//  custRegiViewController.m
//  getMyCab
//
//  Created by Xiaodan Wang on 2/1/16.
//  Copyright © 2016 Xiaodan Wang. All rights reserved.
//

#import "custRegiViewController.h"
#import "textFieldCell.h"
@interface custRegiViewController () {
    textFieldCell * cell;
}

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,strong) NSArray * labelArray;
@property (nonatomic,strong) NSMutableArray * resultArray;
- (IBAction)submitButtonTapped:(id)sender;

@end

@implementation custRegiViewController

static bool emailIsGood=false;
static bool mobileIsGood=false;
static bool passwordIsGood=false;
static bool repeatPasswordIsGood=false;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"Back"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem=btnBack;
    
    self.title=@"Register for customer";
    _labelArray=@[@"Email",@"Mobile Number",@"Password",@"Repeat password"];
    _tableview.allowsSelection = NO;
    _resultArray=[[NSMutableArray alloc]init];
    
    _tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
# pragma mark- tableview datasource-
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
    cell.showLabel.text = _labelArray[indexPath.row];
    if (indexPath.row==2 || indexPath.row==3) {
        cell.showTextfield.secureTextEntry=true;
    }
    return cell;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _labelArray.count;
}

#pragma mark- tableview delegate-
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [cell.showTextfield becomeFirstResponder];
//}

#pragma mark- flags check-
- (void)formatCheck:(NSArray *)inputArray{
    NSString * emailStr=[NSString stringWithFormat:@"%@",_resultArray[0]];
    NSString * mobileStr=[NSString stringWithFormat:@"%@",_resultArray[1]];
    NSString * passwordStr=[NSString stringWithFormat:@"%@",_resultArray[2]];
    NSString * repeatPasswordStr=[NSString stringWithFormat:@"%@",_resultArray[3]];
    

    if ([emailStr rangeOfString:@"@"].location!=NSNotFound && [emailStr rangeOfString:@".com"].location!=NSNotFound) emailIsGood=true;
    NSCharacterSet *numberSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *nameSet = [NSCharacterSet characterSetWithCharactersInString:mobileStr];
    if (mobileStr.length==10 && [numberSet isSupersetOfSet:nameSet]) mobileIsGood=true;
    if (passwordStr.length>=5 && passwordStr.length<=10) passwordIsGood=true;
    if ([passwordStr isEqualToString:repeatPasswordStr]) repeatPasswordIsGood=true;
    
    NSString * problemStr= [[NSString alloc]init];
    if (!emailIsGood)  problemStr=[problemStr stringByAppendingString:@" Check email!"];
    if (!mobileIsGood)  problemStr=[problemStr stringByAppendingString:@" Check mobile number!"];
    if (!passwordIsGood)  problemStr=[problemStr stringByAppendingString:@" Check Password!"];
    if (!repeatPasswordIsGood)  problemStr=[problemStr stringByAppendingString:@" Two passwords are different!"];
    
    if (emailIsGood && mobileIsGood && passwordIsGood && repeatPasswordIsGood) {
        NSString * urlString = [NSString stringWithFormat:@"http://rjtmobile.com/ansari/regtest.php?username=%@&password=%@&mobile=%@",emailStr,passwordStr,mobileStr];
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Success!" message:urlString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Check format!" message:problemStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (IBAction)submitButtonTapped:(id)sender {
    
    emailIsGood=false;
    mobileIsGood=false;
    passwordIsGood=false;
    repeatPasswordIsGood=false;
    
    for (int i=0; i<_labelArray.count; i++) {
        NSIndexPath * indPath =[NSIndexPath indexPathForRow:i inSection:0];
        textFieldCell * localCell =[_tableview cellForRowAtIndexPath:indPath];
        _resultArray[i]=localCell.showTextfield.text;
    }
    [self formatCheck:_resultArray];
}

@end
