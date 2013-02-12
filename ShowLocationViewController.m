//
//  ShowLocationViewController.m
//  Panoramio Planet
//
//  Created by fili on 1/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ShowLocationViewController.h"
#import "FetchPhotoResult.h"
#import "pointAnnotation.h"
#import "PhotoViewController.h"
@interface ShowLocationViewController (){
    UIImageView *_zoomView;
    CGSize _imageSize;
    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) NSCache *imageCache;
@property (nonatomic, strong) UIPageControl * pageControl;
@property float offsetX;
@property int mapViewSpan;
@property int autoZoom;
@property double lat;
@property double lng;
@property (strong, nonatomic) NSArray *annotations;
@property NSInteger pageIndex;
@property NSInteger currentDisplayPhoto;
@property float scrollBeginOffset;

@property (nonatomic, strong) UITapGestureRecognizer *imageTap;
@property (nonatomic, strong) pointAnnotation *pointAnnt;
@property Boolean currentPhotoIsFavorite;
@end

@implementation ShowLocationViewController
@synthesize scrollView = _scrollView;
@synthesize currentPhotoIndex;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize imageCache;
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize pageIndex = _pageIndex;
@synthesize currentDisplayPhoto = _currentDisplayPhoto;
@synthesize scrollBeginOffset = _scrollBeginOffset;
@synthesize photoId = _photoId;
@synthesize imageTap;
@synthesize pointAnnt;
@synthesize currentPhotoIsFavorite;

- (void) updateMapView{
    if (self.mapView.annotations)
        [self.mapView removeAnnotations: self.mapView.annotations];
    if (self.annotations)
        [self.mapView addAnnotations:self.annotations];
}

- (void) setMapView:(MKMapView *)mapView{
    _mapView = mapView;
    [self updateMapView];
}

- (void) setAnnotations:(NSArray *)annotations{
    _annotations = annotations;
    [self updateMapView];
}

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
    @try {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapViewSpan = 50;
    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    if (self.photoId) {
        fetchPhoto.photoId = self.photoId;
    }
    _fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    self.scrollView.delegate=self;

    _currentDisplayPhoto = currentPhotoIndex;
    
    _pageIndex = 0;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bouncesZoom = YES;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.pagingEnabled = YES;
    _zoomView = [[UIImageView alloc] init];
    dispatch_queue_t fetchQ = dispatch_queue_create("data fetcher", NULL);
    [self displayImage:[self imageAtIndex:currentPhotoIndex] withPageIndex:_currentDisplayPhoto];
    currentPhotoIndex++;
 //   dispatch_async(fetchQ, ^{

        if (currentPhotoIndex < [[self.fetchedResultsController fetchedObjects]count]) {
            _pageIndex++;
            [self displayImage:[self imageAtIndex:currentPhotoIndex] withPageIndex:_currentDisplayPhoto+1];
        }
  //          });
        [_scrollView addSubview:_zoomView];
        [_scrollView setContentSize:CGSizeMake(320*(_pageIndex+1), _scrollView.frame.size.height)];
        self.offsetX = 0.0;
        [self updateMapInfo];

    self.imageTap = [[UITapGestureRecognizer alloc]
                        initWithTarget:self action:@selector(handlePhotoTap:)];
    [self.scrollView addGestureRecognizer:imageTap];

    }
    @catch (NSException *exception) {
        @throw(@"did not load show location view. %@", exception.description);
    }
}

-(void)handlePhotoTap: (UIGestureRecognizer*) gesture
{
    [self performSegueWithIdentifier:@"ShowPhoto" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowPhoto"]) {
        PhotoViewController *photoVC = segue.destinationViewController;
        photoVC.photoId = _photoId;
        photoVC.isFavorite = self.currentPhotoIsFavorite;
    }
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (UIImage*) imageAtIndex:(NSUInteger) photoIndex
{
    if(photoIndex>=[[self.fetchedResultsController fetchedObjects]count])
        return nil;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
    PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSString *urlString = [NSString stringWithFormat:@"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg",photoInfo.photoId];
    NSURL *imageURL = [NSURL URLWithString: urlString];
    //   dispatch_async(fetchQ, ^{
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}

- (UIImageView*)displayImage:(UIImage *)image withPageIndex:(NSInteger)pageIndex
{
    if (image == nil) {
        return nil;
    }
//    _scrollView.zoomScale = 1.0;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGFloat widthScale = image.size.width/self.scrollView.bounds.size.width;
    CGFloat heightScale = image.size.height/self.scrollView.bounds.size.height;
    NSInteger newImageHeight, newImageWidth;
    if (widthScale>=heightScale) {
        newImageHeight = self.scrollView.bounds.size.height*(self.scrollView.bounds.size.width/image.size.width);
        newImageWidth = self.scrollView.bounds.size.width;
    }else{
        newImageHeight = self.scrollView.bounds.size.height;
        newImageWidth = self.scrollView.bounds.size.width*(self.scrollView.bounds.size.height/image.size.height);
    }
    
    image = [self resizeImage:image newSize:CGSizeMake(newImageWidth, newImageHeight)];
    if (widthScale>=heightScale) {
        imageView.frame = CGRectMake(self.scrollView.bounds.size.width*_pageIndex,(self.scrollView.bounds.size.height- newImageHeight)/2, newImageWidth, newImageHeight);
    }else{
        imageView.frame = CGRectMake(self.scrollView.bounds.size.width*_pageIndex+(self.scrollView.bounds.size.width - newImageWidth)/2, 0, newImageWidth, newImageHeight);
    }
    [_zoomView addSubview: imageView];
    return imageView;
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

- (void) updateRegionWithCoordinate:(CLLocationCoordinate2D) coordinate{
    MKCoordinateSpan span = {.latitudeDelta =  self.mapViewSpan, .longitudeDelta =  self.mapViewSpan};
    MKCoordinateRegion region = {coordinate, span};
    [self.mapView setRegion:region animated:YES];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    _scrollBeginOffset = scrollView.contentOffset.x;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ((_scrollBeginOffset < _scrollView.contentOffset.x)&&(_scrollView.contentOffset.x != 0.0) && (_scrollView.contentOffset.x != -0.0)) {
        currentPhotoIndex++;
        _pageIndex++;
        [_scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width*(_pageIndex+1), _scrollView.frame.size.height)];
        self.offsetX = _scrollView.contentOffset.x;
        [self displayImage:[self imageAtIndex:currentPhotoIndex] withPageIndex:_pageIndex];
        _currentDisplayPhoto++;
    }else{
        if(_currentDisplayPhoto>0){
            _currentDisplayPhoto--;
        }
    }
    [self updateMapInfo];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pav.image = [UIImage imageNamed:@"location.png"];    //as suggested by Squatch
    return pav;
}

- (NSArray*) mapAnnotationwithCoordinate:(CLLocationCoordinate2D) coordinate
{
    NSMutableArray *annotations = [NSMutableArray array];
    pointAnnotation *pointAnnt = [[pointAnnotation alloc]init];
    [annotations addObject:[pointAnnt annotationForPhotowithCoordinate:coordinate]];
    return annotations;
}

- (void*) updateMapInfo
{
//    NSInteger currentPhotoIndex = _scrollView.contentOffset.x/_scrollView.frame.size.width;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentDisplayPhoto inSection:0];
    PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSArray *components = [photoInfo.position componentsSeparatedByString:@","];
    self.lat = [[components objectAtIndex:0] doubleValue];
    self.lng = [[components objectAtIndex:1] doubleValue];
    _photoId = photoInfo.photoId;
    self.currentPhotoIsFavorite = photoInfo.isFavorite;
    CLLocationCoordinate2D coordinate = {.latitude= self.lat, .longitude= self.lng};
    self.annotations = [self mapAnnotationwithCoordinate:coordinate];
    [self updateRegionWithCoordinate:coordinate];
}

@end
