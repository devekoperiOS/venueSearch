//
//  RootViewController.m
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import "RootViewController.h"
#import "AppRecord.h"
#import "IconDownloader.h"
#import "VenueTableViewCell.h"
#import "Constants.h"
#import "DetailViewController.h"
#import "LibraryAPI.h"
#import "AppDelegate.h"

static NSString *CellIdentifier = @"venueTableCell";


#pragma mark -

@interface RootViewController () <UIScrollViewDelegate, UISearchBarDelegate>

// the set of IconDownloader objects for each app
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end


#pragma mark -

@implementation RootViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.placeholder = @"Enter city";
    searchBar.showsCancelButton = true;
    self.navigationItem.titleView = searchBar;
}


- (void)terminateAllDownloads
{
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}


- (void)dealloc
{
    // terminate all pending download connections
    [self terminateAllDownloads];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    [self terminateAllDownloads];
}
#pragma mark - search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *strPlace = searchBar.text;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    // based on this text find lat long and call foursquare API
    [[LibraryAPI sharedInstance] callAPIToGetVenuesByPlaceName:strPlace];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

#pragma mark - currentLocation

- (IBAction)btnGetVenueAtCurrentLocation:(UIButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.locationManager startUpdatingLocation];
}
#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = self.entries.count;
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VenueTableViewCell *cell = nil;
    NSUInteger nodeCount = self.entries.count;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
    {
        AppRecord *appRecord = (self.entries)[indexPath.row];
        cell.lblName.text = appRecord.name;
        cell.lblCategory.text = appRecord.shortName;
            
        NSMutableString *strAddress = [[NSMutableString alloc]init];
        [strAddress setString:@""];
        for (NSString *str in appRecord.formattedAddress) {
            [strAddress appendString:str];
            [strAddress appendString:@" "];
        }
        cell.lblAddress.text = strAddress;
        strAddress = nil;
            
        if(appRecord.distance == nil)
            cell.lblDistance.text = @" ";
        else
        {
            double mi = [appRecord.distance floatValue] / 1609.344;
            cell.lblDistance.text = [NSString stringWithFormat:@"%.02f miles",mi];
        }
        // Only load cached images; defer new downloads until scrolling ends
        if (!appRecord.appIcon)
        {
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            cell.imgVenue.image = [UIImage imageNamed:@"Placeholder.png"];
        }
        else
        {
            if(appRecord.appIcon == NULL)
                cell.imgVenue.image = [UIImage imageNamed:@"Noimageplaceholder.png"];
            else
                cell.imgVenue.image = appRecord.appIcon;
        }
    }
    return cell;
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"show detail"])
    {
        // Get reference to the destination view controller
        // Pass any objects to the view controller here, like...
        
        // note that "sender" will be the tableView cell that was selected
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        AppRecord *venue = [_entries objectAtIndex:indexPath.row];
        DetailViewController *obj = (DetailViewController *)[segue destinationViewController];
        obj.venue = venue;
        //[[LibraryAPI sharedInstance] callAPIToGetPhotos:venue.id];
        
    }
}


#pragma mark - Table cell image support


- (void)startIconDownload:(AppRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        [iconDownloader setCompletionHandler:^{
            
            VenueTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            if(appRecord.appIcon == NULL)
                cell.imgVenue.image = [UIImage imageNamed:@"Noimageplaceholder.png"];
            else
                cell.imgVenue.image = appRecord.appIcon;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startDownload];
    }
}


- (void)loadImagesForOnscreenRows
{
    if (self.entries.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            AppRecord *appRecord = (self.entries)[indexPath.row];
            
            if (!appRecord.appIcon)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}


#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}




@end
