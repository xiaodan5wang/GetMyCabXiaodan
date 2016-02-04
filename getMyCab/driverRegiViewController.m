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
    }else if (indexPath.row==_labelArray.count) {
        cell  = [tableView dequeueReusableCellWithIdentifier:@"photoCellDriver"];
        cell.showLabel.text = @"Photo";
    }
    if (indexPath.row==3 || indexPath.row==4) {
        cell.showTextField.secureTextEntry=true;
    }
    return cell;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _labelArray.count+1;
}

#pragma mark- textfield delegate-
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag==9) {
        _dataPickerView.hidden=false;
        [textField resignFirstResponder];
        UITableViewCell *cell = (UITableViewCell *) [textField superview];
        [_tableview scrollToRowAtIndexPath:[_tableview indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }else if (textField.tag==10) {
        UIAlertController * alert= [UIAlertController alertControllerWithTitle:@"Select Education Level" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction * edu1=[UIAlertAction actionWithTitle:@"High School" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            textField.text=@"High School";
            [_resultDict setValue:textField.text forKey:[NSString stringWithFormat:@"10"]];
        }];
        UIAlertAction * edu2=[UIAlertAction actionWithTitle:@"Bechalor" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            textField.text=@"Bechalor";
            [_resultDict setValue:textField.text forKey:[NSString stringWithFormat:@"10"]];
        }];
        UIAlertAction * edu3=[UIAlertAction actionWithTitle:@"Master" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            textField.text=@"Master";
            [_resultDict setValue:textField.text forKey:[NSString stringWithFormat:@"10"]];
        }];
        UIAlertAction * edu4=[UIAlertAction actionWithTitle:@"Doctor" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            textField.text=@"Doctor";
            [_resultDict setValue:textField.text forKey:[NSString stringWithFormat:@"10"]];
        }];
        [alert addAction:edu1];
        [alert addAction:edu2];
        [alert addAction:edu3];
        [alert addAction:edu4];
        [self presentViewController:alert animated:YES completion:nil];
        [textField resignFirstResponder];
    }else if (textField.tag==11){
        
        UIAlertController * alert= [UIAlertController alertControllerWithTitle:@"Select Blood Group" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction * blood1=[UIAlertAction actionWithTitle:@"A" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            textField.text=@"A";
            [_resultDict setValue:textField.text forKey:[NSString stringWithFormat:@"11"]];
        }];
        UIAlertAction * blood2=[UIAlertAction actionWithTitle:@"B" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            textField.text=@"B";
            [_resultDict setValue:textField.text forKey:[NSString stringWithFormat:@"11"]];
        }];
        UIAlertAction * blood3=[UIAlertAction actionWithTitle:@"AB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            textField.text=@"AB";
            [_resultDict setValue:textField.text forKey:[NSString stringWithFormat:@"11"]];
        }];
        UIAlertAction * blood4=[UIAlertAction actionWithTitle:@"O" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            textField.text=@"O";
            [_resultDict setValue:textField.text forKey:[NSString stringWithFormat:@"11"]];
        }];
        [alert addAction:blood1];
        [alert addAction:blood2];
        [alert addAction:blood3];
        [alert addAction:blood4];
        [self presentViewController:alert animated:YES completion:nil];
        [textField resignFirstResponder];
    }else if (textField.tag==12) {
        [self startGettingLocation];
        [textField resignFirstResponder];
    }
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

#pragma mark- get location city by coordinator-
- (void)startGettingLocation {
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
    NSString * eduStr=[NSString stringWithFormat:@"%@",[dict valueForKey:@"10"] ];
    NSString * bloodStr=[NSString stringWithFormat:@"%@",[dict valueForKey:@"11"] ];
    NSString * cityStr=[NSString stringWithFormat:@"%@",[dict valueForKey:@"12"] ];
    
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
    if (licenseStr.length==10 && [numberSet isSupersetOfSet:emergencySet]) emergencyIsGood=true;
    NSString * formatedDate=[_dateFormatter stringFromDate:[NSDate date]];
    NSString * todayDate=formatedDate;
    NSString * todayYear=[todayDate componentsSeparatedByString:@"-"][2];
    NSString * todayMonth=[todayDate componentsSeparatedByString:@"-"][0];
    NSString * todayDay=[todayDate componentsSeparatedByString:@"-"][1];
    NSString * birthDate=DOBStr;
    if (birthDate.length==0) birthDate=todayDate;
    NSString * birthYear=[birthDate componentsSeparatedByString:@"-"][2];
    NSString * birthMonth=[birthDate componentsSeparatedByString:@"-"][0];
    NSString * birthDay=[birthDate componentsSeparatedByString:@"-"][1];
    if ([todayYear intValue]-18>[birthYear intValue]) DOBIsGood=true;
    else if ([todayYear intValue]-18==[birthYear intValue] && [todayMonth intValue]>[birthMonth intValue]) DOBIsGood=true;
    else if ([todayYear intValue]-18==[birthYear intValue] && [todayMonth intValue]==[birthMonth intValue] && [todayDay intValue]>[birthDay intValue]) DOBIsGood=true;
    else DOBIsGood=false;
    if (eduStr.length!=0) eduIsGood=true;
    if (bloodStr.length!=0) bloodIsGood=true;
    if (cityStr.length!=0) cityIsGood=true;
    if (_imageData) photoIsGood=true;
    
    NSString * problemStr= [[NSString alloc]init];
    if (!nameIsGood) problemStr=[problemStr stringByAppendingString:@" Name requires 8 digit!"];
    if (!emailIsGood)  problemStr=[problemStr stringByAppendingString:@" Invalid email!"];
    if (!mobileIsGood)  problemStr=[problemStr stringByAppendingString:@" Phone number requires 8 digit!"];
    if (!passwordIsGood)  problemStr=[problemStr stringByAppendingString:@" Password requires 5-10 digit!"];
    if (!repeatPasswordIsGood)  problemStr=[problemStr stringByAppendingString:@" Two passwords are different!"];
    if (!VINIsGood)  problemStr=[problemStr stringByAppendingString:@" VIN requires 17 digit"];
    if (!licenseIsGood) problemStr=[problemStr stringByAppendingString:@" Invalid license number!"];
    if (!emergencyIsGood)  problemStr=[problemStr stringByAppendingString:@" Emergency contact requires 10 digit!"];
    if (!DOBIsGood)  problemStr=[problemStr stringByAppendingString:@" You are too young!"];
    if (!eduIsGood)  problemStr=[problemStr stringByAppendingString:@" Please select EDU level!"];
    if (!bloodIsGood)  problemStr=[problemStr stringByAppendingString:@" Please select blood group!"];
    if (!cityIsGood)   problemStr=[problemStr stringByAppendingString:@" Please let system find your city"];
    if (!photoIsGood)  problemStr=[problemStr stringByAppendingString:@" Please upload photo!"];

    
    if (nameIsGood&&emailIsGood&&mobileIsGood&&passwordIsGood&&repeatPasswordIsGood&&VINIsGood&&licenseIsGood&&emergencyIsGood&&DOBIsGood&&eduIsGood&&bloodIsGood&&cityIsGood) {
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


#pragma mark- submit-
- (IBAction)submitButtonTapped:(id)sender {
    NSLog(@"result %@",_resultDict);
    [self formatCheck:_resultDict];
}
@end
