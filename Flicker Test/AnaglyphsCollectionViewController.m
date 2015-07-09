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
#import "FavouritesViewController.h"

@interface AnaglyphsCollectionViewController () <UISearchBarDelegate>

@property (nonatomic, strong) NSArray *anaglyphObjects;
@property (nonatomic, strong) UISearchController *searchController;
@property(nonatomic, strong) NSArray *allObjects;
@property(nonatomic, strong) NSMutableArray *favouriteAnaglyphs;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic) BOOL finishedEditingSearch;
@property (nonatomic, strong)  UITextField *textFieldInput;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end


@implementation AnaglyphsCollectionViewController

-(void) viewWillAppear:(BOOL)animated {
    self.favouriteAnaglyphs = [[NSMutableArray alloc] init];
    for (FlickrPhoto *photo in self.anaglyphObjects) {
        if (photo.isFavourite) {
            [self.favouriteAnaglyphs addObject:photo];
            NSLog(@"%@", photo);
        }
    }
}

    
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView setContentOffset:CGPointMake(0, 44)];
//    [self refreshView];
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.collectionView addSubview:self.refreshControl];
//    [self.refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
//    self.collectionView.alwaysBounceVertical = YES;
////    
//    
//    
//    [self.refreshControl beginRefreshing];
    
    if ([self.anaglyphObjects count] != 0) {
        return;
    }
    
    //network call
    
    int random = arc4random_uniform(365); //generate random page every time

    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?&method=flickr.groups.pools.getPhotos&api_key=66a526df8c983a344c7561753108b531&group_id=52240974383@N01&nojsoncallback=1&format=json&per_page=200&page=%d&extras=geo,date_taken,url_z,tags", random];
    
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
                anaglyphPhoto.title = anaglyphDict[@"title"]; //scope 1
                anaglyphPhoto.dateTaken = anaglyphDict[@"datetaken"];
                anaglyphPhoto.username = anaglyphDict[@"ownername"]; //scope 2
                anaglyphPhoto.tags = [anaglyphDict[@"tags"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; //scope 3
                
                [tempAnaglyphArray addObject:anaglyphPhoto];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.anaglyphObjects = [[NSArray alloc] initWithArray: tempAnaglyphArray]; //array of photoURL strings
                self.allObjects = self.anaglyphObjects;
                [self.collectionView reloadData];
                [self.refreshControl endRefreshing];
                
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
    
    AnaglyphCell *anaglyphCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AnaglyphCell" forIndexPath:indexPath];
    FlickrPhoto *flickrPhoto = self.anaglyphObjects[indexPath.row];
    
    if ([flickrPhoto.longitude doubleValue] != 0 && [flickrPhoto.latitude doubleValue] != 0) {
        anaglyphCell.iconImageView.hidden = NO;
    }
    else {
        anaglyphCell.iconImageView.hidden = YES;
    }
    
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
    } else if ([[segue identifier] isEqualToString:@"segueToFavourites"]) {
        FavouritesViewController *newVC = [[FavouritesViewController alloc] init];
        newVC = segue.destinationViewController;
        [[segue destinationViewController] setArrayItem:self.favouriteAnaglyphs];
        
    }
}


#pragma mark Search Controller

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setText:@""];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (IBAction)segmentControlChanged:(id)sender {
    
    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text {
    NSString *searchString = self.searchBar.text;

    if ([searchString isEqualToString:@""]) {
        return;
    } else if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.anaglyphObjects = [self.allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title CONTAINS[c] %@", searchString]];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        self.anaglyphObjects = [self.allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY tags CONTAINS[c] %@", searchString]];
    } else if (self.segmentedControl.selectedSegmentIndex == 2) {
        self.anaglyphObjects = [self.allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"username CONTAINS[c] %@", searchString]];
    }
    [self.collectionView reloadData];
}


@end
