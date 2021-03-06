//
//  MapViewController.h
//  getMyCab
//
//  Created by Xiaodan Wang on 2/8/16.
//  Copyright © 2016 Xiaodan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>

@interface MapViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic,strong) NSString * mobile;

@end
