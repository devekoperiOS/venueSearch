//
//  PhotoViewController.m
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import "PhotoViewController.h"
#import "RootViewController.h"
#import "VenuePhotos.h"
#import "IconDownloader.h"
#import "VenueTableViewPhotoCell.h"
#import "Constants.h"
#import "LibraryAPI.h"

static NSString *CellIdentifier = @"photoTableCell";

@interface PhotoViewController () <UIScrollViewDelegate, UISearchBarDelegate>

// the set of IconDownloader objects for each app
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation PhotoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.tblPhoto.estimatedRowHeight = self.tblPhoto.rowHeight;
    self.tblPhoto.rowHeight = UITableViewAutomaticDimension;
    self.tblPhoto.dataSource = self;
    self.tblPhoto.delegate = self;
    [self.tblPhoto reloadData];
}



- (void)terminateAllDownloads
{
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownloadPhoto)];
    
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



#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = self.entriesPhotos.count;
    return count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VenueTableViewPhotoCell *cell = nil;
    NSUInteger nodeCount = self.entriesPhotos.count;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
    {
        // Set up the cell representing the app
        VenuePhotos *appRecord = (self.entriesPhotos)[indexPath.row];
        // Only load cached images; defer new downloads until scrolling ends
        if (!appRecord.venuePhoto)
        {
            if (self.tblPhoto.dragging == NO && self.tblPhoto.decelerating == NO)
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            cell.activity.hidden = false;
            [cell.activity startAnimating];
            cell.imgVenue.image = [UIImage imageNamed:@"Placeholder.png"];
        }
        else
        {
            cell.activity.hidden = true;
            [cell.activity stopAnimating];
            if(appRecord.venuePhoto == NULL)
                cell.imgVenue.image = [UIImage imageNamed:@"Noimageplaceholder.png"];
            else
                cell.imgVenue.image = appRecord.venuePhoto;
        }
    }
    return cell;
}



#pragma mark - Table cell image support


- (void)startIconDownload:(VenuePhotos *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecordPhoto = appRecord;
        [iconDownloader setCompletionHandlerForPhoto:^{
            
            VenueTableViewPhotoCell *cell = [self.tblPhoto cellForRowAtIndexPath:indexPath];
            
            cell.activity.hidden = true;
            [cell.activity stopAnimating];
            
            // Display the newly loaded image
            if(appRecord.venuePhoto == NULL)
                cell.imgVenue.image = [UIImage imageNamed:@"Noimageplaceholder.png"];
            else
                cell.imgVenue.image = appRecord.venuePhoto;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startDownloadPhoto];
    }
}


- (void)loadImagesForOnscreenRows
{
    if (self.entriesPhotos.count > 0)
    {
        NSArray *visiblePaths = [self.tblPhoto indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            VenuePhotos *appRecord = (self.entriesPhotos)[indexPath.row];
            
            if (!appRecord.venuePhoto)
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
