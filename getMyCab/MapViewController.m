//
//  MapViewController.m
//  getMyCab
//
//  Created by Xiaodan Wang on 2/8/16.
//  Copyright © 2016 Xiaodan Wang. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet UIButton *showmapButton;
- (IBAction)showmapButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet MKMapView *map;

@property (nonatomic) CLLocationManager *locationManager; //used to find the local coordinator
@property (nonatomic) CLGeocoder *geoCoder;
@property (nonatomic) CLPlacemark *placemaker; //use local coordinator to find the city
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _map.hidden=true;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- get location city by coordinator-
- (void)startGettingLocation {
    [self.view endEditing:NO];
    _locationManager.delegate=self;
    _map.delegate=self;
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
            _showmapButton.hidden=false;
        } else   NSLog(@"%@", error.debugDescription);
    }];
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateRegion region= MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 400, 400);
    [_map setRegion:region];
}

- (IBAction)showmapButtonTapped:(id)sender {
    [self startGettingLocation];
    _map.hidden=false;
    
}
@end
