//
//  AnaglyphEnlargedViewController.h
//  Flicker Test
//
//  Created by Chelsea Liu on 7/6/15.
//  Copyright (c) 2015 Chelsea Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrPhoto.h"

@interface AnaglyphEnlargedViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) FlickrPhoto *detailItem;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
