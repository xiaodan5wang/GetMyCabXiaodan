//
//  driverRegiViewController.m
//  getMyCab
//
//  Created by Xiaodan Wang on 2/1/16.
//  Copyright © 2016 Xiaodan Wang. All rights reserved.
//

#import "driverRegiViewController.h"
#import "textFieldCellDriver.h"
#import "photoCellDriver.h"

@interface driverRegiViewController ()  {
    textFieldCellDriver * cell;
    
}

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
- (IBAction)submitButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *dataPickerView;

@property (nonatomic) NSData *imageData; //store image data from the image picker controller
@property (nonatomic) NSString *selectedDate; //selected data from the date picker controller
@property (nonatomic) NSDateFormatter * dateFormatter;

@property (nonatomic,strong) NSArray * labelArray; //by default forming the label for all the cells
@property (nonatomic,strong) NSMutableDictionary * resultDict; //saving all the info from the textfields

@property (nonatomic) CLLocationManager *locationManager; //used to find the local coordinator
@property (nonatomic) CLGeocoder *geoCoder;
@property (nonatomic) CLPlacemark *placemaker; //use local coordinator to find the city

@end

@implementation driverRegiViewController

static bool nameIsGood=false;
static bool emailIsGood=false;
static bool mobileIsGood=false;
static bool passwordIsGood=false;
static bool repeatPasswordIsGood=false;
static bool VINIsGood=false;
static bool licenseIsGood=false;
static bool emergencyIsGood=false;
static bool DOBIsGood=false;
static bool eduIsGood=false;
static bool bloodIsGood=false;
static bool cityIsGood=false;
static bool photoIsGood=false;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"Back"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem=btnBack;
    
    
    self.title=@"Register for driver";
    _labelArray=@[@"Full name",@"Email",@"Mobile Number",@"Password",@"Repeat password",@"VIN",@"License",@"Emergency Contact",@"DOB",@"Education",@"Blood Group",@"City"];
    _tableview.allowsSelection = NO;

    _dataPickerView.hidden=true;
    _resultDict=[[NSMutableDictionary alloc]init];
    _imageData=[[NSData alloc]init];
    _locationManager=[[CLLocationManager alloc]init];
    _geoCoder=[[CLGeocoder alloc]init];
    _dateFormatter=[[NSDateFormatter alloc]init];
    _dateFormatter.dateFormat=@"MM-dd-YYYY";
    
    NSString * formatedDate=[_dateFormatter stringFromDate:[NSDate date]];
    _selectedDate= formatedDate;
    
    _tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

# pragma mark- tableview datasource-
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.row<_labelArray.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldCellDriver"];
        cell.showLabel.text = _labelArray[indexPath.row];
        cell.showTextField.tag=indexPath.row+1;
        cell.showTextField.delegate=self;
        cell.showTextField.text=[_resultDict valueForKey:[NSString stringWithFormat:@"%d",cell.showTextField.tag]];
        cell.buttonToAvoidTextfield.tag=(indexPath.row+1)*10;
    }else if (indexPath.row==_labelArray.count) {
        cell  = [tableView dequeueReusableCellWithIdentifier:@"photoCellDriver"];
        cell.showLabel.text = @"Photo";
    }
    if (indexPath.row==3 || indexPath.row==4) {
        cell.showTextField.secureTextEntry=true;
    }else if (indexPath.row!=12){
        cell.showTextField.secureTextEntry=false;
    }
    
    if (indexPath.row<8) cell.buttonToAvoidTextfield.enabled=false;
    else if(indexPath.row>=8 && indexPath.row<=11)cell.buttonToAvoidTextfield.enabled=true;
    return cell;
}
- (IBAction)buttonToAvoidTextFieldTapped:(id)sender {
    if ([sender tag]==90) {
        [self showDateView];
    }else if ([sender tag]==100){
        [self alertControllerForEducationQulification];
    }else if ([sender tag]==110){
        [self alertControllerForBloodGroupSelection];
    }else if ([sender tag]==120){
        [self startGettingLocation];
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _labelArray.count+1;
}

#pragma mark- textfield delegate-
- (void)textFieldDidBeginEditing:(UITextField *)textField{

    UITableViewCell *cellAll = (UITableViewCell *) [[textField superview] superview];
    [_tableview scrollToRowAtIndexPath:[_tableview indexPathForCell:cellAll] atScrollPosition:UITableViewScrollPositionTop animated:YES];

}

- (void)alertControllerForEducationQulification{
    NSIndexPath * eduIndPath =[NSIndexPath indexPathForRow:9 inSection:0];
    textFieldCellDriver * eduCell =[_tableview cellForRowAtIndexPath:eduIndPath];
    UIAlertController * alert= [UIAlertController alertControllerWithTitle:@"Select Education Level" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * edu1=[UIAlertAction actionWithTitle:@"High School" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        eduCell.showTextField.text=@"High School";
        [_resultDict setValue:eduCell.showTextField.text forKey:[NSString stringWithFormat:@"10"]];
    }];
    UIAlertAction * edu2=[UIAlertAction actionWithTitle:@"Bechalor" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        eduCell.showTextField.text=@"Bechalor";
        [_resultDict setValue:eduCell.showTextField.text forKey:[NSString stringWithFormat:@"10"]];
    }];
    UIAlertAction * edu3=[UIAlertAction actionWithTitle:@"Master" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        eduCell.showTextField.text=@"Master";
        [_resultDict setValue:eduCell.showTextField.text forKey:[NSString stringWithFormat:@"10"]];
    }];
    UIAlertAction * edu4=[UIAlertAction actionWithTitle:@"Doctor" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        eduCell.showTextField.text=@"Doctor";
        [_resultDict setValue:eduCell.showTextField.text forKey:[NSString stringWithFormat:@"10"]];
    }];
    [alert addAction:edu1];
    [alert addAction:edu2];
    [alert addAction:edu3];
    [alert addAction:edu4];
    [self presentViewController:alert animated:YES completion:nil];
    [self.view endEditing:NO];
}

- (void)alertControllerForBloodGroupSelection{
    NSIndexPath * bloodIndPath =[NSIndexPath indexPathForRow:10 inSection:0];
    textFieldCellDriver * bloodCell =[_tableview cellForRowAtIndexPath:bloodIndPath];
    UIAlertController * alert= [UIAlertController alertControllerWithTitle:@"Select Blood Group" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * blood1=[UIAlertAction actionWithTitle:@"A" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        bloodCell.showTextField.text=@"A";
        [_resultDict setValue:bloodCell.showTextField.text forKey:[NSString stringWithFormat:@"11"]];
    }];
    UIAlertAction * blood2=[UIAlertAction actionWithTitle:@"B" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        bloodCell.showTextField.text=@"B";
        [_resultDict setValue:bloodCell.showTextField.text forKey:[NSString stringWithFormat:@"11"]];
    }];
    UIAlertAction * blood3=[UIAlertAction actionWithTitle:@"AB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        bloodCell.showTextField.text=@"AB";
        [_resultDict setValue:bloodCell.showTextField.text forKey:[NSString stringWithFormat:@"11"]];
    }];
    UIAlertAction * blood4=[UIAlertAction actionWithTitle:@"O" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        bloodCell.showTextField.text=@"O";
        [_resultDict setValue:bloodCell.showTextField.text forKey:[NSString stringWithFormat:@"11"]];
    }];
    [alert addAction:blood1];
    [alert addAction:blood2];
    [alert addAction:blood3];
    [alert addAction:blood4];
    [self presentViewController:alert animated:YES completion:nil];
    [self.view endEditing:NO];
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    [_resultDict setValue:textField.text forKey:[NSString stringWithFormat:@"%d",textField.tag]];
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark- tableview delegate-
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<_labelArray.count) return 50;
    else return 120;
}


#pragma mark- imagePickerController-
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *img= info[UIImagePickerControllerOriginalImage];
//    _imageData = [[NSData alloc]init];
    _imageData = UIImagePNGRepresentation(img);
    NSIndexPath * photoIndPath =[NSIndexPath indexPathForRow:_labelArray.count inSection:0];
    photoCellDriver * photoCell = [_tableview cellForRowAtIndexPath:photoIndPath];
    [photoCell.showImage setImage:img];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openImagePickerController{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera ]) {
        picker.sourceType=UIImagePickerControllerSourceTypeCamera;
    }else
        picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)addPicTapped:(id)sender {
    [self openImagePickerController];
}

#pragma mark- date picker-
- (IBAction)setDateDone:(id)sender {
    _dataPickerView.hidden=true;
    NSIndexPath * dateIndPath =[NSIndexPath indexPathForRow:8 inSection:0];
    textFieldCellDriver * dateCell =[_tableview cellForRowAtIndexPath:dateIndPath];
    dateCell.showTextField.text=_selectedDate;
    [_resultDict setValue:_selectedDate forKey:[NSString stringWithFormat:@"%d",9]];
}
- (IBAction)setDateCancel:(id)sender {
    _dataPickerView.hidden=true;
}

- (IBAction)selectDate:(id)sender {
    NSString * formatedDate=[_dateFormatter stringFromDate:_datePicker.date];
    _selectedDate= formatedDate;
}

- (void)showDateView{
    _dataPickerView.hidden=false;
    [self.view endEditing:NO];
}

#pragma mark- get location city by coordinator-
- (void)startGettingLocation {
    [self.view endEditing:NO];
    _locationManager.delegate=self;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    [_locationManager requestAlwaysAuthorization];
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"fail to get location");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation * currentLocation = [locations lastObject];
    NSLog(@"current latitude is:%f current longitude is:%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    [_locationManager stopUpdatingLocation];
    [_geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error==nil && placemarks>0) {
            _placemaker = [placemarks lastObject];
            NSString * city= _placemaker.locality;
            [_resultDict setValue:city forKey:[NSString stringWithFormat:@"%d",12]];
            NSLog(@"%@",city);
            
            NSIndexPath * cityIndPath =[NSIndexPath indexPathForRow:11 inSection:0];
            textFieldCellDriver * cityCell = [_tableview cellForRowAtIndexPath:cityIndPath];
            
            cityCell.showTextField.text=[_resultDict valueForKey:[NSString stringWithFormat:@"%d",12]];
        } else   NSLog(@"%@", error.debugDescription);
    }];
}

#pragma mark- format check
-(void)formatCheck:(NSMutableDictionary *)dict{
    NSString * nameStr=[NSString stringWithFormat:@"%@",[dict valueForKey:@"1"]];
    NSString * emailStr=[NSString stringWithFormat:@"%@",[dict valueForKey:@"2"] ];
    NSString * mobileStr=[NSString stringWithFormat:@"%@",[dict valueForKey:@"3"] ];
    NSString * passwordStr=[NSString stringWithFormat:@"%@",[dict valueForKey:@"4"] ];
    NSString * repeatPasswordStr=[NSString stringWithFormat:@"%@",[dict valueForKey:@"5"] ];
    NSString * VINStr=[NSString stringWithFormat:@"%@",[dict valueForKey:@"6"] ];
    NSString * licenseStr=[NSString stringWithFormat:@"%@",[dict valueForKey:@"7"] ];
    NSString * emergencyStr=[NSString stringWithFormat:@"%@",[dict valueForKey:@"8"] ];
    NSString * DOBStr=[NSString stringWithFormat:@"%@",[dict valueForKey:@"9"] ];
    
    if (nameStr.length>=8) nameIsGood=true;
    if ([emailStr rangeOfString:@"@"].location!=NSNotFound && [emailStr rangeOfString:@".com"].location!=NSNotFound) emailIsGood=true;
    NSCharacterSet *numberSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *mobileSet = [NSCharacterSet characterSetWithCharactersInString:mobileStr];
    if (mobileStr.length==10 && [numberSet isSupersetOfSet:mobileSet]) mobileIsGood=true;
    if (passwordStr.length>=5 && passwordStr.length<=10) passwordIsGood=true;
    if ([passwordStr isEqualToString:repeatPasswordStr]) repeatPasswordIsGood=true;
    if (VINStr.length==17) VINIsGood=true;
    NSCharacterSet *licenseSet = [NSCharacterSet characterSetWithCharactersInString:licenseStr];
    if (licenseStr.length==9 && [numberSet isSupersetOfSet:licenseSet]) licenseIsGood=true;
    NSCharacterSet *emergencySet = [NSCharacterSet characterSetWithCharactersInString:emergencyStr];
    if (emergencyStr.length==10 && [numberSet isSupersetOfSet:emergencySet]) emergencyIsGood=true;
    NSString * formatedDate=[_dateFormatter stringFromDate:[NSDate date]];
    NSString * todayDate=formatedDate;
    NSString * todayYear=[todayDate componentsSeparatedByString:@"-"][2];
    NSString * todayMonth=[todayDate componentsSeparatedByString:@"-"][0];
    NSString * todayDay=[todayDate componentsSeparatedByString:@"-"][1];
    NSString * birthDate=DOBStr;
    if ([dict valueForKey:@"9"]){//birthDate.length!=0){
    NSString * birthYear=[birthDate componentsSeparatedByString:@"-"][2];
    NSString * birthMonth=[birthDate componentsSeparatedByString:@"-"][0];
    NSString * birthDay=[birthDate componentsSeparatedByString:@"-"][1];
        if ([todayYear intValue]-18>[birthYear intValue]) DOBIsGood=true;
        else if ([todayYear intValue]-18==[birthYear intValue] && [todayMonth intValue]>[birthMonth intValue]) DOBIsGood=true;
        else if ([todayYear intValue]-18==[birthYear intValue] && [todayMonth intValue]==[birthMonth intValue] && [todayDay intValue]>[birthDay intValue]) DOBIsGood=true;
    }
    if ([dict valueForKey:@"9"]!=nil) eduIsGood=true;
    if ([dict valueForKey:@"10"]!=nil) bloodIsGood=true;
    if ([dict valueForKey:@"11"]!=nil) cityIsGood=true;
//    if (!_imageData && true) photoIsGood=true;
    if (_imageData.length >0) photoIsGood=true;
    
    NSString * problemStr= [[NSString alloc]init];
    if (!nameIsGood) problemStr=[problemStr stringByAppendingString:@" Name requires 8 digit!\n"];
    if (!emailIsGood)  problemStr=[problemStr stringByAppendingString:@" Invalid email!\n"];
    if (!mobileIsGood)  problemStr=[problemStr stringByAppendingString:@" Phone number requires 8 digit!\n"];
    if (!passwordIsGood)  problemStr=[problemStr stringByAppendingString:@" Password requires 5-10 digit!\n"];
    if (!repeatPasswordIsGood)  problemStr=[problemStr stringByAppendingString:@" Two passwords are different!\n"];
    if (!VINIsGood)  problemStr=[problemStr stringByAppendingString:@" VIN requires 17 digit\n"];
    if (!licenseIsGood) problemStr=[problemStr stringByAppendingString:@" Invalid license number!\n"];
    if (!emergencyIsGood)  problemStr=[problemStr stringByAppendingString:@" Emergency contact requires 10 digit!\n"];
    if (!DOBIsGood)  problemStr=[problemStr stringByAppendingString:@" You are too young!\n"];
    if (!eduIsGood)  problemStr=[problemStr stringByAppendingString:@" Please select EDU level!\n"];
    if (!bloodIsGood)  problemStr=[problemStr stringByAppendingString:@" Please select blood group!\n"];
    if (!cityIsGood)   problemStr=[problemStr stringByAppendingString:@" Please let system find your city!\n"];
    if (!photoIsGood)  problemStr=[problemStr stringByAppendingString:@" Please upload photo!\n"];

    if (nameIsGood&&emailIsGood&&mobileIsGood&&passwordIsGood&&repeatPasswordIsGood&&VINIsGood&&licenseIsGood&&emergencyIsGood&&DOBIsGood&&eduIsGood&&bloodIsGood&&cityIsGood&&photoIsGood) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Success!" message:@"Register successful. Will return to the login page" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:[self getURLRequestForRegistration] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSString* respondStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self loginStatus:respondStr];
                });
            }
        }] resume];

        
        
    }else {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Check format!" message:problemStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSURLRequest *)getURLRequestForRegistration{
    NSString *urlText=[NSString stringWithFormat:@"http://rjtmobile.com/ansari/regtestdriver.php?name=%@&email=%@&mobile=%@&password=%@&vechile=%@&license=%@&city=%@",[_resultDict valueForKey:@"1"],[_resultDict valueForKey:@"2"],[_resultDict valueForKey:@"3"],[_resultDict valueForKey:@"4"],[_resultDict valueForKey:@"6"],[_resultDict valueForKey:@"7"],[_resultDict valueForKey:@"12"]];
    urlText=[urlText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url=[NSURL URLWithString:urlText];
//    NSURL * url=[NSURL URLWithString:[NSString stringWithFormat:@"http://rjtmobile.com/ansari/regtestdriver.php?name=%@&email=%@&mobile=%@&password=%@&vechile=%@&license=%@&city=%@",[_resultDict valueForKey:@"1"],[_resultDict valueForKey:@"2"],[_resultDict valueForKey:@"3"],[_resultDict valueForKey:@"4"],[_resultDict valueForKey:@"6"],[_resultDict valueForKey:@"7"],[_resultDict valueForKey:@"12"]]];
    NSMutableURLRequest * urlRequest=[NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:180];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    return urlRequest;
}

- (void)loginStatus:(NSString*)string{
    NSLog(@"response string from server:%@",string);
}


#pragma mark- submit-
- (IBAction)submitButtonTapped:(id)sender {
    NSLog(@"result %@",_resultDict);
    [self formatCheck:_resultDict];
}
@end
