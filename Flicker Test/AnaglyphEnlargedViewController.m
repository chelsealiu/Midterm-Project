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

@property (strong, nonatomic) NSString *buttonTitle;
-(void)showInfo;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *heartButton;

@end

@implementation AnaglyphEnlargedViewController


- (void)setDetailItem:(FlickrPhoto*)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateTintColour];
    
    UIBarButtonItem *mapButton=[[UIBarButtonItem alloc] initWithTitle:@"Show On Map" style:UIBarButtonItemStylePlain target:self action:@selector(shouldPerformSegueWithIdentifier:sender:)];
    
    UIBarButtonItem *infoButton=[[UIBarButtonItem alloc] initWithTitle:@"Show Info" style:UIBarButtonItemStylePlain target:self action:@selector(shouldPerformSegueWithIdentifier:sender:)];
    
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 4;
    
    NSURL *photoURL = [NSURL URLWithString: [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/%@_%@_z.jpg", self.detailItem.farm, self.detailItem.server, self.detailItem.photoID, self.detailItem.secret]];
    NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
    self.imageView.image = [UIImage imageWithData:photoData];

    [self.scrollView addSubview:self.imageView];
    self.scrollView.userInteractionEnabled = YES;

    [self viewForZoomingInScrollView:self.scrollView];
    
    if ([self.detailItem.longitude doubleValue] == 0 && [self.detailItem.latitude doubleValue] == 0) {
        
        self.navigationItem.rightBarButtonItem = infoButton;
        
    } else {
        
        self.navigationItem.rightBarButtonItem = mapButton;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIImageView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (IBAction)addToFavourite:(UIBarButtonItem*)sender {
    
    self.detailItem.isFavourite = !self.detailItem.isFavourite;
    [self updateTintColour];
}

-(void) updateTintColour {
    
    if (!self.detailItem.isFavourite) {
        [self.heartButton setTintColor:nil];
    } else {
        [self.heartButton setTintColor:[UIColor redColor]];
    }
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Show Info"]) {
        [self showInfo];
        return NO;
    } else {
        [self performSegueWithIdentifier:@"showMap" sender:sender];
        return YES;
    }
}

- (void) showInfo{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", self.detailItem.title] message:[NSString stringWithFormat:@"Taken by user: %@\nDate taken: %@", self.detailItem.username, self.detailItem.dateTaken] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[segue destinationViewController] setDetailItem:self.detailItem];
}

@end
