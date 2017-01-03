//
//  DetailViewController.m
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import "DetailViewController.h"
#import "PhotoViewController.h"
#import "LibraryAPI.h"
#import "Constants.h"
#import "WebdisplayViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblRating;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *btnPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnURL;

- (IBAction)btnViewPhone:(UIButton *)sender;
@end

@implementation DetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if(self.venue.shortName == NULL || [self.venue.shortName length] == 0)
        self.title = @"Detail";
    else
        self.title = self.venue.shortName;
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [self.venue.lat doubleValue];
    zoomLocation.longitude= [self.venue.lng doubleValue];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [self.mapView setRegion:viewRegion animated:YES];
    MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc]init];
    CLLocationCoordinate2D pinCoordinate;
    pinCoordinate.latitude = [self.venue.lat doubleValue];
    pinCoordinate.longitude = [self.venue.lng doubleValue];
    myAnnotation.coordinate = pinCoordinate;
    myAnnotation.title = self.venue.name;
    NSMutableString *strAddress = [[NSMutableString alloc]init];
    [strAddress setString:@""];
    for (NSString *str in self.venue.formattedAddress) {
        [strAddress appendString:str];
        [strAddress appendString:@" "];
    }
    myAnnotation.subtitle = strAddress;
    [self.mapView addAnnotation:myAnnotation];
    
    self.lblName.text = self.venue.name;
    self.lblAddress.text = strAddress;
    
    if(self.venue.url == NULL || [self.venue.url length] == 0)
        self.btnURL.hidden = true;
    else
    {
        self.btnURL.hidden = false;
        [self.btnURL setTitle:[NSString stringWithFormat:@" %@",self.venue.url] forState:UIControlStateNormal];
    }
    if(self.venue.formattedPhone == NULL || [self.venue.formattedPhone length] == 0)
        self.btnPhone.hidden = true;
    else
    {
        self.btnPhone.hidden = false;
        [self.btnPhone setTitle:[NSString stringWithFormat:@" %@",self.venue.formattedPhone] forState:UIControlStateNormal];
    }
    
    if(self.venue.venueRatingBlacklisted == NULL)
        self.lblRating.hidden = true;
    else
    {
        self.lblRating.hidden = false;
        if([self.venue.venueRatingBlacklisted boolValue])
            self.lblRating.text = @"Rating: Good";
        else
            self.lblRating.text = @"Rating: Not good";
    }
    strAddress = nil;

}



#pragma mark - navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"show photos"])
    {
        PhotoViewController *obj = (PhotoViewController *)[segue destinationViewController];
        obj.venue = self.venue;
        [[LibraryAPI sharedInstance] callAPIToGetPhotos:self.venue.id];
        
    }
    else if([[segue identifier] isEqualToString:@"show web"])
    {
        WebdisplayViewController *obj = (WebdisplayViewController *)[segue destinationViewController];
        obj.strURL = self.venue.url;
    }
}


#pragma mark - button

- (IBAction)btnViewPhone:(UIButton *)sender {
    
    if([self.venue.country isEqualToString:@"United States"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://1-%@",self.venue.phone]]];
    }
    else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.venue.phone]]];
    }
}
@end
