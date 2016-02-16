//
//  MapViewController2.m
//  getMyCab
//
//  Created by Xiaodan Wang on 2/9/16.
//  Copyright © 2016 Xiaodan Wang. All rights reserved.
//

#import "MapViewController2.h"
#import "AppDelegate.h"

@interface MapViewController2 (){
    MKPointAnnotation *pointPickup;
    MKPointAnnotation *pointDropoff;
    CLLocationCoordinate2D coordinatePickup;
    CLLocationCoordinate2D coordinateDropoff;
    CLLocationCoordinate2D coordinateMid;
    int annotationFlag;
    UIBarButtonItem *doneButton;
    AppDelegate * localDelegate;
    MKRoute * routePolyline;
}

@property (weak, nonatomic) IBOutlet UILabel *labelPickup;
@property (weak, nonatomic) IBOutlet UILabel *labelDropoff;
@property (weak, nonatomic) IBOutlet MKMapView *map;
- (IBAction)updateRouteTapped:(id)sender;


@property (nonatomic) CLLocationManager* locationManager;
@property (nonatomic) CLGeocoder *geoCoder;
@property (nonatomic) CLPlacemark *placemaker; //use local coordinator to find the city
@property (nonatomic) MKPolyline *routeLine; //your line
@property (nonatomic) MKPolylineView *routeLineView; //overlay view

@end

@implementation MapViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    doneButton = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
    _locationManager=[[CLLocationManager alloc]init];
    [_locationManager requestAlwaysAuthorization];
    [_locationManager startUpdatingLocation];
    _locationManager.delegate=self;
    _map.delegate=self;
    _map.showsUserLocation=true;
    doneButton.enabled=false;
    localDelegate=[[UIApplication sharedApplication]delegate];
}

- (void)viewWillAppear:(BOOL)animated{
    pointDropoff=[[MKPointAnnotation alloc]init];
    pointPickup=[[MKPointAnnotation alloc]init];
    _geoCoder=[[CLGeocoder alloc]init];
    _routeLine=[[MKPolyline alloc]init];
//    _placemaker=[[CLPlacemark alloc]init];
    coordinatePickup=_locationManager.location.coordinate;
    coordinatePickup.latitude=_locationManager.location.coordinate.latitude+0.0005;
    coordinatePickup.longitude=_locationManager.location.coordinate.longitude-0.001;
    
    coordinateDropoff.latitude=_locationManager.location.coordinate.latitude+0.0005;
    coordinateDropoff.longitude=_locationManager.location.coordinate.longitude+0.001;
    
    pointPickup.coordinate=coordinatePickup;
    pointDropoff.coordinate=coordinateDropoff;
    pointPickup.title=@"Pickup";
    pointDropoff.title=@"Dropoff";
    
    [_map addAnnotation:pointPickup];
    [_map addAnnotation:pointDropoff];
    
    MKCoordinateRegion region= MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, 400, 400);
    [_map setRegion:region];
}

- (void)done{
    [self.navigationController popViewControllerAnimated:YES];
    localDelegate=[[UIApplication sharedApplication]delegate];
    localDelegate.flagForCustomerMapView=1;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }else if([annotation isKindOfClass:[MKPointAnnotation class]]){
        
        static NSString* const identifier=@"custAnnotationID";
        MKAnnotationView *annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView) {
            annotationView.annotation=annotation;
        }else {
            annotationView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        
        annotationView.canShowCallout=true;
        annotationView.draggable=true;
        if ([annotation.title isEqualToString:@"Pickup"]) annotationView.image=[UIImage imageNamed:@"pin-pick"];
        else if ([annotation.title isEqualToString:@"Dropoff"]) annotationView.image=[UIImage imageNamed:@"pin-drop"];
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
    [_map removeOverlay:routePolyline.polyline];
    if (newState == MKAnnotationViewDragStateStarting) {
        view.dragState = MKAnnotationViewDragStateDragging;
    }
    else if (newState == MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateCanceling) {
        view.dragState = MKAnnotationViewDragStateNone;
        if (annotationFlag==1) {
            [_map removeOverlay:_routeLine];
            coordinatePickup = view.annotation.coordinate;
            NSLog(@"Pickup pin dropped at %f,%f", coordinatePickup.latitude, coordinatePickup.longitude);
            _labelPickup.text=[NSString stringWithFormat:@"%.03f, %.03f",coordinatePickup.latitude,coordinatePickup.longitude];
        }else if(annotationFlag==2) {
            coordinateDropoff = view.annotation.coordinate;
            NSLog(@"Dropoff pin dropped at %f,%f", coordinateDropoff.latitude, coordinateDropoff.longitude);
            _labelDropoff.text=[NSString stringWithFormat:@"%.03f, %.03f",coordinateDropoff.latitude,coordinateDropoff.longitude];
        }
        [_locationManager startUpdatingLocation];  //restart updating location when the pin is moved
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MKPointAnnotation *selectedAnnotation = view.annotation;
    if([selectedAnnotation.title isEqualToString:@"Pickup"]) annotationFlag=1;
    else if([selectedAnnotation.title isEqualToString:@"Dropoff"]) annotationFlag=2;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
//    CLLocation * currentLocation = [locations lastObject];
//    NSLog(@"current latitude is:%f current longitude is:%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    CLLocation * pickupLocation =[[CLLocation alloc]initWithLatitude:coordinatePickup.latitude longitude:coordinatePickup.longitude];
    [_geoCoder reverseGeocodeLocation:pickupLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error==nil && placemarks>0) {
            _placemaker = [placemarks lastObject];
            NSString * city= _placemaker.locality;
            NSLog(@"%@",city);
            if (city!=nil) {
                [_locationManager stopUpdatingLocation];        //stop updating location after find the city
                doneButton.enabled=true;
                localDelegate.cityForCustomerMapView=city;
            }
        } else   NSLog(@"%@", error.debugDescription);
    }];
}



- (MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *routeRender=[[MKPolylineRenderer alloc]initWithOverlay:overlay];
    [routeRender setStrokeColor:[UIColor blackColor]];
    [routeRender setAlpha:.5f];
    return routeRender;
}
- (IBAction)updateRouteTapped:(id)sender {
 //   _routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:2];
    [_map removeOverlay:routePolyline.polyline];
    
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    MKPlacemark *placemarkPickup = [[MKPlacemark alloc] initWithCoordinate:coordinatePickup addressDictionary:nil];
    MKPlacemark *placemarkDropoff = [[MKPlacemark alloc] initWithCoordinate:coordinateDropoff addressDictionary:nil];
    MKMapItem *mapItemPickup = [[MKMapItem alloc] initWithPlacemark:placemarkPickup];
    MKMapItem *mapItemDropoff = [[MKMapItem alloc] initWithPlacemark:placemarkDropoff];
    
    [directionsRequest setSource:mapItemPickup];
    [directionsRequest setDestination:mapItemDropoff];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            routePolyline = response.routes.lastObject;
            [_map addOverlay:routePolyline.polyline];
            _labelPickup.text=[placemarkPickup.addressDictionary objectForKey:@"Street"];
            _labelDropoff.text=[placemarkDropoff.addressDictionary objectForKey:@"Street"];
        }
    }];
    
    
}
@end
