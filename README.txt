This application is displaying the venues for current location. It also find venues based on name of place. From list of venues user can tap on any one and can see more detail. From detail view, user can see photos, website and can make call. 

For current location, I have used core location. In authorization method of current location, if user has not determined or if user has denied to use the location service, then I am calling API by using hard code latitude and longitude for Comcast office. 

Information about Foursquare API:

As per documentation of foursquare API, it provides different kind of URLs. To use that, I registered my application in foursquare. I got client id and client secret which I can pass in my url. I have added this in Constants.h file.

I have used following 3 URL.

1. Following is URL in which, user need to enter latitude and longitude. I am using this URL, when user calls the API by using current location.

https://api.foursquare.com/v2/venues/search?ll=40.103844,-75.382324&limit=50&client_id=4LLHA53PNHF5DENJXXTKKZTJP4QNDPLNPZV22V4HXXMARNHL&client_secret=LH04RWE31ZD5H5VRJCG5KISEWQB2XBCZEL02DHCO3RUI1PWY&v=20170103

2. Following is URL in which, user need to enter name of city. I am using this URL, when user calls the API by using search term.

https://api.foursquare.com/v2/venues/search?near=Chicago, IL&limit=50&client_id=4LLHA53PNHF5DENJXXTKKZTJP4QNDPLNPZV22V4HXXMARNHL&client_secret=LH04RWE31ZD5H5VRJCG5KISEWQB2XBCZEL02DHCO3RUI1PWY&v=20170103


Note: This API is not giving distance, so if user is searching by entering name of city then, there is not distance information shown in application. For retrieving the icon, I have specified prefix, suffix and size.

3. Following is URL in which, user need to provide venue ID and authorization token. To use this API, I have created my account and generated an authorization token, which I have added in Constants.h file.

https://api.foursquare.com/v2/venues/51da60eb498e14582f350b71/photos?limit=5&oauth_token=KD0RU2YRM32PHYF500KQUWCSCLDFVAWLZ0LVPUC1ME0DGPDL&v=20170103

In every API call, I have given limit and version which is current date.


Information about flow:

I have used navigation based flow for list and detail screens.

When application starts, I am calling API based on current location. If used denied to use or if its not determined then I am using hard code lat long for Comcast office.

I have created plain button which simply display text like "Click here to find venues at current location". If user click on this, application will retrieve current location and display venues based on that location. In location delegate method, I am stopping updating location once it finds lat long to stop using battery. This button is a header of table view.

On top bar (navigation bar), I have added search bar, where user can type the name of city. On clicking on search button of keyboard, application will call API based on name of search term. I am using foursquare API which has "near" parameter. As I have checked the documentation, this API works on geocoding. So, I have used this one and not worked on Google API.

In each cell of table I am displaying name of venue, category of venue, address of venue, icon  and distance.

On clicking on cell, I am displaying detail page. On detail page I am displaying name, address, link to view photos, map with pin and detail view for the venue which user has selected to view its detail. In addition to that I am displaying website URL, Phone number and overall rating.

All the records do not have website URL, Phone number and rating. So, Its only visible if information is available in API. 

On clicking website button, I am opening web view which loads that url.
On clicking call button, user can make call to specified number. As I have checked some data, I found that some phone numbers have country code and some phone number do not have. So, I have added 1 for USA. For other countries, it does have. 

Note: If there is not country code then call will not be take place.

On clicking view photos, I am displaying 5 photos. User can scroll through it and visit back to main screen.


Information about implementation:

For location service, I have used core location. For network call, I have used NSURLSession and NSOperation to perform asynchronous call. I have used NSOeration and GCD for performing work on background and main thread.

AppDelegate
This file contain code for location service along with its delegate method. There is a call to API in authorization method for location service as well as in updating location method.

RootViewController
It contains table view with list of venues which are coming as a result of API call. For table view search for new location and navigating to detail view.

DetailViewController
When preparing for segue, I am passing venue to detail view. It contains more detail for a particular venue. I have used map kit for displaying pin and detail view. It also displays website and phone number. 

PhotoViewController
List view with 5 photos for each venue are displayed by table view.

WebdisplayViewController
URL for a venue is displayed in this screen by using web view.

CustomCell
Both for venue and photo, I have used custom cell and configured that in storyboard.

Library
It contain LibraryAPI and IconDownloader. LibraryAPI is common file that has methods for calling foursquare API. Networking code i.e. sending request to server is inside LibraryAPI file. Along with that, it also provide UI updates once the parsing is done. It have some helper methods as well.
It contain IconDownloader for downloading of image, which is requesting server to get image.

Parsing
It contain ParseOperation and ParseOperationPhoto for parsing of requested URL. It has main method which is an entry point and that contain JSON parsing and parsed data are added to model classes.

Model
It contain data for storing API response for venues and photos. During JSON parsing, I am keep on adding data for model classes.

Software Used:

Xcode 8.2

Deployment target
iOS 7 and later






 
