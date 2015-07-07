//
//  AllPhotosViewControllerCollectionViewController.m
//  Flicker Test
//
//  Created by Chelsea Liu on 7/4/15.
//  Copyright (c) 2015 Chelsea Liu. All rights reserved.
//

#import "AnaglyphsCollectionViewController.h"
#import "AnaglyphEnlargedViewController.h"
#import "FlickrPhoto.h"
#import "AnaglyphCell.h"


@interface AnaglyphsCollectionViewController ()

@property (strong, nonatomic) NSArray *anaglyphObjects;


@end



@implementation AnaglyphsCollectionViewController

static NSString * const reuseIdentifier = @"AnaglyphCell";


- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self.anaglyphObjects count] != 0) {
        return;
        //exit early/no network request if pictures already exist
    }
    
    //network call
  
    int random = arc4random_uniform(365); //generate random page every time
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?&method=flickr.groups.pools.getPhotos&api_key=66a526df8c983a344c7561753108b531&group_id=52240974383@N01&nojsoncallback=1&format=json&per_page=200&page=%d&extras=geo,date_taken,url_z", random];
    
    NSURL *anaglyphURL = [NSURL URLWithString:urlString];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:anaglyphURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *fetchingError) {
        
        if (fetchingError) {
            NSLog(@"ERROR: fetching error");
        }
        
        NSError *jsonError;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) {
            NSLog(@"ERROR: JSON error");
        }
        
        NSDictionary *allAnaglyphsArray = responseDictionary[@"photos"][@"photo"]; //list of dictionaries with properties
        
        if (!allAnaglyphsArray) {
            NSLog(@"ERROR: no photos available");
        } else {
            
            NSMutableArray *tempAnaglyphArray = [NSMutableArray array];
            for (NSDictionary *anaglyphDict in allAnaglyphsArray) {
                
                FlickrPhoto *anaglyphPhoto = [[FlickrPhoto alloc] init];
                
                anaglyphPhoto.farm = anaglyphDict[@"farm"];
                anaglyphPhoto.server = anaglyphDict[@"server"];
                anaglyphPhoto.photoID = anaglyphDict[@"id"];
                anaglyphPhoto.secret = anaglyphDict[@"secret"];
                anaglyphPhoto.photoURL = [NSURL URLWithString: [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_q.jpg", anaglyphPhoto.farm, anaglyphPhoto.server, anaglyphPhoto.photoID, anaglyphPhoto.secret]];
                anaglyphPhoto.longitude = anaglyphDict[@"longitude"];
                anaglyphPhoto.latitude = anaglyphDict[@"latitude"];
                anaglyphPhoto.title = anaglyphDict[@"title"];
                anaglyphPhoto.dateTaken = anaglyphDict[@"datetaken"];

                [tempAnaglyphArray addObject:anaglyphPhoto];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.anaglyphObjects = [[NSArray alloc] initWithArray: tempAnaglyphArray]; //array of photoURL strings
                [self.collectionView reloadData];
            });
        }
        
        
        
    }];
    
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.anaglyphObjects) {
        return 1;
    } else {
        return 0;
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.anaglyphObjects.count;
}


#pragma mark <UICollectionViewDataSource>



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AnaglyphCell *anaglyphCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    FlickrPhoto *flickrPhoto = self.anaglyphObjects[indexPath.row];
    NSURL *imageURL = flickrPhoto.photoURL;
    anaglyphCell.imageView.image = nil;
    [anaglyphCell.task cancel]; //cancel
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:flickrPhoto.photoURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        data = [NSData dataWithContentsOfURL: imageURL];
      
        dispatch_async(dispatch_get_main_queue(), ^{
            
            anaglyphCell.imageView.image = [UIImage imageWithData:data];

            });
        }];
    
    anaglyphCell.task = task; //attach
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(AnaglyphCell*)sender {
    if ([[segue identifier] isEqualToString:@"showEnlargedAnaglyph"]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        FlickrPhoto *photoClicked = self.anaglyphObjects[indexPath.row];
        [[segue destinationViewController] setDetailItem: photoClicked];
    }


}


#pragma mark <UICollectionViewDelegate>
//
//
//// Uncomment this method to specify if the specified item should be highlighted during tracking
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//	return YES;
//}
//
//
//// Uncomment this method to specify if the specified item should be selected
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//
//// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
//	return NO;
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//	return NO;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//	
//}


@end
