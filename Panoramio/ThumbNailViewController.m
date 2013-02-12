//
//  ThumbNailViewController.m
//  Panoramio Planet
//
//  Created by fili on 12/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


//#import "ThumbNailViewController.h"
//#import "PlanetViewAppDelegate.h"
//#import "PhotoInfo.h"
//#import "FetchPhotoResult.h"
//#import "ShowLocationViewController.h"
//
//@interface ThumbNailViewController (){
//    FetchPhotoResult *fetchPhotoResult;
//}
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
//@property (nonatomic, strong) NSFetchedResultsController *fetchedFavoriteResultsController;
//@property (nonatomic,strong) NSCache *imageCache;
//@property NSInteger const row;
//@property NSInteger const column;
//@property float imageWidth;
//@property float imageHight;
//@property NSInteger currentListPage;
//@property (nonatomic, strong) UITapGestureRecognizer *subImageTap;
//@property NSInteger currentPhotoIndex;
//@property Boolean isEnd;
//@property Boolean isFavoritePageEnd;
//@property Boolean isCommonPageEnd;
//@property NSString *photoId;
//@property float scrollBeginOffset;
//@end
//
//@implementation ThumbNailViewController
//
//@synthesize scrollView = _scrollView;
//@synthesize fetchedResultsController=_fetchedResultsController;
//@synthesize row;
//@synthesize column;
//@synthesize imageWidth = _imageWidth;
//@synthesize imageHight = _imageHeight;
//@synthesize imageCache;
//@synthesize currentListPage;
//@synthesize isFavorite;
//@synthesize photoId;
//@synthesize scrollBeginOffset = _scrollBeginOffset;
//@synthesize isCommonPageEnd;
//@synthesize isFavoritePageEnd;
//@synthesize fetchedFavoriteResultsController = _fetchedFavoriteResultsController;
//
////NSInteger const row = 6;
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view.
//    self.row =6;
//    self.column = 4;
//    _imageHeight = (_scrollView.frame.size.width-2)/self.column-1;
//    _imageWidth = _imageHeight;
//    self.subImageTap = [[UITapGestureRecognizer alloc]
//                                      initWithTarget:self action:@selector(handleTap:)];
//
//    [self fetchPhotoData];
//    //add UITabBarControllerDelegate
//    PlanetViewAppDelegate* myDelegate = (((PlanetViewAppDelegate*) [UIApplication sharedApplication].delegate));
//    UITabBarController *tabController = (UITabBarController *)myDelegate.window.rootViewController;
//    tabController.delegate = self;
//    self.scrollView.delegate=self;
//    [self.scrollView setContentSize:self.scrollView.frame.size];
//    [_scrollView addGestureRecognizer:self.subImageTap];
//    self.isEnd = NO;
//    self.isFavoritePageEnd = NO;
//    self.isCommonPageEnd = NO;
// //   self.scrollView.contentInset=UIEdgeInsetsMake(64.0,0.0,44.0,0.0);
//}
//
//- (void)fetchPhotoData
//{
//    NSError *error;
//    NSUInteger selectedIndex = self.tabBarController.selectedIndex;
//    
//    if (selectedIndex == 1) {
//        FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
//        fetchPhoto.isFavorite = YES;
//        _fetchedFavoriteResultsController = [fetchPhoto fetchedResultsController];
//        if (![_fetchedFavoriteResultsController performFetch:&error]) {
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }else{
//        FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
//        fetchPhoto.isFavorite = NO;
//        _fetchedResultsController = [fetchPhoto fetchedResultsController];
//        if (![[self fetchedResultsController] performFetch:&error]) {
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//
//}
//
//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
//    if((tabBarController.selectedIndex == 1) || (tabBarController.selectedIndex == 0)){
//        [self fetchPhotoData];
////        self.isCommonPageEnd = NO;
//        if (tabBarController.selectedIndex == 1) {
////            self.isEnd = NO;
//            self.isFavoritePageEnd = NO;
//            NSArray *imageSubviews = _scrollView.subviews;
//            for (UIView *subImageView in imageSubviews) {
//                [subImageView removeFromSuperview];
//            }
//            [self printPhotoWithPageIndex:0];
//        }
//    }
//}
//
//-(void) handleTap:(UIGestureRecognizer*) gesture
//{
//    CGPoint touchPoint=[gesture locationInView:_scrollView];
//    int photoIndex = self.column * ((NSInteger)(touchPoint.y/(_imageHeight+1)))+((NSInteger)touchPoint.x/(_imageWidth+1));
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
//    [self fetchPhotoData];
//    int photoCount = [[_fetchedResultsController fetchedObjects] count];
//    BOOL isInImageScale = NO;
//    if (self.tabBarController.selectedIndex == 0) {
//        isInImageScale = photoIndex < [[_fetchedResultsController fetchedObjects] count];
//    }else if(self.tabBarController.selectedIndex == 1){
//        isInImageScale = photoIndex < [[_fetchedFavoriteResultsController fetchedObjects]count];
//    }
////    NSLog(@"%d %d", photoIndex, [[_fetchedResultsController fetchedObjects] count]);
//    if (isInImageScale) {
//        PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
//        self.photoId = photoInfo.photoId;
//        [self performSegueWithIdentifier:@"showPhotoDetail" sender:self];
//    }
//}
//
//-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"showPhotoDetail"]) {
//        ShowLocationViewController *photoVC = segue.destinationViewController;
//        photoVC.currentPhotoIndex = self.currentPhotoIndex;
//        photoVC.photoId = self.photoId;
//    }
//}
//- (void)viewWillAppear:(BOOL)animated
//{
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    //[self downloadMoreImages:40];
//    [self printPhotoWithPageIndex:0];
//}
//
//- (void)viewDidUnload
//{
//    [self setScrollView:nil];
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return NO;
//}
//
//- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
///*    int pageHeight = (int)scrollView.frame.size.height;
//    int offset = (int)scrollView.contentOffset.y;
//    if (offset%pageHeight > pageHeight/4) {
//        if(currentListPage!=((offset)/(pageHeight-5)+1)){
//            if (offset>pageHeight*(currentListPage-1)) {
//                currentListPage++;
//                [self printPhotoWithPageIndex:currentListPage];
//                [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, (self.row*_imageHeight)*(currentListPage+1))];
//            }
//        }
//    }
// */
//}
//
//-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
//{
//    _scrollBeginOffset = _scrollView.contentOffset.x;
//}
//
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    if ((_scrollBeginOffset < _scrollView.contentOffset.y)&&(_scrollView.contentOffset.y != 0.0) && (_scrollView.contentOffset.y != -0.0)){
//        [self fetchPhotoData];
//        currentListPage++;
//        [self printPhotoWithPageIndex:currentListPage];
//        [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, (self.row*_imageHeight)*(currentListPage+1))];
//    }
//}
//
//- (void)downloadImageWithURL: (NSURL*) imageURL
//                 inImageView:(UIImageView*) imageView;
//{
//    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//    UIImage *image = [UIImage imageWithData:imageData]; 
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        imageView.image = image;
//    });
//}
//
//- (BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//
//
//- (void)printPhotoWithPageIndex:(int)pageIndex
//{
//    //  dispatch_queue_t fetchQ = dispatch_queue_create("data fetcher", NULL);
//    if ((self.isCommonPageEnd)&&(self.tabBarController.selectedIndex == 0)) {
//        return;
//    }
//    if ((self.isFavoritePageEnd)&&(self.tabBarController.selectedIndex == 1)) {
//        return;
//    }
//    dispatch_queue_t fetchQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
//    
//    if (self.imageCache == nil) {
//        self.imageCache = [[NSCache alloc] init];
//    }
//    int photoCount = 0;
//    NSFetchedResultsController *currentFetchedResultsController;
//    if (self.tabBarController.selectedIndex == 0) {
//        photoCount = [[_fetchedResultsController fetchedObjects]count];
//        currentFetchedResultsController = _fetchedResultsController;
//    }else if (self.tabBarController.selectedIndex == 1){
//        photoCount = [[_fetchedFavoriteResultsController fetchedObjects]count];
//        currentFetchedResultsController = _fetchedFavoriteResultsController;
//    }
//    
//    //static dispatch_once_t onceToken;
//    for (int rowIndex = 0; rowIndex<self.row; rowIndex++) {
//        for(int columnIndex = 0; columnIndex< self.column; columnIndex++){
//            int photoIndex = rowIndex*self.column + columnIndex+pageIndex*self.row*self.column;
//            if (photoIndex >= photoCount) {
//                if (self.tabBarController.selectedIndex == 0) {
//                    self.isCommonPageEnd = YES;
//                }else if (self.tabBarController.selectedIndex == 1){
//                    self.isFavoritePageEnd = YES;
//                }
//                return;
//            }
//            
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
//            PhotoInfo *photoInfo = [currentFetchedResultsController objectAtIndexPath:indexPath];
//            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2+columnIndex*(_imageWidth+1), 2+rowIndex*(_imageHeight+1)+pageIndex*_imageHeight*self.row, _imageWidth, _imageHeight)];
//            [self.scrollView addSubview:imageView];
//            imageView.image = [UIImage imageNamed:@"spinner.gif"];
//            dispatch_async(fetchQ, ^{
//                NSString *urlString = [NSString stringWithFormat:@"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg",photoInfo.photoId];
//                NSURL *imageURL = [NSURL URLWithString: urlString];                      
//                NSData *imageData = [self.imageCache objectForKey:[NSNumber numberWithInt:photoIndex]];
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
//        //            dispatch_release(mainQ);
//                }           
//            });
//        }
// //       if (self.isFavoritePageEnd) {
////            break;
// //       }
//    }
// //   dispatch_release(fetchQ);
//}
//
//@end
//
//
//@implementation ThumbNailViewController (LandscapeOrientation)
//
//- (BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//@end

#import "ThumbNailViewController.h"
@interface ThumbNailViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ThumbNailViewController
@synthesize scrollView = _scrollView;

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
    float imageSizeHeight = (_scrollView.frame.size.width-2)/self.column-1;
    super.imageHight = imageSizeHeight;
    super.imageWidth = imageSizeHeight;
    
    self.subImageTap = [[UITapGestureRecognizer alloc]
                        initWithTarget:self action:@selector(handleTap:)];
    
    [self fetchPhotoData];
    //add UITabBarControllerDelegate
    PlanetViewAppDelegate* myDelegate = (((PlanetViewAppDelegate*) [UIApplication sharedApplication].delegate));
    UITabBarController *tabController = (UITabBarController *)myDelegate.window.rootViewController;
    tabController.delegate = self;
    self.scrollView.delegate=self;
    [self.scrollView setContentSize:self.scrollView.frame.size];
    [_scrollView addGestureRecognizer:self.subImageTap];
    NSArray *imageSubviews = _scrollView.subviews;
    for (UIView *subImageView in imageSubviews) {
        [subImageView removeFromSuperview];
    }
    [super setScrollView: _scrollView];
    [super printPhotoWithPageIndex:0];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchPhotoData
{
    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    fetchPhoto.isFavorite = NO;
    NSFetchedResultsController *fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [super setFetchedResultsController: fetchedResultsController];
}

@end
