//
//  ViewController.m
//  FlickrSearch
//
//  Created by Dennis Nguyen on 6/22/15.
//  Copyright (c) 2015 dnwin. All rights reserved.
//

#import "ViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar; // properties to change apperance of outlets
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) NSMutableDictionary *searchResults; // Holds all of search results
@property (strong, nonatomic) NSMutableArray *searches; // Contains history of search entries
@property (strong, nonatomic) Flickr *flickr; // Stores api key and various functions

- (IBAction)shareButtonTapped:(id)sender;

@end

@implementation ViewController


// API key d4fdb6021469bcf569e5a324a6dd1ef6
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Clear searches everytime view is loaded
    self.searches = [@[] mutableCopy];
    self.searchResults = [@{} mutableCopy];
    self.flickr = [[Flickr alloc] init];
    
    // Set custom background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cork.png"]];
    
    // Make image for toolbar
    UIImage *navBarImage = [[UIImage imageNamed:@"navbar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(27, 27, 27, 27)];
    [self.toolbar setBackgroundImage:navBarImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    // Change font color of share button
    [self.shareButton setTintColor:[UIColor whiteColor]];
    
    UIImage *textFieldImage = [UIImage imageNamed:@"search_field"];
    [textFieldImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.textField setBackground:textFieldImage];
    
}

- (IBAction)shareButtonTapped:(id)sender; {
    // TODO
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.flickr searchFlickrForTerm:textField.text completionBlock:^(NSString *searchTerm, NSArray *results, NSError *error) {
        
        if (results && [results count] > 0) {
            
            // Checks to see if not searched before, then save search term and add results to dictioary w/ term
            if (![self.searches containsObject:searchTerm]) {
                NSLog(@"Found %lu photos matching %@", (unsigned long)[results count], searchTerm);
                // Add to 0 index to form stack
                [self.searches insertObject:searchTerm atIndex:0];
                self.searchResults[searchTerm] = results;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // placeholder: reload collection data after peforming search
            });
        } else {
            NSLog(@"Error searching Flickr: %@", error.localizedDescription);
        }
        
    }];
    
    // Close keyboard on return key
    [textField resignFirstResponder];
    return YES;
}
@end
