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
#import "FlickrPhotoViewController.h"

@interface ViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar; // properties to change apperance of outlets
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableDictionary *searchResults; // Holds individual folders of search results (arrays)
@property (strong, nonatomic) NSMutableArray *searches; // Contains history of search entries
@property (strong, nonatomic) Flickr *flickr; // Stores api key and various functions

@property (nonatomic, strong) NSMutableArray *selectedPhotos; // Holds selection of photos during share mode
@property (nonatomic) BOOL sharing; // Set to YES when user is making multi-selection to share imagest

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
    
    self.selectedPhotos = [@[] mutableCopy];
    // Register cells for reuse
    //[self.collectionView registerClass:[UICollectionViewCell class]
    //       forCellWithReuseIdentifier:@"FlickrCell"];
    
}

- (IBAction)shareButtonTapped:(id)sender; {
    UIBarButtonItem *shareButton = (UIBarButtonItem *)sender;
    
    // If not sharing, set to sharing mode, change button to done
    if (!self.sharing) {
        self.sharing = YES;
        [shareButton setStyle:UIBarButtonItemStyleDone];
        [shareButton setTitle:@"Done"];
        [self.collectionView setAllowsMultipleSelection:YES];
    } else { // If sharing mode and user presses DONE
        self.sharing = NO;
        [shareButton setStyle:UIBarButtonItemStylePlain];
        [shareButton setTitle:@"Share"];
        [self.collectionView setAllowsMultipleSelection:NO];
        
        // If any photos are selected
        if ([self.selectedPhotos count] > 0) {
            // Mail photos
            [self showMailComposerAndSend];
        }
        // Deselect all
        for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
        // Clear selected objects
        [self.selectedPhotos removeAllObjects];
        
    }
}

- (void)showMailComposerAndSend {
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
    if (!self.sharing) {
        // Popup modal vc if not sharing
        if (!self.sharing) {
            NSString *searchTerm = self.searches[indexPath.section];
            FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
            // Present modally
            [self performSegueWithIdentifier:@"ShowFlickrPhoto" sender:photo];
            // Remove selection
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        } else { // Sharing mode
            NSString *searchTerm = self.searches[indexPath.section];
            // Get current photo selected and add to mutable array
            FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
            [self.selectedPhotos addObject:photo];
        }
    }
}

// When a cell is deselected during multiple selection enabled
- (void)collectionView:(UICollectionView *)collectionView
    didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Remove photo from currently selected array
    NSString *searchTerm = self.searches[indexPath.section];
    FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
    [self.selectedPhotos removeObject:photo];
}



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

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Present modally
    if ([segue.identifier  isEqualToString:@"ShowFlickrPhoto"]) {
        FlickrPhotoViewController *flickrPhotoViewController = segue.destinationViewController;
        flickrPhotoViewController.flickrPhoto = sender;

    }
}

@end
