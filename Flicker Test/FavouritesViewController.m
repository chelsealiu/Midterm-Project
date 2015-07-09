//
//  FavouritesViewController.m
//  Flicker Test
//
//  Created by Chelsea Liu on 7/9/15.
//  Copyright (c) 2015 Chelsea Liu. All rights reserved.
//

#import "FavouritesViewController.h"
#import "AnaglyphCell.h"
#import "FlickrPhoto.h"

@interface FavouritesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>





@end

@implementation FavouritesViewController

- (void)setDetailItem:(NSMutableArray*)newDetailItem {
    if (_arrayItem != newDetailItem) {
        _arrayItem = newDetailItem;
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"number of favourites: %lu", (unsigned long)self.arrayItem.count);
    return self.arrayItem.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AnaglyphCell *anaglyphCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FavouriteCell" forIndexPath:indexPath];
    FlickrPhoto *flickrPhoto = self.arrayItem[indexPath.row];
    
    NSURL *imageURL = flickrPhoto.photoURL;

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:flickrPhoto.photoURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        data = [NSData dataWithContentsOfURL: imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            anaglyphCell.favImageView.image = [UIImage imageWithData:data];
            
        });
    }];
    
//    anaglyphCell.task = task; //attach
    [task resume];
    
    return anaglyphCell;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(170, 170);
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(11, 11, 11, 11);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
