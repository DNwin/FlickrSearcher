//
//  FlickrPhotoViewController.m
//  FlickrSearch
//
//  Created by Dennis Nguyen on 8/6/15.
//  Copyright (c) 2015 dnwin. All rights reserved.
//

#import "FlickrPhotoViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"

@interface FlickrPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)done:(id)sender;

@end

@implementation FlickrPhotoViewController

// Will usually use a new photo everytime it appears
- (void)viewDidAppear:(BOOL)animated {
    self.imageView.image = nil;
    // If large photo fetched, set
    if (self.flickrPhoto.largeImage) {
        self.imageView.image = self.flickrPhoto.largeImage;
    } else { // Display stretched thumbnail if not
        // Small image
        self.imageView.image = self.flickrPhoto.thumbnail;
        
        // Load large image
        [Flickr loadImageForPhoto:self.flickrPhoto thumbnail:NO completionBlock:^(UIImage *photoImage, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = self.flickrPhoto.largeImage;
                });
            }}];
    }

}


- (IBAction)done:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}





@end
