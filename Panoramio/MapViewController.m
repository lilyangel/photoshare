//
//  MapViewController.m
//  Panoramio
//
//  Created by lily on 1/15/13.
//
//

#import "MapViewController.h"
#import "FetchPhotoResult.h"
#import "pointAnnotation.h"
#import "PhotoViewController.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *annotations;
@property NSString *photoId;
@property Boolean isFavorite;
@property (nonatomic) NSURLConnection *connection;
@end

@implementation MapViewController
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize annotations = _annotations;
@synthesize mapView = _mapView;
@synthesize connection = _connection;

- (void) updateMapView{
    @synchronized(self.mapView.annotations){
    if (self.mapView.annotations)
        [self.mapView removeAnnotations: self.mapView.annotations];
    if (self.annotations)
        [self.mapView addAnnotations:self.annotations]; 
    }
}

-(void) setMapView:(MKMapView *)mapView{
    _mapView = mapView;
    [self updateMapView];
}

- (void) setAnnotations:(NSArray *)annotations{
//    @synchronized(self.annotations){
        _annotations = annotations;
//    }
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
	// Do any additional setup after loading the view.

    self.mapView.delegate = self;
    MKCoordinateSpan span = {.latitudeDelta =  50, .longitudeDelta =  50};
    CLLocationCoordinate2D coordinate = {.latitude= 20, .longitude= -100};
    MKCoordinateRegion region = {coordinate, span};
    [self.mapView setRegion:region animated:YES];
    
    UIPinchGestureRecognizer* mapPinch = [[UIPinchGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleMapChange:)];
    [mapPinch setDelegate:self];
    [self.mapView addGestureRecognizer:mapPinch];
    UIPanGestureRecognizer* mapPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleMapChange:)];
    [mapPan setDelegate:self];
    [self.mapView addGestureRecognizer:mapPan]; 
//    [mapPan setDelegate:self];
    [self updateMap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)handleMapChange:(UIGestureRecognizer*)gesture
{
    if(gesture.state == UIGestureRecognizerStateEnded){
        [self updateMap];
    }
}

- (void)updateMap
{
    //dispatch_queue_t fetchQ = dispatch_queue_create("data fetcher", NULL);

    CGPoint nePoint = CGPointMake(self.mapView.bounds.origin.x + self.mapView.bounds.size.width, self.mapView.bounds.origin.y);
    CGPoint swPoint = CGPointMake((self.mapView.bounds.origin.x), (self.mapView.bounds.origin.y + self.mapView.bounds.size.height));
    CLLocationCoordinate2D neCoord = [self.mapView convertPoint:nePoint toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D swCoord = [self.mapView convertPoint:swPoint toCoordinateFromView:self.mapView];
    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    fetchPhoto.northEastLat = neCoord.latitude;
    fetchPhoto.northEastLng = neCoord.longitude;
    fetchPhoto.southWestLat = swCoord.latitude;
    fetchPhoto.southWestLng = swCoord.longitude;
    
    _fetchedResultsController = [fetchPhoto fetchedResultsController];
    
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSMutableArray *mutableAnnotations = [NSMutableArray array];
    //dispatch_async(fetchQ, ^{
        int photoNumber = MIN(5, [[_fetchedResultsController fetchedObjects] count]);
      for(int i = 0;i<photoNumber;i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
        pointAnnotation *pointAnnt = [[pointAnnotation alloc]init];
        CLLocationCoordinate2D coordinate = {.latitude= [photoInfo.latitude doubleValue], .longitude= [photoInfo.longtitude doubleValue]};
        pointAnnt.photoId = photoInfo.photoId;
        [mutableAnnotations addObject:[pointAnnt annotationForPhotowithCoordinate:coordinate]];
      }
    //    NSArray *inmutableAnnotations = [mutableAnnotations copy];
      self.annotations = mutableAnnotations;
    //});
//    dispatch_release(fetchQ);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    @try {

    MKPinAnnotationView *pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    NSString *urlString = [NSString stringWithFormat:@"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg",((pointAnnotation*)annotation).photoId];
    NSURL *imageURL = [NSURL URLWithString: urlString];
        
    dispatch_queue_t localQ = dispatch_queue_create("data fetcher", NULL);
        
    dispatch_async(localQ, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        pav.image = [self resizeImage:image newSize:CGSizeMake(25, 20)];

    });
    return pav;
    }
    @catch (NSException *exception) {
        NSLog(@"set annotations %@", exception.description);
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    @try {
        pointAnnotation *pa = view.annotation;
        self.photoId = pa.photoId;
        NSLog(@"mapview click photoId %@", pa.photoId);
        NSError *error;
        FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
        fetchPhoto.photoId = pa.photoId;
        NSFetchedResultsController *fetchedResultsController = [fetchPhoto fetchedResultsController];
        if (![fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        PhotoInfo *photoInfo = [fetchedResultsController objectAtIndexPath:indexPath];
        self.isFavorite = photoInfo.isFavorite;
        [self performSegueWithIdentifier:@"MapToPhoto" sender:self];
    }
    @catch(NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MapToPhoto"]) {
        PhotoViewController *photoVC = segue.destinationViewController;
        photoVC.photoId = self.photoId;
        photoVC.isFavorite = self.isFavorite;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}
@end
