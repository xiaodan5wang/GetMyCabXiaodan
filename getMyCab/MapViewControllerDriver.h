//
//  MapViewControllerDriver.h
//  getMyCab
//
//  Created by Xiaodan Wang on 2/9/16.
//  Copyright © 2016 Xiaodan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewControllerDriver : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate>

@property (nonatomic,strong) NSString * mobile;

@end
