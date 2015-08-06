//
//  FlickrPhotoViewController.h
//  FlickrSearch
//
//  Created by Dennis Nguyen on 8/6/15.
//  Copyright (c) 2015 dnwin. All rights reserved.
//

#import <UIKit/UIKit.h>

// Modal Popup on selection of a photo

@class FlickrPhoto;

@interface FlickrPhotoViewController : UIViewController

@property (nonatomic, strong) FlickrPhoto *flickrPhoto;

@end
