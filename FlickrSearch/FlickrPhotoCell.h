//
//  FlickrPhotoCellCollectionViewCell.h
//  FlickrSearch
//
//  Created by Dennis Nguyen on 8/5/15.
//  Copyright (c) 2015 dnwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlickrPhoto;

@interface FlickrPhotoCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) FlickrPhoto *photo;


@end
