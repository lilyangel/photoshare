//
//  ThumbNailSuperViewController.h
//  Panoramio
//
//  Created by lily on 2/9/13.
//
//

#import <UIKit/UIKit.h>
#import "FetchPhotoResult.h"

@interface ThumbNailSuperViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate, UITabBarControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) NSCache *imageCache;
@property NSInteger const row;
@property NSInteger const column;
@property float imageWidth;
@property float imageHight;
@property NSInteger currentListPage;
@property (nonatomic, strong) UITapGestureRecognizer *subImageTap;
@property NSInteger currentPhotoIndex;
@property Boolean isEnd;
@property NSString *photoId;
@property float scrollBeginOffset;

//global varible to pre-store all photoes.
@property (nonatomic) NSMutableDictionary *imageSet;
@property (nonatomic) NSMutableData *receivedData;
@property (nonatomic) NSURLConnection *connection;

- (void)fetchPhotoData;
- (void) handleTap:(UIGestureRecognizer*) gesture;
- (void)printPhotoWithPageIndex:(int)pageIndex;
- (void)downloadOneFramePhoto:(int)frameSize;
@end
