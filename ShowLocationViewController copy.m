//
//  ShowLocationViewController.m
//  Panoramio Planet
//
//  Created by fili on 1/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ShowLocationViewController.h"
#import "FetchPhotoResult.h"

@interface ShowLocationViewController (){
    UIImageView *_zoomView;
    CGSize _imageSize;
    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) NSCache *imageCache;
@property (nonatomic, strong) UIPageControl * pageControl;
@end

@implementation ShowLocationViewController
@synthesize scrollView = _scrollView;
@synthesize currentPhotoIndex;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize imageCache;

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
    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    _fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    self.scrollView.delegate=self;
    currentPhotoIndex = 0;
/*
    [self addPhoto:_scrollView index:currentPhotoIndex withImageSize:_scrollView.frame.size];
    currentPhotoIndex = 1;
    [self addPhoto:_scrollView index:currentPhotoIndex withImageSize:_scrollView.frame.size];
 //   UIPanGestureRecognizer* photoPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    //  [photoPan setDelegate:self];
   //   [self.scrollView addGestureRecognizer:photoPan];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width+1, self.scrollView.frame.size.height)];
    self.wantsFullScreenLayout = YES;
 */
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bouncesZoom = YES;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.pagingEnabled = YES;
//    _scrollView.alwaysBounceHorizontal = NO;
 //   _scrollView.alwaysBounceVertical = NO;

        _zoomView = [[UIImageView alloc] init];

    UIImageView *imageView1 =
    [self displayImage:[self imageAtIndex:currentPhotoIndex] withPageIndex:currentPhotoIndex];
//    [self configureForImageSize:[self imageAtIndex:currentPhotoIndex].size];
    [_zoomView addSubview:imageView1];
    currentPhotoIndex++;
    
    UIImageView *imageView2 = 
    [self displayImage:[self imageAtIndex:currentPhotoIndex] withPageIndex:currentPhotoIndex];
//    [self configureForImageSize:[self imageAtIndex:currentPhotoIndex].size];
    
    [_zoomView addSubview:imageView2];
    [self prepareToResize];
    [self recoverFromResizing];
    [_scrollView addSubview:_zoomView];
    self.pageControl = [[UIPageControl alloc]init];
    self.pageControl.frame = CGRectMake(110,5,100,100);
    self.pageControl.numberOfPages = 2;
    self.pageControl.currentPage = 0;
    [_scrollView addSubview:self.pageControl];
    [_scrollView setContentSize:CGSizeMake(320*(currentPhotoIndex+1), _scrollView.frame.size.height)];
    NSLog(@"scroll view content size %f, %f", _scrollView.contentSize.width, _scrollView.contentSize.height);
}
/*
-(void) handlePan:(UIGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"test");
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        currentPhotoIndex++;
        [self addPhoto:self.scrollView index:currentPhotoIndex];
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width*(currentPhotoIndex+1), _scrollView.bounds.size.height);
        _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width*currentPhotoIndex, 0); 
    }
}*/
- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
- (void) scrollViewDidScroll:(UIScrollView *)scrollView{

    int photoWidth = (int)scrollView.frame.size.width;
    int offset = (int)scrollView.contentOffset.x;
    //    displayedNextPage = false;
    //  NSLog(@"%d,%d",pageHight,offset);
    //   if((offset%pageHight > pageHight/4)&&(currentListPage!=(offset/pageHight+1))&&(offset>pageHight*(currentListPage-1))){
    if (offset%photoWidth > photoWidth/4) {
    //    NSLog(@"%d,%d",currentPhotoIndex,offset);
        if((currentPhotoIndex-1)<((offset)/(photoWidth)+1)){
              NSLog(@"%d",offset);
            if (offset>photoWidth*(currentPhotoIndex-1)) {
                    NSLog(@"%d",currentPhotoIndex);
                currentPhotoIndex++;
                [self addPhoto:self.scrollView index:currentPhotoIndex withImageSize:CGSizeMake(320, 293)];
                _scrollView.contentSize = CGSizeMake(320*(currentPhotoIndex+1), _scrollView.contentSize.height);
                _scrollView.contentOffset = CGPointMake(320*currentPhotoIndex, 0);
        //        NSLog(@"%d",_scrollView.contentOffset.x);
            }
        }
    }
}
*/
- (void) addPhoto:(UIScrollView *)scrollView index:(int)photoIndex withImageSize:(CGSize) imageSize{
    if (self.imageCache == nil) {
        self.imageCache = [[NSCache alloc] init];
    } 
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
    PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
 //   UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake((scrollView.contentSize.width)*currentPhotoIndex+3, 3, (scrollView.contentSize.width)*(currentPhotoIndex+1)-3, scrollView.contentSize.height)];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake((imageSize.width)*currentPhotoIndex+3, 3, (imageSize.width)*(currentPhotoIndex+1)-3, imageSize.height)];
    NSLog(@"%f,%f,%f,%f",imageView.frame.size.width, imageView.frame.size.height,scrollView.bounds.size.width,scrollView.bounds.size.height);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:imageView];
    NSString *urlString = [NSString stringWithFormat:@"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg",photoInfo.photoId];
    NSURL *imageURL = [NSURL URLWithString: urlString];
    
    //    NSData *imageData = [self.imageCache objectForKey:[NSNumber numberWithInt:photoIndex]];
    /*    if(imageData != nil){
     UIImage *image = [UIImage imageWithData:imageData]; 
     imageView.image = image;
     }else{*/
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    //    [self.imageCache setObject:imageData forKey:[NSNumber numberWithInt:photoIndex]]; 
    
    UIImage *image = [UIImage imageWithData:imageData]; 
    imageView.image = image; 
    //    }
  //  _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width*(currentPhotoIndex+1), _scrollView.bounds.size.height);
  //  _scrollView.contentOffset = CGPointMake(_scrollView.bounds.size.width*currentPhotoIndex, 0); 
}
- (UIImage*) imageAtIndex:(NSUInteger) photoIndex
{
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
    // clear the previous image
//    [_zoomView removeFromSuperview];
 //   _zoomView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    _scrollView.zoomScale = 1.0;
    
    // make a new UIImageView for the new image
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(image.size.width*pageIndex, 0, image.size.width,  image.size.height);
    NSLog(@"frame %f,%f", imageView.frame.size.height,imageView.frame.size.width);
//    [_scrollView setContentSize:CGSizeMake(320*(currentPhotoIndex+1), _scrollView.frame.size.height)];
    [self configureForImageSize:image.size];
    
    return imageView;

}

- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
//    _scrollView.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    _scrollView.zoomScale = _scrollView.minimumZoomScale;
   // _scrollView.zoomScale = 0.3;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = _scrollView.bounds.size;
    //    CGSize boundsSize = CGSizeMake(self.bounds.size.height/2, self.bounds.size.width);
    NSLog(@"self bounds size %f, %f",boundsSize.height, boundsSize.width);
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
    NSLog(@"%f",_scrollView.zoomScale);
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
//    [self makeOffset];
}
-(void) makeOffset
{
    NSLog(@"scrollView %f", _scrollView.contentOffset.x);
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


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
 /*   int page = scrollView.contentOffset.x/scrollView.frame.size.width;
    NSLog(@"%d",page);
    self.pageControl.currentPage=page;*/
 //   [self makeOffset];
    currentPhotoIndex++;
    [_scrollView setContentSize:CGSizeMake(320*(currentPhotoIndex+1), _scrollView.frame.size.height)];
//    UIImageView *imageView2 =
 //   [self displayImage:[self imageAtIndex:currentPhotoIndex] withPageIndex:currentPhotoIndex];
    UIImage *image = [self imageAtIndex:currentPhotoIndex];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(image.size.width*currentPhotoIndex, 0, image.size.width,  image.size.height);
    [_zoomView addSubview:imageView];
    NSLog(@"offset %f",scrollView.contentOffset.x);
/*    [_zoomView addSubview:imageView2];
    [self prepareToResize];
    [self recoverFromResizing];
    
 //   [self makeOffset];
      int page = scrollView.contentOffset.x/scrollView.frame.size.width;
     NSLog(@"%f",scrollView.contentOffset.x);
 //    self.pageControl.currentPage=page;*/
}

@end
