//
//  MapViewController.m
//  getMyCab
//
//  Created by Xiaodan Wang on 2/8/16.
//  Copyright © 2016 Xiaodan Wang. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import "MapViewController2.h"

@interface MapViewController (){
    NSString *pickupCity;
    NSString *urlStr;
    NSMutableArray *driverAnnotationArray;
    NSString *subtitleStr;
    //to show driver info
    __block NSArray *cityArray,*latArray,*longiArray,*nameArray,*mobileArray;
    __block NSMutableDictionary *driverDictionary;
}

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
    _locationManager.delegate=self;
    _map.delegate=self;
    driverAnnotationArray=[NSMutableArray array];
    driverDictionary=[[NSMutableDictionary alloc]init];
    subtitleStr=[[NSString alloc]init];
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc]initWithTitle:@"LogOut" style:UIBarButtonItemStylePlain target:self action:@selector(popIt)];
    self.navigationItem.rightBarButtonItem=logOutButton;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.hidesBackButton=true;
    AppDelegate * localDelegate = [[UIApplication sharedApplication]delegate];
    if (localDelegate.flagForCustomerMapView==0) {
        _map.hidden=true;
    }else {
        _map.hidden=false;
        [self startGettingLocation];
        pickupCity=localDelegate.cityForCustomerMapView;
        NSLog(@"pickup city is: %@",pickupCity);
        urlStr= [NSString stringWithFormat:@"http://rjtmobile.com/ansari/driver_search.php?city=%@",pickupCity];
        [self apiCallForJsonActorsData];
        MKCoordinateRegion region= MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, 1000, 1000);
        //    NSLog(@"lat and long: %f, %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        [_map setRegion:region];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popIt{
    [self.navigationController popToRootViewControllerAnimated:YES];
    AppDelegate * localDelegate= [[UIApplication sharedApplication]delegate];
    localDelegate.flagForCustomerMapView=0;
}

- (void)apiCallForJsonActorsData{
//    NSURL * url=[NSURL URLWithString:@"http://rjtmobile.com/ansari/driver_search.php?city=Hyderabad"];
    NSURL * url=[NSURL URLWithString:urlStr];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSLog(@"%@",response);
            NSError * error;
            id resultData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSLog(@"%@",resultData);
        //    __block NSArray *cityArray,*latArray,*longiArray,*nameArray;
            dispatch_sync(dispatch_get_main_queue(), ^{
                //if ([resultData isKindOfClass:[NSDictionary class]]){
                    cityArray=[NSArray arrayWithArray:[resultData valueForKey:@"city"]];
                    latArray=[NSArray arrayWithArray:[resultData valueForKey:@"latitude"]];
                    longiArray=[NSArray arrayWithArray:[resultData valueForKey:@"longitude"]];
                    nameArray=[NSArray arrayWithArray:[resultData valueForKey:@"name"]];
                    mobileArray= [NSArray arrayWithArray:[resultData valueForKey:@"mobile"]];
                NSLog(@"arrResult %@",nameArray);

                //}
            });
            if (cityArray.count==0) {
                UIAlertController * alertNoDriver= [UIAlertController alertControllerWithTitle:@"Sorry" message:@"No on duty driver is found." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertNoDriver addAction:action];
                [self presentViewController:alertNoDriver animated:YES completion:nil];
            }else {
                for (int i=0; i<cityArray.count; i++) { // add all on duty driver's lat and long into to make annotations and store in a mutablearray
                    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
                    CLLocationCoordinate2D annotationCoordinate;
                    annotationCoordinate.latitude=[latArray[i] floatValue];
                    annotationCoordinate.longitude=[longiArray[i] floatValue];
                    annotation.coordinate=annotationCoordinate;
                    annotation.title=nameArray[i];
                    annotation.subtitle=mobileArray[i];
                    NSString * infoString = [NSString stringWithFormat:@"Driver name:%@\n Driver Mobile:%@\n Contact him/her now?",nameArray[i],mobileArray[i]];
                    [driverDictionary setObject:infoString forKey:mobileArray[i]];
                    [driverAnnotationArray addObject:annotation];
                    [_map addAnnotation:driverAnnotationArray[i]];
                }
            }NSLog(@"%@", driverDictionary);
        }
    }] resume];
}

#pragma mark- get location city by coordinator-
- (void)startGettingLocation {
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    [_locationManager requestAlwaysAuthorization];
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"fail to get location");
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{

}

- (IBAction)showmapButtonTapped:(id)sender {
    _map.hidden=false;
    MapViewController2 * mapVC2 = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController2"];
    [self.navigationController pushViewController:mapVC2 animated:YES];
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if([annotation isKindOfClass:[MKPointAnnotation class]]){
        static NSString *identifier = @"custAnnotationID";
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView) {
            annotationView.annotation=annotation;
        }else{
            annotationView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
        }
//        MKPointAnnotation * localAnnotation = (MKPointAnnotation*)annotation;
//        subtitleStr=annotation.subtitle;
        annotationView.canShowCallout=true;
        annotationView.image=[UIImage imageNamed:@"car_driver"];
        UIButton * msgButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [msgButton addTarget:self action:@selector(contactDriverNow) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView=msgButton;
        return annotationView;
    }
    return nil;
}

- (void)contactDriverNow{
    NSLog(@"phone %@",subtitleStr);
    NSString *alertStr = [driverDictionary objectForKey:subtitleStr];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Contact" message:alertStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * actionOK =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *textController= [[MFMessageComposeViewController alloc]init];
            textController.messageComposeDelegate=self;
            [textController setBody:@"Hi dear driver, can I get a ride?"];
            [textController setRecipients:[NSArray arrayWithObject:subtitleStr]];
            [self presentViewController:textController animated:YES completion:nil];
            
        }
        
    }];
    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:actionOK];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    MKPointAnnotation *selectedAnnotation = view.annotation;
    subtitleStr=selectedAnnotation.subtitle;
}

@end
