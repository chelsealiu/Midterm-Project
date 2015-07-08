//
//  LocationViewController.m
//  Flicker Test
//
//  Created by Chelsea Liu on 7/6/15.
//  Copyright (c) 2015 Chelsea Liu. All rights reserved.
//

#import "LocationViewController.h"

@import MapKit;

@interface LocationViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) BOOL setInitialLocation;

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
    self.locationManager.delegate = self; //must conform to protocol in HEADER as well as storyboard!!!
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.mapView.showsUserLocation = YES;

    //check user's current settings: enabled? -> allows access?
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization]; //only request for tracking when app opens
            
        }
    }
    
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

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject]; //most recent update
    
    if (!self.setInitialLocation) {
        self.setInitialLocation = YES; //make sure this is only called once
        MKCoordinateRegion region = MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01));
        [self.mapView setRegion:region animated:YES];
        
    }
}

//show user's current location

- (IBAction)locateUser:(id)sender {
    
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
    
    if (self.mapView.userLocation) {
        NSLog(@"TRIES to print userlocation %@", self.mapView.userLocation);
        //Check if user is already zoomed in to current location
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    }
}


- (void) loadImagelocation {
        
    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];

    marker.coordinate = CLLocationCoordinate2DMake([self.detailItem.latitude doubleValue], [self.detailItem.longitude doubleValue]);
    marker.title = self.detailItem.title;

    marker.subtitle = [NSString stringWithFormat:@"Date taken: %@", self.detailItem.dateTaken];
    [self.mapView addAnnotation:marker];
    [self.mapView setCenterCoordinate: marker.coordinate animated:YES];
    
}


//- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    if (annotation == self.mapView.userLocation) {
//        return nil;
//    }
//    
//    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"TheatrePin"];
//    if (!annotationView) {
//        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"TheatrePin"];
//        //resize image
//        CGSize tempSize = CGSizeMake(25, 32);
//        UIImage *tempImage = [UIImage imageNamed:@"angry_pusheen"];
//        UIGraphicsBeginImageContext(tempSize);
//        [tempImage drawInRect:CGRectMake(0,0,tempSize.width,tempSize.height)];
//        annotationView.image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        annotationView.centerOffset = CGPointMake(0, -annotationView.image.size.height/2);
//        //account for size difference of custom image vs original pin
//        //x coordinate is fine, change the placement for y coordinate
//        annotationView.canShowCallout = YES;
//    }
//    
//    return annotationView;
//}

@end
