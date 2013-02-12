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
@interface ThumbNailSuperViewController ()
@property PlanetViewAppDelegate *pvDelegate;
@property dispatch_queue_t fetchQ;
@property NSInteger didCount;
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
    //_fetchQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    self.fetchQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
}

- (void)fetchPhotoData
{
    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    fetchPhoto.isFavorite = NO;
    _fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
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
//        dispatch_async(_fetchQ, ^{

        [self fetchPhotoData];
        currentListPage++;
        [self printPhotoWithPageIndex:currentListPage];
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, (self.row*_imageHeight)*(currentListPage+1))];
//        });
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}



- (void)printPhotoWithPageIndex:(int)pageIndex
{
    //  dispatch_queue_t fetchQ = dispatch_queue_create("data fetcher", NULL);
    if (self.isEnd) {
        return;
    }
    
    
    if (self.imageCache == nil) {
        self.imageCache = [[NSCache alloc] init];
    }
    int photoCount = [[_fetchedResultsController fetchedObjects]count];
    
    
//    dispatch_async(_fetchQ, ^{
    
    for (int rowIndex = 0; rowIndex<self.row; rowIndex++) {
        for(int columnIndex = 0; columnIndex< self.column; columnIndex++){
            int photoIndex = rowIndex*self.column + columnIndex+pageIndex*self.row*self.column;
            if (photoIndex >= photoCount) {
                self.isEnd = true;
                break;
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2+columnIndex*(_imageWidth+1), 2+rowIndex*(_imageHeight+1)+pageIndex*_imageHeight*self.row, _imageWidth, _imageHeight)];

            [self.scrollView addSubview:imageView];
           imageView.image = [UIImage imageNamed:@"arrow_down.png"];
            
            
            
            if(_imageSet != nil){
                if([_imageSet count] > photoIndex){
                    //imageView.image = [UIImage imageWithData:[_imageSet objectAtIndex:photoIndex]];
                }
            }else{
                 NSLog(@"image set not exist");
            }
        }
        if (self.isEnd) {
            break;
        }
    }
    int downloadCount = MIN(24, [[_fetchedResultsController fetchedObjects]count] - self.row*self.column*currentListPage);
    [self downloadOneFramePhoto:downloadCount];
    /*
    //dispatch_async(fetchQ, ^{
    //static dispatch_once_t onceToken;
    NSIndexPath *indexPath;
    PhotoInfo *photoInfo;
    UIImageView * imageView;


    
    for (int rowIndex = 0; rowIndex<self.row; rowIndex++) {
        for(int columnIndex = 0; columnIndex< self.column; columnIndex++){
            int photoIndex = rowIndex*self.column + columnIndex+pageIndex*self.row*self.column;
            if (photoIndex >= photoCount) {
                self.isEnd = true;
                return;
            }
            
            indexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
            photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2+columnIndex*(_imageWidth+1), 2+rowIndex*(_imageHeight+1)+pageIndex*_imageHeight*self.row, _imageWidth, _imageHeight)];
            //NSLog(@"%f, %f, %f, %f", imageView.frame.size.height, imageView.frame.size.width, imageView.frame.origin.x, imageView.frame.origin.y);
            [self.scrollView addSubview:imageView];
            imageView.image = [UIImage imageNamed:@"shared.png"];
            dispatch_async(_fetchQ, ^{
                NSString *urlString = [NSString stringWithFormat:@"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg",photoInfo.photoId];
                NSURL *imageURL = [NSURL URLWithString: urlString];
                //NSData *imageData = [self.imageCache objectForKey:[NSNumber numberWithInt:photoIndex]];
                NSData *imageFromDB = photoInfo.imageData;
                
                UIImage *limage;
                if (imageFromDB == nil) {
                    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                    photoInfo.imageData = imageData;
                    //NSError *error;
                    //if (![self.pvDelegate.managedObjectContext save:&error]) {
                    //    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //    abort();
                    //}
                    [self.imageCache setObject:imageData forKey:[NSNumber numberWithInt:photoIndex]];
                    limage = [UIImage imageWithData:imageData];
                }else{
                    limage = [UIImage imageWithData:imageFromDB];
                }
                dispatch_queue_t mainQ = dispatch_get_main_queue();
                dispatch_sync(mainQ, ^{
                    imageView.image = limage;
                });

//                if(imageData != nil){
//                    UIImage *image = [UIImage imageWithData:imageData];
//                    imageView.image = image;
//                }else{
//                    imageData = [NSData dataWithContentsOfURL:imageURL];
//                    [self.imageCache setObject:imageData forKey:[NSNumber numberWithInt:photoIndex]];
//                    UIImage *image = [UIImage imageWithData:imageData];
//                    dispatch_queue_t mainQ = dispatch_get_main_queue();
//                    dispatch_sync(mainQ, ^{
//                        imageView.image = image;
//                    });
//                }
            });
        }
    } */
    
    
    
    //try another solution: download the data first, then fetch image from global varible: imageSet.
    
    
    
    
    
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
//        if (photoInfo.imageData == nil) {
        NSString *urlString = [NSString stringWithFormat:@"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg",photoInfo.photoId];
        NSURL *imageURL = [NSURL URLWithString: urlString];
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
        _connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        _receivedData = [[NSMutableData alloc] init];
        //[_imageSet setObject:_receivedData forKey:urlString];
        NSMutableDictionary *dataAndPhotoIndex = [[NSMutableDictionary alloc]init];
        [dataAndPhotoIndex setObject:_receivedData forKey:[NSString stringWithFormat:@"%d", index]];
        NSMutableDictionary *imageAndURL = [[NSMutableDictionary alloc]init];
        [imageAndURL setObject:dataAndPhotoIndex forKey:urlString];
        [_imageSet setObject:imageAndURL forKey:_connection.description];
/*        }else{
            dispatch_async(_fetchQ, ^{
            UIImageView *tmpsubView = [[_scrollView subviews] objectAtIndex:(index)];
            tmpsubView.image = [UIImage imageWithData: photoInfo.imageData];
            });
        }
 */
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    NSMutableData *theReceived = [_imageSet objectForKey:[connection description]];
    NSMutableDictionary *imageAndRUL = [_imageSet objectForKey:connection.description];
    NSMutableData *theReceived = [[[imageAndRUL objectForKey:response.URL] allValues]objectAtIndex:0];

    [theReceived setLength:0];

}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSMutableData *theReceived = [_imageSet objectForKey:[connection description]];
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


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *imageAndURL = [_imageSet objectForKey:connection.description];

    NSMutableData *theReceived = [[[[imageAndURL allValues] objectAtIndex:0] allValues]objectAtIndex:0];
    if (theReceived == nil) {
        NSLog(@"No image data");
    }
    
    int photoIndex = [[[[[imageAndURL allValues] objectAtIndex:0] allKeys]objectAtIndex:0] intValue];
    
    UIImageView *tmpsubView = [[_scrollView subviews] objectAtIndex:(photoIndex)];
    if (tmpsubView != nil){
        tmpsubView.image = [UIImage imageWithData:theReceived];
    }else{
        NSLog(@"No image View");
    }
    self.didCount++;

    [_imageSet removeObjectForKey:connection.description];
    [self setConnection: nil];
/*    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    fetchPhoto.photoId = photoIdStr;
    NSFetchedResultsController *fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    PhotoInfo *photoInfo = [fetchedResultsController objectAtIndexPath:indexPath];
    photoInfo.imageData = theReceived;
    if (![self.pvDelegate.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }*/
}

@end
