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
#import "FlickrPhotoCell.h"
#import "FlickrPhotoHeaderView.h"

@interface ViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar; // properties to change apperance of outlets
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableDictionary *searchResults; // Holds individual folders of search results (arrays)
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
    
    // Register cells for reuse
    //[self.collectionView registerClass:[UICollectionViewCell class]
    //       forCellWithReuseIdentifier:@"FlickrCell"];
    
}

- (IBAction)shareButtonTapped:(id)sender; {
    // TODO
}

// Called when user hits return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.flickr searchFlickrForTerm:textField.text completionBlock:^(NSString *searchTerm, NSArray *results, NSError *error) {
        
        if (results && [results count] > 0) {
            
            // Only add to searches dictionary if searchTerm isnt found in search history
            if (![self.searches containsObject:searchTerm]) {
                NSLog(@"Found %lu photos matching %@", (unsigned long)[results count], searchTerm);
                // Add to 0 index to form stack
                [self.searches insertObject:searchTerm atIndex:0];
                // Add to dictionary
                self.searchResults[searchTerm] = results;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        } else {
            NSLog(@"Error searching Flickr: %@", error.localizedDescription);
        }
        
    }];
    
    // Close keyboard on return key
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UICollectionViewDataSource

// Number of sections
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.searches count];
}

// Number of objects in a section
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSString *searchTerm = self.searches[section];
    return [self.searchResults[searchTerm] count];
}

// Make a cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Use custom flickr cell
    FlickrPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
    
    NSString *searchTerm = self.searches[indexPath.section];
    cell.photo = self.searchResults[searchTerm][indexPath.row];
    
    return cell;
    }

// Need to implement for custom view header. This header will appear with every set of photo search term/results.
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    // Make a reusable headerView
    FlickrPhotoHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FlickrPhotoHeaderView" forIndexPath:indexPath];
    // Configure header
    NSString *searchTerm = self.searches[indexPath.section];
    [headerView setSearchText:searchTerm];
    
    return headerView;
}

#pragma mark - UICollectionViewDelegate

// When cell is selected
- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO
}

// When a cell is deselected during multiple selection
- (void)collectionView:(UICollectionView *)collectionView
    didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
        // TODO: select item
    
}

// F


#pragma mark - UICollectionViewDelegateFlowLayout
// Size of a given cell based on a photo
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *searchTerm = self.searches[indexPath.section];
    FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
    
    CGSize retval = photo.thumbnail.size.width > 0 ?
    photo.thumbnail.size : CGSizeMake(100, 100);
    retval.height += 35;
    retval.width += 35;
    
    return retval;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

@end
