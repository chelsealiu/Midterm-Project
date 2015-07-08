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


@interface AnaglyphsCollectionViewController () <UISearchBarDelegate, UISearchResultsUpdating, UILayoutSupport>

@property (nonatomic, strong) NSArray *anaglyphObjects;
@property (nonatomic, strong) UISearchController *searchController;
@property(nonatomic, strong) NSArray *allObjects;
//@property(nonatomic, strong) NSMutableArray *searches;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic) BOOL finishedEditingSearch;
@property (nonatomic, strong)  UITextField *textFieldInput;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL enterPressed;

@end



@implementation AnaglyphsCollectionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView setContentOffset:CGPointMake(0, 44)];

    [self refreshView];
    [self configureSearchBar];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.collectionView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    self.collectionView.alwaysBounceVertical = YES;
    
}

-(IBAction)refreshView {
    
    [self.refreshControl beginRefreshing];
    
    if ([self.anaglyphObjects count] != 0) {
        return;
        //exit early/no network request if pictures already exist
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
                NSLog(@"%@", anaglyphPhoto.tags);
                
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
    return UIEdgeInsetsMake(44, 11, 11, 11);
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(AnaglyphCell*)sender {
    if ([[segue identifier] isEqualToString:@"showEnlargedAnaglyph"]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        FlickrPhoto *photoClicked = self.anaglyphObjects[indexPath.row];
        [[segue destinationViewController] setDetailItem: photoClicked];
    }
}

#pragma mark Search Controller

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setText:@""];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

-(void) configureSearchBar {
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [self.collectionView setContentOffset:CGPointMake(0, 44)];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    self.searchController.searchBar.delegate = self;
    self.searchController.active = YES;
    [self.view addSubview:self.searchController.searchBar];
    self.searchController.searchBar.placeholder = @"Search by title, tags, username ...";
    self.searchController.searchBar.showsScopeBar = YES;
    self.searchController.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"Title",@"Tags",@"Username", nil];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.searchController.searchBar attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.searchController.searchBar attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.searchController.searchBar attribute:NSLayoutAttributeRight multiplier:1.0 constant:10]];
    
    [self.searchController.searchBar setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = self.searchController.searchBar.text;
    NSLog(@"%@", searchString);
    
    if ([searchString isEqualToString:@""]) {
        return;
    } else if (self.searchController.searchBar.selectedScopeButtonIndex == 0) {
        self.anaglyphObjects = [self.allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title CONTAINS[c] %@", searchString]];
    } else if (self.searchController.searchBar.selectedScopeButtonIndex == 1) {
        self.anaglyphObjects = [self.allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY tags CONTAINS[c] %@", searchString]];
    } else if (self.searchController.searchBar.selectedScopeButtonIndex == 2) {
        self.anaglyphObjects = [self.allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"username CONTAINS[c] %@", searchString]];
    }
    [self.collectionView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    searchBar.showsScopeBar = YES;
    [searchBar setShowsCancelButton:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    searchBar.showsScopeBar = NO;
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}


@end
