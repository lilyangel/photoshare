//
//  ThumbNailViewController.m
//  Panoramio Planet
//
//  Created by fili on 12/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThumbNailViewController.h"
#import "PlanetViewAppDelegate.h"
#import "PhotoInfo.h"
#import "FetchPhotoResult.h"
#import "ShowLocationViewController.h"

@interface ThumbNailViewController (){
    FetchPhotoResult *fetchPhotoResult;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) NSCache *imageCache;
@property NSInteger row;
@property NSInteger column;
@property float imageWidth;
@property float imageHight;
@property NSInteger currentListPage;
@property (nonatomic, strong) UITapGestureRecognizer *subImageTap;
@property NSInteger currentPhotoIndex;
@property Boolean isEnd;
@property NSString *photoId;
@end

@implementation ThumbNailViewController

@synthesize scrollView = _scrollView;
//@synthesize managedObjectContext;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize row = _row;
@synthesize column = _column;
@synthesize imageWidth = _imageWidth;
@synthesize imageHight = _imageHeight;
@synthesize imageCache;
@synthesize currentListPage;
@synthesize isFavorite;
@synthesize photoId;

static NSInteger _row = 6;
static NSInteger _column = 4;

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
 //   _row =6;
 //   _column = 4;
    _imageHeight = (_scrollView.frame.size.width-2)/4-1;
    _imageWidth = _imageHeight;
    self.subImageTap = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleTap:)];

    [self fetchPhotoData];
    //add UITabBarControllerDelegate
    PlanetViewAppDelegate* myDelegate = (((PlanetViewAppDelegate*) [UIApplication sharedApplication].delegate));
    UITabBarController *tabController = (UITabBarController *)myDelegate.window.rootViewController;
    //    NSUserDefaults*defaults = [NSUserDefaults standardUserDefaults];
    //    tabController.selectedIndex = [defaults integerForKey:@"item 1"];
    tabController.delegate = self;
    self.scrollView.delegate=self;
    [self.scrollView setContentSize:self.scrollView.frame.size];
    [_scrollView addGestureRecognizer:self.subImageTap];
    self.isEnd = NO;
 //   self.scrollView.contentInset=UIEdgeInsetsMake(64.0,0.0,44.0,0.0);
}

- (void)fetchPhotoData
{
    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    NSUInteger selectedIndex = self.tabBarController.selectedIndex;
    
    if (selectedIndex == 1) {
        fetchPhoto.isFavorite = YES;
    }else{
        fetchPhoto.isFavorite = NO;
    }
    _fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    int counts = [[_fetchedResultsController fetchedObjects] count];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if(tabBarController.selectedIndex == 1){
        self.isEnd = NO;
        int i = 0;
        /*
    for (UIView *subView in [self.scrollView subviews])
    {
        if ([subView isKindOfClass:[UIImageView class]]) {
            if (subView.frame.size.height == 79) {
                [subView removeFromSuperview];
                i++;
            }
        }

    }*/
        
        [self fetchPhotoData];
        [self printPhotoWithPageIndex:0];
    }
}

-(void) handleTap:(UIGestureRecognizer*) gesture
{
    CGPoint touchPoint=[gesture locationInView:_scrollView];
    NSLog(@"click image %f, %f", touchPoint.x, touchPoint.y);
    int photoIndex = self.column * ((NSInteger)(touchPoint.y/(_imageHeight+1)))+((NSInteger)touchPoint.x/(_imageWidth+1));
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
    PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
    self.photoId = photoInfo.photoId;
    [self performSegueWithIdentifier:@"showPhotoDetail" sender:self];
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
    [self printPhotoWithPageIndex:0];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
    int pageHeight = (int)scrollView.frame.size.height;
    int offset = (int)scrollView.contentOffset.y;
    //    displayedNextPage = false;
    //  NSLog(@"%d,%d",pageHight,offset);
    //   if((offset%pageHight > pageHight/4)&&(currentListPage!=(offset/pageHight+1))&&(offset>pageHight*(currentListPage-1))){
    if (offset%pageHeight > pageHeight/4) {
        NSLog(@"%d,%d",currentListPage,offset);
        if(currentListPage!=((offset)/(pageHeight-30)+1)){
            //  NSLog(@"%d",currentListPage);
            if (offset>pageHeight*(currentListPage-1)) {
                currentListPage++;
                NSLog(@"%f,%d,%d, %d",scrollView.contentOffset.y, pageHeight,currentListPage, offset/pageHeight+1);
                //        NSString *script = [NSString stringWithFormat:];
                //        [self.photoListView stringByEvaluatingJavaScriptFromString:@"clickNext()"];
                [self printPhotoWithPageIndex:currentListPage];
                [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, (self.row*_imageHeight)*(currentListPage+1))];
                //    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height*currentListPage);
                //     NSLog(@"%f",self.scrollView.frame.size.height);
                //    [self.scrollView setContentOffset: bottomOffset animated:YES];
            }
        }
    }
}

- (void)downloadImageWithURL: (NSURL*) imageURL
                 inImageView:(UIImageView*) imageView;
{
    
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData]; 
    dispatch_sync(dispatch_get_main_queue(), ^{
        imageView.image = image;
    });
}



- (void)printPhotoWithPageIndex:(int)pageIndex
{
    //  dispatch_queue_t fetchQ = dispatch_queue_create("data fetcher", NULL);
    if (self.isEnd) {
        return;
    }
    dispatch_queue_t fetchQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    if (self.imageCache == nil) {
        self.imageCache = [[NSCache alloc] init];
    }    
    int count = [[_fetchedResultsController fetchedObjects] count];
    //static dispatch_once_t onceToken;
    for (int rowIndex = 0; rowIndex<self.row; rowIndex++) {
        for(int columnIndex = 0; columnIndex< self.column; columnIndex++){
            int photoIndex = rowIndex*self.column + columnIndex+pageIndex*self.row*self.column;
            if (photoIndex >= [[_fetchedResultsController fetchedObjects] count]) {
                self.isEnd = YES;
                break;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
            PhotoInfo *photoInfo = [_fetchedResultsController objectAtIndexPath:indexPath];
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2+columnIndex*(_imageWidth+1), 2+rowIndex*(_imageHeight+1)+pageIndex*_imageHeight*self.row, _imageWidth, _imageHeight)];
      //      [imageView addGestureRecognizer: self.subImageTap];
            [self.scrollView addSubview:imageView];
            NSLog(@"%f,%f",imageView.frame.origin.x,imageView.frame.origin.y);
            imageView.image = [UIImage imageNamed:@"spinner.gif"];
            dispatch_async(fetchQ, ^{
                NSString *urlString = [NSString stringWithFormat:@"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg",photoInfo.photoId];
                NSLog(@"%@",urlString);
                NSURL *imageURL = [NSURL URLWithString: urlString];          
                /*          NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                 UIImage *image = [UIImage imageWithData:imageData]; 
                 imageView.image = image;
                 [self downloadImageWithURL:imageURL inImageView:imageView];
                 */            
                NSData *imageData = [self.imageCache objectForKey:[NSNumber numberWithInt:photoIndex]];
                if(imageData != nil){
                    UIImage *image = [UIImage imageWithData:imageData]; 
                    imageView.image = image;
                }else{
                    imageData = [NSData dataWithContentsOfURL:imageURL];
                    [self.imageCache setObject:imageData forKey:[NSNumber numberWithInt:photoIndex]]; 
                    UIImage *image = [UIImage imageWithData:imageData];
                    dispatch_queue_t mainQ = dispatch_get_main_queue();
                    dispatch_sync(mainQ, ^{
                        imageView.image = image;
                    });
                    dispatch_release(mainQ);
                }           
            });
        }
        if (self.isEnd) {
            break;
        }
    }
    dispatch_release(fetchQ);
}

@end
