//
//  AnaglyphEnlargedViewController.m
//  Flicker Test
//
//  Created by Chelsea Liu on 7/6/15.
//  Copyright (c) 2015 Chelsea Liu. All rights reserved.
//

#import "AnaglyphEnlargedViewController.h"
#import "LocationViewController.h"

@interface AnaglyphEnlargedViewController ()


@end

@implementation AnaglyphEnlargedViewController


- (void)setDetailItem:(FlickrPhoto*)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 2;
    
    NSURL *photoURL = [NSURL URLWithString: [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/%@_%@_z.jpg", self.detailItem.farm, self.detailItem.server, self.detailItem.photoID, self.detailItem.secret]];
    NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
    self.imageView.image = [UIImage imageWithData:photoData];

    [self.scrollView addSubview:self.imageView];
    self.scrollView.userInteractionEnabled = YES;

    [self viewForZoomingInScrollView:self.scrollView];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (UIImageView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}


#pragma mark - Navigation

//in sequence:

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    identifier = @"showMap";
    if ([self.detailItem.longitude integerValue] == 0 && [self.detailItem.latitude integerValue] == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Location unavailable for this image. :(" message:[NSString stringWithFormat:@"Image Name: %@\nDate Taken: %@", self.detailItem.title, self.detailItem.dateTaken] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        NSLog(@"%@, %@", self.detailItem.latitude, self.detailItem.longitude);
        return NO;
    } else {
        NSLog(@"%@, %@", self.detailItem.latitude, self.detailItem.longitude);
        return YES;
        
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [[segue destinationViewController] setDetailItem:self.detailItem];
}

@end
