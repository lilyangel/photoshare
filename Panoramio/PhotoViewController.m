//
//  PhotoViewController.m
//  Panoramio
//
//  Created by lily on 1/13/13.
//
//

#import "PhotoViewController.h"
#import "PlanetViewAppDelegate.h"
#import "PhotoInfo.h"
#import "FetchPhotoResult.h"
#import "PopoverViewController.h"
#import "social/Social.h"
#import "accounts/Accounts.h"

@interface PhotoViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *shareButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UITapGestureRecognizer *imageTap;
@property (strong, nonatomic) UIButton *customButton;

//@property (strong, nonatomic) PopoverViewController *popoverVC;
//@property (nonatomic) NSString *photoId;
@end

@implementation PhotoViewController
@synthesize photoId = _photoId;
@synthesize imageView;
@synthesize imageTap;
@synthesize isFavorite;
@synthesize customButton;

//why add the following function will throw the exc_bad_access exception???
/*- (void)setPhotoId: (int) photoId
 {
 self.photoId = photoId;
 }*/
- (void)addFavorite
{
    PlanetViewAppDelegate *pvDelegate = (((PlanetViewAppDelegate*) [UIApplication sharedApplication].delegate));
    NSError *error;
    FetchPhotoResult *fetchPhoto = [[FetchPhotoResult alloc] init];
    fetchPhoto.photoId = self.photoId;
    NSFetchedResultsController *fetchedResultsController = [fetchPhoto fetchedResultsController];
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    PhotoInfo *photoInfo = [fetchedResultsController objectAtIndexPath:indexPath];
    UIImage *favoriteImage;
//    UIButton *someButton = self.navigationItem.rightBarButtonItem.customView;
    UIButton *someButton = [[self.navigationItem.rightBarButtonItems objectAtIndex:1] customView];
    if (isFavorite) {
        photoInfo.isFavorite = [NSNumber numberWithInt:0];
        favoriteImage = [UIImage imageNamed:@"greyheartSmall.png"];
        self.isFavorite = NO;
    }else{
        photoInfo.isFavorite = [NSNumber numberWithInt:1];
        favoriteImage = [UIImage imageNamed:@"redheartSmall.png"];
        self.isFavorite = YES;
    }
    [someButton setBackgroundImage:favoriteImage forState:UIControlStateNormal];
    [customButton setBackgroundImage:favoriteImage forState:UIControlStateNormal];
    if (![pvDelegate.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}

//-(void)

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
 //   [self.navigationController setNavigationBarHidden:NO animated:YES];
	// Do any additional setup after loading the view.
    self.imageView.backgroundColor = [UIColor blackColor];
    NSString *urlString = [NSString stringWithFormat:@"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg", self.photoId];
    NSURL *imageURL = [NSURL URLWithString: urlString];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    imageView.image = image;
    self.imageTap = [[UITapGestureRecognizer alloc]
                     initWithTarget:self action:@selector(handlePhotoTap:)];
    [self.imageView addGestureRecognizer:imageTap];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *favoriteImage;
    if (self.isFavorite) {
        favoriteImage = [UIImage imageNamed:@"redheartSmall.png"];
    }else{
        favoriteImage = [UIImage imageNamed:@"greyheartSmall.png"];
    }
    //    UIImage* image3 = [UIImage imageNamed:@"redheartSmall.png"];
    CGRect frameimg = CGRectMake(0, 0, favoriteImage.size.width, favoriteImage.size.height);
    UIButton *addFavButton = [[UIButton alloc] initWithFrame:frameimg];
    [addFavButton setBackgroundImage:favoriteImage forState:UIControlStateNormal];
    [addFavButton addTarget:self action:@selector(addFavorite)
         forControlEvents:UIControlEventTouchUpInside];
    [addFavButton setShowsTouchWhenHighlighted:YES];
    
    UIImage *sharedImage = [UIImage imageNamed:@"shared.png"];
    UIButton *shareButton = [[UIButton alloc] initWithFrame:frameimg];
    shareButton.titleLabel.text = @"share";
    [shareButton setBackgroundImage:sharedImage forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(tapSharedButton) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *favButton =[[UIBarButtonItem alloc] initWithCustomView:addFavButton];
    UIBarButtonItem *shareItem =[[UIBarButtonItem alloc] initWithCustomView:shareButton];

    NSArray *barButtonItems = [NSArray arrayWithObjects:shareItem,favButton, nil];
    
//    self.navigationItem.rightBarButtonItem=mailbutton;
    self.navigationItem.rightBarButtonItems = barButtonItems;

}

-(void) viewWillDisappear:(BOOL)animated
{
  //  [[self navigationController] popToViewController:obj animated:YES];

    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        NSLog(@"test");
    }
}

-(void) tapSharedButton
{
 //   PopoverViewController* content = [[PopoverViewController alloc] init];
//    UIPopoverController* aPopover = [[UIPopoverController alloc]
//                                     initWithContentViewController:content];
//    aPopover.delegate = self;
    
    // Store the popover in a custom property for later use.
//    self.popoverVC = aPopover;
    
 //   [self.popoverVC present presentPopoverFromBarButtonItem:sender
   //                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    // open a dialog with just an OK button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Facebook", @"Twitter", @"Weibo", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *serviceType;
    
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        // all done
    } else if (buttonIndex == 0) {
        NSLog(@"facebook");
        serviceType = SLServiceTypeFacebook;
    } else if (buttonIndex == 1) {
        NSLog(@"Twitter");
        serviceType = SLServiceTypeTwitter;
    } else if (buttonIndex == 2) {
        NSLog(@"weibo");
        serviceType = SLServiceTypeSinaWeibo;
    }

    
    
    if([SLComposeViewController isAvailableForServiceType:serviceType]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                
                NSLog(@"Cancelled");
                
            } else
                
            {
                NSLog(@"Done");
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler =myBlock;
        
        //Adding the Text to the facebook post value from iOS
        [controller setInitialText:@"Hi, i would like to share with you about this nice photo"];
        
        //Adding the URL to the facebook post value from iOS
        [controller addURL:[NSURL URLWithString:@"http://www.panoramio.com"]];
        
        //Adding the Image to the facebook post value from iOS
        NSString *urlString = [NSString stringWithFormat:@"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg", self.photoId];
        NSURL *imageURL = [NSURL URLWithString:urlString];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        [controller addImage:[UIImage imageWithData:imageData] ];
        
        
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        NSLog(@"UnAvailable");
    }

    
    
    
}

-(void)displayComposerSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Hello from California!"];
	
    
	// Set up recipients
/*	NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
	NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
	NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
	
	[picker setToRecipients:toRecipients];
	[picker setCcRecipients:ccRecipients];
	[picker setBccRecipients:bccRecipients];
 */
	//[picker ]
	// Attach an image to the email
    NSString *urlString = [NSString stringWithFormat:@"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg", self.photoId];
    NSURL *imageURL = [NSURL URLWithString:urlString];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
	[picker addAttachmentData:imageData mimeType:@"image/png" fileName:urlString];
	
	// Fill out the email body text
	NSString *emailBody = @"";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
//	message.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Result: canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Result: saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Result: sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Result: failed");
			break;
		default:
			NSLog(@"Result: not sent");
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


//set enable user interaction in storyboard;
-(void)handlePhotoTap: (UIGestureRecognizer*) gesture
{
    if (self.navigationController.navigationBarHidden == YES) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];

    }else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setShareButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//need to set Layout for Tab bar viewControllor in storyboard
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
