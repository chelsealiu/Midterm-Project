//
//  LocationViewController.m
//  Flicker Test
//
//  Created by Chelsea Liu on 7/6/15.
//  Copyright (c) 2015 Chelsea Liu. All rights reserved.
//

#import "LocationViewController.h"

@import MapKit;

@interface LocationViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) BOOL setInitialLocation;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *zoomButton;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) int tapCount;

@end

@implementation LocationViewController


- (void)setDetailItem:(FlickrPhoto*)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.setInitialLocation = NO;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self loadImagelocation];
}


//changes made when user changes authorization status

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
    }
}

//zoom to show user's current location when user didUpdateLocations

//- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    
//    self.currentLocation = [locations lastObject]; //most recent update

//    if (!self.setInitialLocation) {
//        self.setInitialLocation = YES; //make sure this is only called once
//        MKCoordinateRegion region = MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01));
//        [self.mapView setRegion:region animated:YES];
//        
//    }
//}

//show user's current location

- (IBAction)locateUser:(id)sender {
    
    
    //check user's current settings: enabled? -> allows access?
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization]; //only request for tracking when app opens
            
        }
    }

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        //if user wants to be tracked but denied permission to be tracked, make alert popup to open settings
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Denied" message:@"Your location settings are turned off." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Open Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            //opening settings
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if (settingsURL) {
                [[UIApplication sharedApplication] openURL:settingsURL];
            }
        }];
        
        [alertController addAction:openAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    self.mapView.showsUserLocation = YES;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate];

}

- (IBAction)goToImageAction:(id)sender {
    
    [self loadImagelocation];
    
}

- (MKPointAnnotation*)loadImagelocation {
    
    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];

    marker.coordinate = CLLocationCoordinate2DMake([self.detailItem.latitude doubleValue], [self.detailItem.longitude doubleValue]);
    marker.title = self.detailItem.title;

    marker.subtitle = [NSString stringWithFormat:@"Date taken: %@", self.detailItem.dateTaken];
    [self.mapView addAnnotation:marker];
    [self.mapView setCenterCoordinate: marker.coordinate animated:YES];
    return marker;
}


- (IBAction)zoomAction:(UIBarButtonItem*)sender {
    
//    
//    if (self.tapCount %2 == 0) {
//        //zoom out
//        MKCoordinateRegion region = [self regionForWorld];
//        [self.mapView setRegion:region animated:YES];
//        
//    } else {
    MKPointAnnotation *marker = [self loadImagelocation];
    
    MKCoordinateRegion region = MKCoordinateRegionMake(marker.coordinate, MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:region animated:YES];
    
    self.tapCount ++;
}

- (MKCoordinateRegion)regionForWorld {
    return MKCoordinateRegionForMapRect(MKMapRectWorld);
}

- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == self.mapView.userLocation) {
        return nil;
    }
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"TheatrePin"];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"TheatrePin"];
        //resize image
        CGSize tempSize = CGSizeMake(32, 26);
        UIImage *tempImage = [UIImage imageNamed:@"pointer"];
        UIGraphicsBeginImageContext(tempSize);
        [tempImage drawInRect:CGRectMake(0,0,tempSize.width,tempSize.height)];
        annotationView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        annotationView.centerOffset = CGPointMake(0, -annotationView.image.size.height/2);

        annotationView.canShowCallout = YES;
    }
    
    return annotationView;
}

@end
