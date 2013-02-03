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
//    _scrollView.alwaysBounceHorizontal = NO;
 //   _scrollView.alwaysBounceVertical = NO;

        _zoomView = [[UIImageView alloc] init];

    UIImageView *imageView1 =
    [self displayImage:[self imageAtIndex:currentPhotoIndex] withPageIndex:_currentDisplayPhoto];

    if (imageView1 != nil) {
        [_zoomView addSubview:imageView1];
    }
    
    currentPhotoIndex++;
    int count = [[self.fetchedResultsController fetchedObjects]count];
    if (currentPhotoIndex < [[self.fetchedResultsController fetchedObjects]count]) {
        _pageIndex++;
    
        UIImageView *imageView2 = 
        [self displayImage:[self imageAtIndex:currentPhotoIndex] withPageIndex:_currentDisplayPhoto+1];
    
        [_zoomView addSubview:imageView2];
    }
    
//    [self prepareToResize];
//    [self recoverFromResizing];
    [_scrollView addSubview:_zoomView];
    [_scrollView setContentSize:CGSizeMake(320*(_pageIndex+1), _scrollView.frame.size.height)];
    self.offsetX = 0.0;
    [self updateMapInfo];
//    _scrollView.zoomScale = 0.64;
    NSLog(@"%f",_scrollView.zoomScale);
    self.imageTap = [[UITapGestureRecognizer alloc]
                        initWithTarget:self action:@selector(handlePhotoTap:)];
    [self.scrollView addGestureRecognizer:imageTap];
}

-(void)handlePhotoTap: (UIGestureRecognizer*) gesture
{
    [self performSegueWithIdentifier:@"ShowPhoto" sender:self];
}

-(void)displayPhotoInArea: (UIGestureRecognizer*) gesture
{
    
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
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}

- (UIImageView*)displayImage:(UIImage *)image withPageIndex:(NSInteger)pageIndex
{
    if (image == nil) {
        return nil;
    }
    _scrollView.zoomScale = 1.0;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    if (image.size.height > image.size.width) {
        float newImageWidth = image.size.width * 375/500;
        image = [self resizeImage:image newSize:CGSizeMake(newImageWidth, 375)];
    }

    if (image.size.height > image.size.width) {
        imageView.frame = CGRectMake(500*_pageIndex+(500-image.size.width)/2, 25, image.size.width,  image.size.height);
    }else{
        imageView.frame = CGRectMake(500*_pageIndex, 25, image.size.width,  image.size.height);
    }

//    imageView.frame = CGRectMake(image.size.width*pageIndex, 25, image.size.width,  image.size.height);

    [self configureForImageSize:image.size];
    
    return imageView;

}

- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
//    _scrollView.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
//    _scrollView.zoomScale = _scrollView.minimumZoomScale;
    _scrollView.zoomScale = 0.64;
   // _scrollView.zoomScale = 0.3;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = _scrollView.bounds.size;
    //    CGSize boundsSize = CGSizeMake(self.bounds.size.height/2, self.bounds.size.width);
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    BOOL imagePortrait = _imageSize.height > _imageSize.width;
    BOOL phonePortrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    _scrollView.maximumZoomScale = maxScale;
    _scrollView.minimumZoomScale = minScale;
    _scrollView.minimumZoomScale = 0.64;
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

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(_scrollView.bounds), CGRectGetMidY(_scrollView.bounds));
    _pointToCenterAfterResize = [_scrollView convertPoint:boundsCenter toView:_zoomView];
    
    _scaleToRestoreAfterResize = _scrollView.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= _scrollView.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
 //   CGFloat maxZoomScale = MAX(_scrollView.minimumZoomScale, _scaleToRestoreAfterResize);
 //   float maxZoomScale = _scrollView.minimumZoomScale;
    _scrollView .zoomScale = MIN(_scrollView.maximumZoomScale, _scrollView.minimumZoomScale);
  //  _scrollView.zoomScale = maxZoomScale;
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
//    [self makeOffset];
}
-(void) makeOffset
{
    CGPoint boundsCenter = [_scrollView convertPoint:_pointToCenterAfterResize fromView:_zoomView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - _scrollView.bounds.size.width / 2.0,
                                 boundsCenter.y - _scrollView.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    _scrollView.contentOffset = offset;
}
- (CGPoint)maximumContentOffset
{
    CGSize contentSize = _scrollView.contentSize;
    CGSize boundsSize = _scrollView.bounds.size;
    //   CGSize boundsSize = CGSizeMake(self.bounds.size.height/2, self.bounds.size.width);
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomView;
    
//    return [_scrollView.subviews objectAtIndex:0];
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
    NSLog(@"%f",_scrollView.contentOffset.x);
    if ((_scrollBeginOffset < _scrollView.contentOffset.x)&&(_scrollView.contentOffset.x != 0.0) && (_scrollView.contentOffset.x != -0.0)) {
        currentPhotoIndex++;
        _pageIndex++;
        [_scrollView setContentSize:CGSizeMake(320*(_pageIndex+1), _scrollView.frame.size.height)];
        self.offsetX = _scrollView.contentOffset.x;
        UIImage *image = [self imageAtIndex:currentPhotoIndex];
        if (image.size.height > image.size.width) {
            float newImageWidth = image.size.width * 375/500;
            image = [self resizeImage:image newSize:CGSizeMake(newImageWidth, 375)];
        }
  //      if (image!=nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        if (image.size.height > image.size.width) {
            imageView.frame = CGRectMake(500*_pageIndex+(500-image.size.width)/2, 25, image.size.width,  image.size.height);
        }else{
            imageView.frame = CGRectMake(500*_pageIndex, 25, image.size.width,  image.size.height);
        }
        [_zoomView addSubview:imageView];

   //     }
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
