//
//  AppDelegate.m
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/1/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import "AppDelegate.h"
#import "LibraryAPI.h"
#import "Constants.h"

@interface AppDelegate () <CLLocationManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // User will get alert message as and when there is call to startUpdatingLocation
    [self.locationManager startUpdatingLocation];
    // This condition just check that user has location service stopped or not
    if (![CLLocationManager locationServicesEnabled]) {
        // call to API
        NSLog(@"Application did finish launching:  call to API by using hard code latitude and longitude");
        [[LibraryAPI sharedInstance] callAPIToGetVenuesByLatLong:LATITUDE longitude:LONGITUDE];
    }
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                  [UIColor whiteColor],
                                                                                                  NSForegroundColorAttributeName,
                                                                                                  nil] 
                                                                                        forState:UIControlStateNormal];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == 2 || status == 0)
    {
        NSLog(@"didChangeAuthorizationStatus: in 0 or 2 :call to API by using hard code latitude and longitude");
        [[LibraryAPI sharedInstance] callAPIToGetVenuesByLatLong:LATITUDE longitude:LONGITUDE];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *loc = [locations lastObject];
    CLLocationDegrees latitude = loc.coordinate.latitude;
    CLLocationDegrees longitude = loc.coordinate.longitude;
    // call to API by using current location
    NSLog(@"didUpdateLocations : call to API by using current location");
    [[LibraryAPI sharedInstance] callAPIToGetVenuesByLatLong:latitude longitude:longitude];
    // Turn off the location manager to save power.
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"can not find location: Error: %@", error);
    NSLog(@"location service didFailWithError:  call to API by using hard code latitude and longitude");
    [[LibraryAPI sharedInstance] callAPIToGetVenuesByLatLong:LATITUDE longitude:LONGITUDE];
}



@end
