//
//  FlickrPhotoCellCollectionViewCell.m
//  FlickrSearch
//
//  Created by Dennis Nguyen on 8/5/15.
//  Copyright (c) 2015 dnwin. All rights reserved.
//

#import "FlickrPhotoCell.h"
#import "FlickrPhoto.h"
#import <QuartzCore/QuartzCore.h>


@implementation FlickrPhotoCell

// Sets the photo on current cell
- (void) setPhoto:(FlickrPhoto *)photo {
    if (_photo != photo) {
        _photo = photo;
    }
    self.imageView.image = _photo.thumbnail;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Configure a colored background for use in selection with alpha
        UIView *background = [[UIView alloc] initWithFrame:self.bounds];
        background.backgroundColor = [UIColor blueColor];
        self.backgroundView = background;
    }
    
    return self;
}

- (void)prepareForReuse {
    [self.imageView setAlpha:1.0];
}

@end
