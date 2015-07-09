//
//  AnaglyphPhoto.h
//  Flicker Test
//
//  Created by Chelsea Liu on 7/4/15.
//  Copyright (c) 2015 Chelsea Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrPhoto : NSObject

@property (strong, nonatomic) NSString *secret;
@property (strong, nonatomic) NSNumber *farm;
@property (strong, nonatomic) NSString *photoID;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSURL *photoURL;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSString *dateTaken;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *tags;
@property (strong, nonatomic) NSString *username;
@property (nonatomic) BOOL isFavourite;

@end
