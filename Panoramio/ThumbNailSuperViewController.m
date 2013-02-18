//
//  ThumbNailSuperViewController.m
//  Panoramio
//
//  Created by lily on 2/9/13.
//
//

#import "ThumbNailSuperViewController.h"
#import "PlanetViewAppDelegate.h"
#import "PhotoInfo.h"
#import "ShowLocationViewController.h"
#import "LocalImageManager.h"
#import <malloc/malloc.h>

@interface ThumbNailSuperViewController ()
@property PlanetViewAppDelegate *pvDelegate;
@property dispatch_queue_t fetchQ;
@property NSInteger didCount;
@property NSTimer *storeDBTimer;
@property dispatch_queue_t storeDBQ;
@end

@implementation ThumbNailSuperViewController
@synthesize scrollView = _scrollView;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize row;
@synthesize column;
@synthesize imageWidth = _imageWidth;
@synthesize imageHight = _imageHeight;
@synthesize imageCache;
@synthesize currentListPage;
@synthesize photoId;
@synthesize scrollBeginOffset = _scrollBeginOffset;
@synthesize isEnd;
@synthesize pvDelegate;
@synthesize fetchQ = _fetchQ;
@synthesize imageSet = _imageSet;
@synthesize receivedData = _receivedData;
@synthesize connection = _connection;
@synthesize didCount;
@synthesize storeDBTimer = _storeDBTimer;
@synthesize storeDBQ;
//NSInteger const row = 6;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.row =6;
    self.column = 4;
    self.isEnd = NO;
    //   self.scrollView.contentInset=UIEdgeInsetsMake(64.0,0.0,44.0,0.0);
    //[self printPhotoWithPageIndex:0];
    self.pvDelegate = (((PlanetViewAppDelegate*) [UIApplication sharedApplication].delegate));
    _imageSet = [[NSMutableDictionary alloc] init];
    
    self.didCount = 0;
    self.currentListPage = 0;
    _fetchQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
  //  self.fetchQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    self.storeDBQ = dispatch_queue_create("store db", NULL);
}

- (void)fetchPhotoData
{
    NSError *error;
    FetchPhotoResult *fetchPhoto = [FetchPhotoResult init];
    fetchPhoto.isFavorite = NO;
    _fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    fetchPhoto = nil;
}

/*
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
 self.isEnd = NO;
 NSArray *imageSubviews = _scrollView.subviews;
 //    for (UIView *subImageView in imageSubviews) {
 //        [subImageView removeFromSuperview];
 //    }
 
 }
 */

-(void) handleTap:(UIGestureRecognizer*) gesture
{
    CGPoint touchPoint=[gesture locationInView:_scrollView];
    int photoIndex = self.column * ((NSInteger)(touchPoint.y/(_imageHeight+1)))+((NSInteger)touchPoint.x/(_imageWidth+1));
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
    [self fetchPhotoData];
    //int photoCount = [[_fetchedResultsController fetchedObjects] count];
    //    NSLog(@"%d %d", photoIndex, [[_fetchedResultsController fetchedObjects] count]);
    if (photoIndex < [[_fetchedResultsController fetchedObjects] count]) {
        PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
        self.photoId = photoInfo.photoId;
        [self performSegueWithIdentifier:@"showPhotoDetail" sender:self];
    }
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPhotoDetail"]) {
        ShowLocationViewController *photoVC = segue.destinationViewController;
        photoVC.currentPhotoIndex = self.currentPhotoIndex;
        photoVC.photoId = self.photoId;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //[self downloadMoreImages:40];
    //[self printPhotoWithPageIndex:0];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    for (UIImageView *tmpview in _scrollView.subviews){
        [tmpview removeFromSuperview];
    }
    [_imageSet removeAllObjects];
    _imageSet = nil;
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    _scrollBeginOffset = _scrollView.contentOffset.x;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ((_scrollBeginOffset < _scrollView.contentOffset.y)&&(_scrollView.contentOffset.y != 0.0) && (_scrollView.contentOffset.y != -0.0)){
        
        [self fetchPhotoData];
        currentListPage++;
        [self printPhotoWithPageIndex:currentListPage];
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, (self.row*_imageHeight)*(currentListPage+1))];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}



- (void)printPhotoWithPageIndex:(int)pageIndex
{
  
    if (self.isEnd) {
        return;
    }
    
    int photoCount = [[_fetchedResultsController fetchedObjects]count];
    
    //for (UIImageView *tmpview in _scrollView.subviews){
    //    tmpview.image = [UIImage imageNamed:@"arrow_down.png"];
    //}
    
    for (int rowIndex = 0; rowIndex<self.row; rowIndex++) {
        for(int columnIndex = 0; columnIndex< self.column; columnIndex++){
            int photoIndex = rowIndex*self.column + columnIndex+pageIndex*self.row*self.column;
            if (photoIndex >= photoCount) {
                self.isEnd = true;
                break;
            }
            
            UIImageView *imageView = [[UIImageView alloc ] initWithFrame:CGRectMake(2+columnIndex*(_imageWidth+1), 2+rowIndex*(_imageHeight+1)+pageIndex*_imageHeight*self.row, _imageWidth, _imageHeight)];
            imageView.image = [UIImage imageNamed:@"arrow_down.png"];
            [self.scrollView addSubview:imageView];
            
            
            if(_imageSet != nil){
                if([_imageSet count] > photoIndex){
                    NSLog(@"image debug");
                    //imageView.image = [UIImage imageWithData:[_imageSet objectAtIndex:photoIndex]];
                }
            }else{
                NSLog(@"image set not exist");
            }
            imageView =nil;
        }
        if (self.isEnd) {
            break;
        }
    }
    int downloadCount = MIN(24, [[_fetchedResultsController fetchedObjects]count] - self.row*self.column*currentListPage);
    [self downloadOneFramePhoto:downloadCount];
    
    
}

-(void)downloadOneFramePhoto:(int)frameSize
{
    //call NSURLConnection to start the download
    int printCount = MIN(24, [[_fetchedResultsController fetchedObjects]count]-24*self.currentListPage);
    //    int printCount = frameSize*(self.currentListPage+1);
    if (printCount == 24) {
        printCount = 24*(self.currentListPage+1);
    }else{
        printCount = [[_fetchedResultsController fetchedObjects]count];
    }
    for (int index = 24*self.currentListPage; index < printCount; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *getImagePath = [NSString stringWithFormat:@"%@/%@.jpg", documentsDirectory, photoInfo.photoId];// here you jus need to pass image name that you entered when you stored it.
//        NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:getImagePath];// [NSData dataWithContentsOfFile:getImagePath];
 //       NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
  //      NSData *imageData = [LocalImageManager getLocalImageByPhotoId:photoInfo.photoId];
        if ( photoInfo.imageData == nil) {
            NSString *urlString = [NSString stringWithFormat:@"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg",photoInfo.photoId];
            NSURL *imageURL = [NSURL URLWithString: urlString];
            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
            _connection = [[NSURLConnection alloc ] initWithRequest:theRequest delegate:self];
            
            _receivedData = [[NSMutableData alloc ] init];
            //[_imageSet setObject:_receivedData forKey:urlString];
            NSMutableDictionary *dataAndPhotoIndex = [[NSMutableDictionary alloc] init];
            [dataAndPhotoIndex setObject:_receivedData forKey:[NSString stringWithFormat:@"%d", index]];
            NSMutableDictionary *imageAndURL = [[NSMutableDictionary alloc] init];
            [imageAndURL setObject:dataAndPhotoIndex forKey:urlString];
            [_imageSet setObject:imageAndURL forKey:_connection.description];
            dataAndPhotoIndex = nil;
            imageAndURL = nil;
            
        }else{
            //dispatch_async(_fetchQ, ^{
            UIImageView *tmpsubView = [[_scrollView subviews] objectAtIndex:(index)];
            //UIImage *localimage = [UIImage imageWithData: photoInfo.imageData];

            tmpsubView.image = [UIImage imageWithData: photoInfo.imageData];
      //      photoInfo.imageData = nil;
            
            //localimage = nil;
            //});
        }
        photoInfo = nil;
        indexPath = nil;
        
    }
//    
//    if (_storeDBTimer != nil) {
//        [_storeDBTimer invalidate];
//        _storeDBTimer = nil;
//    }
     
 //   self.storeDBQ = dispatch_queue_create("store db", NULL);
//    dispatch_async(self.fetchQ,^{
//    _storeDBTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
//                                                    target:self
//                                                  selector:@selector(storeData)
//                                                  userInfo:nil
//                                                  repeats:NO];
//    [[NSRunLoop mainRunLoop]addTimer:_storeDBTimer forMode:NSRunLoopCommonModes];
  //          });
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)storeData
{
    NSError *error;
    NSLog(@"%d", self.didCount++);
    if (![self.pvDelegate.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSMutableDictionary *imageAndRUL = [_imageSet objectForKey:connection.description];
    NSMutableData *theReceived = [[[imageAndRUL objectForKey:response.URL] allValues]objectAtIndex:0];
    [theReceived setLength:0];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableDictionary *imageAndRUL = [_imageSet objectForKey:connection.description];
    NSMutableData *theReceived = [[[[imageAndRUL allValues] objectAtIndex:0] allValues]objectAtIndex:0];
    [theReceived appendData:data];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSMutableData *theReceived = [_imageSet objectForKey:[connection description]];
    theReceived = nil;
    connection = nil;
    NSLog(@"connection failed,ERROR %@", [error localizedDescription]);
}

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)saveImageToLocal
{

}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *imageAndURL = [_imageSet objectForKey:connection.description];
    
    NSMutableData *theReceived = [[[[imageAndURL allValues] objectAtIndex:0] allValues]objectAtIndex:0];
    
    UIImage *localimage = [self resizeImage:[UIImage imageWithData:theReceived] newSize:CGSizeMake(80, 80)];

    //CGFloat iscale = MIN( _imageWidth / (localimage.size.width), _imageHeight / (localimage.size.height) );
    
    if (theReceived == nil) {
        NSLog(@"No image data");
    }
    
    int photoIndex = [[[[[imageAndURL allValues] objectAtIndex:0] allKeys]objectAtIndex:0] intValue];
    
    UIImageView *tmpsubView = [[_scrollView subviews] objectAtIndex:(photoIndex)];
    if (tmpsubView != nil){
        tmpsubView.image = localimage;
    }else{
        NSLog(@"No image View");
    }
    

    
    //store to local
    NSString *urlString = [[imageAndURL allKeys] objectAtIndex:0];    
    NSArray *components = [urlString componentsSeparatedByString:@"http://mw2.google.com/mw-panoramio/photos/medium/"];
    NSString *photoIdStr = [components objectAtIndex:1];
 //   NSString *photoId = [[photoIdStr componentsSeparatedByString:@".jpg"]objectAtIndex:0];
//    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    
//    NSString *jpegPath = [NSString stringWithFormat:@"%@/%@",dir, photoIdStr];// this path if you want save reference path in sqlite
//    NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(localimage, 1.0f)];//1.0f = 100% quality
//    [data writeToFile:jpegPath atomically:YES];
//    [LocalImageManager saveLocalImageByPhotoId:photoId withImage:localimage];

    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    photoIdStr = [[photoIdStr componentsSeparatedByString:@"."] objectAtIndex:0];
    fetchPhoto.photoId = photoIdStr;
    NSFetchedResultsController *fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    PhotoInfo *photoInfo = [fetchedResultsController objectAtIndexPath:indexPath];
//    NSData *imageData = UIImageJPEGRepresentation(localimage, 0.3);
    photoInfo.imageData = nil;
    photoInfo.imageData = UIImageJPEGRepresentation(localimage, 0.2);
    localimage = nil;
    
     if (![self.pvDelegate.managedObjectContext save:&error]) {
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     abort();
     }
//    [self.pvDelegate.managedObjectContext reset];

    [_imageSet removeObjectForKey:connection.description];
    [self setConnection: nil];

}

@end
