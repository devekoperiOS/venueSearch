//
//  LibraryAPI.m
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//


#import "LibraryAPI.h"
#import "RootViewController.h"
#import "PhotoViewController.h"
#import "ParseOperation.h"
#import "ParseOperationPhoto.h"
#import "Constants.h"


@interface LibraryAPI ()
// private properties
// queue to run ParseOperation and ParseOperationPhoto
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSOperationQueue *queuePhoto;
// NSOperation for parsing of API
@property (nonatomic, strong) ParseOperation *parser;
@property (nonatomic, strong) ParseOperationPhoto *parserphoto;

// private methods
- (NSString *)getVersion;
- (void)callVenueSearchAPI:(NSString *)strurl;
- (void)callVenuePhotoAPI:(NSString *)strurl;
- (void)handleError:(NSError *)error;
- (void)handleEmptyResponse:(NSString *)strMessage message:(int)messageId;

@end



@implementation LibraryAPI

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

// creating a singlton to return same instance every time
+ (LibraryAPI*)sharedInstance
{
    static LibraryAPI *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LibraryAPI alloc] init];
    });
    return _sharedInstance;
}

- (void)callAPIToGetPhotos:(NSString *)venueid
{
    NSString *strVersion = [self getVersion];
    NSString *myurl = [NSString stringWithFormat:@"%s%@%slimit=%d&oauth_token=%s&v=%@",APIURL,venueid,APIPHOTS,PHOTOLIMIT,OAUTHTOKEN,strVersion];
    [self callVenuePhotoAPI:[myurl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
}

- (void)callVenuePhotoAPI:(NSString *)strurl
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strurl]];
    // creating session data task to get and the json response
    NSURLSessionDataTask *sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    // response status code
    //NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
    if (error != nil)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
            {
                // in info.plist you need to set arbitary load to true for security
                abort();
            }
            else
            {
                [self handleError:error];
            }
        }];
    }
    else
    {
        // create  queue to run the ParseOperation
        self.queuePhoto = [[NSOperationQueue alloc] init];
        // create an ParseOperation which is a subclass of NSOperation in order to parse the venue data so that the UI is not blocked
        _parserphoto = [[ParseOperationPhoto alloc] initWithData:data];
        // creating weakSelf to prevent memory cycle
        __weak LibraryAPI *weakSelf = self;
        self.parserphoto.errorHandler = ^(NSError *parseError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [weakSelf handleError:parseError];
            });
        };
        // if we use parserphoto in completionBlock, then it result in retain cycle
        __weak ParseOperationPhoto *weakParser = self.parserphoto;
        self.parserphoto.completionBlock = ^(void) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (weakParser.appRecordList != nil)
            {
                // The completion block execute on any thread
                // updating UI on the main thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    // checking url, because asychronous requqest can complete at any time, mean while if user has called another API request
                    NSURL *a = [request URL];
                    if([strurl isEqualToString:[a absoluteString]])
                    {
                        PhotoViewController *rootViewController = (PhotoViewController*)[(UINavigationController*)[[UIApplication sharedApplication] delegate].window.rootViewController topViewController];
                        if(weakParser.appRecordList == nil || [weakParser.appRecordList count] == 0)
                        {
                            if(weakParser.strError != nil){
                                [weakSelf handleEmptyResponse:weakParser.strError message:1];
                            }
                            else
                                [weakSelf handleEmptyResponse:@"No photos available" message:1];
                        }
                        else{
                            rootViewController.entriesPhotos = weakParser.appRecordList;
                            // updating ui
                            [rootViewController.tblPhoto reloadData];
                        }
                    }
                });
            }
            weakSelf.queuePhoto = nil;
        };
        [self.queuePhoto addOperation:self.parserphoto]; // start the ParseOperationPhoto
    }
    }];
    [sessionTask resume];
    // network activity started to show user some activity, on status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)callVenueSearchAPI:(NSString *)strurl
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strurl]];
    NSURLSessionDataTask *sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error != nil)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
            {
                abort();
            }
            else
            {
                [self handleError:error];
            }
         }];
    }
    else
    {
        self.queue = [[NSOperationQueue alloc] init];
        _parser = [[ParseOperation alloc] initWithData:data];
        __weak LibraryAPI *weakSelf = self;
        self.parser.errorHandler = ^(NSError *parseError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [weakSelf handleError:parseError];
            });
        };
        __weak ParseOperation *weakParser = self.parser;
        self.parser.completionBlock = ^(void) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (weakParser.appRecordList != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSURL *a = [request URL];
                    if([strurl isEqualToString:[a absoluteString]])
                    {
                        RootViewController *rootViewController =
                        (RootViewController*)[(UINavigationController*)[[UIApplication sharedApplication] delegate].window.rootViewController topViewController];
                        if([weakParser.appRecordList count] == 0 && weakParser.strError != nil){
                            [weakSelf handleError:[NSError errorWithDomain:weakParser.strError code:0 userInfo:nil]];
                        }
                        else
                        {
                            rootViewController.entries = weakParser.appRecordList;
                            [rootViewController.tableView reloadData];
                        }
                    }
                });
            }
            weakSelf.queue = nil;
        };
        [self.queue addOperation:self.parser];
      }
    }];
    [sessionTask resume];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (NSString *)getVersion
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    return [dateFormatter stringFromDate:[NSDate date]];
}

- (void)callAPIToGetVenuesByPlaceName:(NSString *)placename
{
    NSString *strVersion = [self getVersion];
    NSString *myurl = [NSString stringWithFormat:@"%s%snear=%@&limit=%d&client_id=%s&client_secret=%s&v=%@",APIURL,APISEARCH,placename,LIMIT,CLIENTID,CLIENTSECRET,strVersion];
    [self callVenueSearchAPI:[myurl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
}

- (void)callAPIToGetVenuesByLatLong:(double)latitude longitude:(double)longitude
{
    NSString *strVersion = [self getVersion];
    NSString *myurl = [NSString stringWithFormat:@"%s%sll=%f,%f&limit=%d&client_id=%s&client_secret=%s&v=%@",APIURL,APISEARCH,latitude,longitude,LIMIT,CLIENTID,CLIENTSECRET,strVersion];
    [self callVenueSearchAPI:[myurl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
}


- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot find venues"
                                                                   message:errorMessage
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         // dissmissal of alert completed
                                                         [self callAPIToGetVenuesByLatLong:LATITUDE longitude:LONGITUDE];
                                                     }];
    [alert addAction:OKAction];
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)handleEmptyResponse:(NSString *)strMessage message:(int)messageId
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No values found"
                                                                   message:strMessage
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         // dissmissal of alert completed
                                                         if(messageId == 1)
                                                         {
                                                             UINavigationController *objNav = (UINavigationController*)[[UIApplication sharedApplication] delegate].window.rootViewController;
                                                             [objNav popViewControllerAnimated:YES];
                                                         }
                                                         else{
                                                             [self callAPIToGetVenuesByLatLong:LATITUDE longitude:LONGITUDE];
                                                         }
                                                     }];
    [alert addAction:OKAction];
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:alert animated:YES completion:nil];
}


@end
