//
//  MapViewControllerDriver.m
//  getMyCab
//
//  Created by Xiaodan Wang on 2/9/16.
//  Copyright © 2016 Xiaodan Wang. All rights reserved.
//

#import "MapViewControllerDriver.h"
#import "AppDelegate.h"

@interface MapViewControllerDriver ()
@property (weak, nonatomic) IBOutlet UIButton *offDutyButton;
@property (weak, nonatomic) IBOutlet UIButton *onDutyButton;
@property (weak, nonatomic) IBOutlet MKMapView *map;
- (IBAction)offDutyButtonTapped:(id)sender;
- (IBAction)onDutyButtonTapped:(id)sender;


@property (nonatomic) CLLocationManager *locationManager; //used to find the local coordinator
@property (nonatomic) CLGeocoder *geoCoder;
@property (nonatomic) CLPlacemark *placemaker; //use local coordinator to find the city
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

@end

@implementation MapViewControllerDriver

- (void)viewDidLoad {
    [super viewDidLoad];
    _offDutyButton.enabled=false;
    _map.delegate=self;
    _locationManager.delegate=self;
    self.title=@"OFF DUTY now";
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.hidesBackButton=true;
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc]initWithTitle:@"LogOut" style:UIBarButtonItemStylePlain target:self action:@selector(popIt)];
    self.navigationItem.rightBarButtonItem=logOutButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)popIt{
    [self.navigationController popToRootViewControllerAnimated:YES];
    AppDelegate * localDelegate= [[UIApplication sharedApplication]delegate];
    localDelegate.flagForCustomerMapView=0;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"fail to get location");
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateRegion region= MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 400, 400);
    _latitude=userLocation.coordinate.latitude;
    _longitude=userLocation.coordinate.longitude;
    NSLog(@"lat and long: %f, %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    [_map setRegion:region];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getURLRequestForRegistration] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSString* respondStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self loginStatus:respondStr];
            });
        }
    }] resume];
}

#warning xiao dan is 2
- (NSURLRequest *)getURLRequestForRegistration{
    NSURL * url=[NSURL URLWithString:[NSString stringWithFormat:@"http://rjtmobile.com/ansari/driver_cords.php?mobile=%@&latitude=%f&longitude=%f",_mobile,_latitude,_longitude]];
    NSMutableURLRequest * urlRequest=[NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:180];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    return urlRequest;
}

- (void)loginStatus:(NSString*)string{
    NSLog(@"response string from server:%@",string);
}


- (IBAction)offDutyButtonTapped:(id)sender {
    _onDutyButton.enabled=true;
    _offDutyButton.enabled=false;
    _map.showsUserLocation=false;
    [_locationManager stopUpdatingLocation];
    self.title=@"OFF DUTY now";
}

- (IBAction)onDutyButtonTapped:(id)sender {
    _offDutyButton.enabled=true;
    _onDutyButton.enabled=false;
    _locationManager.delegate=self;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
    _map.showsUserLocation=true;
    self.title=@"ON DUTY now";
}
@end
