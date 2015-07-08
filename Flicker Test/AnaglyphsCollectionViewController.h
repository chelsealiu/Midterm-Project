//
//  AllPhotosViewControllerCollectionViewController.h
//  Flicker Test
//
//  Created by Chelsea Liu on 7/4/15.
//  Copyright (c) 2015 Chelsea Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnaglyphsCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;



@end
