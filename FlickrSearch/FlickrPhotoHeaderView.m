//
//  FlickrPhotoHeaderView.m
//  FlickrSearch
//
//  Created by Dennis Nguyen on 8/5/15.
//  Copyright (c) 2015 dnwin. All rights reserved.
//

#import "FlickrPhotoHeaderView.h"

@interface FlickrPhotoHeaderView()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;


@end

@implementation FlickrPhotoHeaderView

- (void)setSearchText:(NSString *)text
{
    self.searchLabel.text = text;
    
    // Two circles on left and right side header
    UIImage *shareButtonImage = [[UIImage imageNamed:@"header_bg.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(68, 68, 68, 68)];
    self.backgroundImageView.image = shareButtonImage;
}

@end
