//
//  FilmViewController.m
//  Queer Lisboa
//
//  Created by Bruno Abrantes on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilmViewController.h"
#import "AsyncImageView.h"
#import "GTMNSString+HTML.h"
#import "EventViewController.h"

@implementation FilmViewController

@synthesize film=_film, image, titleLabel, theSuperView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) resizeView {
    
    CGFloat viewHeight = 0.0f;
    for (UIView* view in self.view.subviews)
    {
        if (!view.hidden)
        {
            CGFloat y = view.frame.origin.y;
            CGFloat h = view.frame.size.height;
            
            if (y + h > viewHeight)
            {
                viewHeight = h + y;
            }
        }
    }
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, viewHeight)];
}

- (void)embedYouTube:(NSString*)url {    
    NSRange range = [url rangeOfString:@"v="];
    url = [url substringFromIndex:range.location + 2];
    
    url = [NSString stringWithFormat:@"http://www.youtube.com/embed/%@", url];
    NSError *error;
    NSString* template = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"video" ofType:@"html"] encoding:NSUTF8StringEncoding error:&error];
    NSString* html = [NSString stringWithFormat:template, videoView.frame.size.width, videoView.frame.size.height, url];
    [videoView loadHTMLString:html baseURL:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *title = [NSString stringWithString:[[self.film objectForKey:@"title"] gtm_stringByUnescapingFromHTML]];
    [titleLabel setText:title];
    
    NSError *error;
    NSString *synopsisTemplate = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"synopsis" ofType:@"html"] encoding:NSUTF8StringEncoding error:&error];
    NSString *html = [NSString stringWithFormat:synopsisTemplate, [self.film objectForKey:@"description"]];
    [synopsis loadHTMLString:html baseURL:nil];
    
    NSString *trailer = [self.film objectForKey:@"trailer"];
    
    if (trailer != NULL) {        
        CGRect videoFrame = videoView.frame;
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        videoFrame.size.width = screenBounds.size.width - 40.0f;
        videoFrame.size.height = (videoFrame.size.width * 9) / 16;

        float heightDiff = videoFrame.size.height - videoView.frame.size.height;

        [videoView setFrame:videoFrame];

        CGRect imageFrame = image.frame;
        imageFrame.origin.y += heightDiff;
        [image setFrame:imageFrame];

        CGRect synopsisHeadingFrame = synopsisTitle.frame;
        synopsisHeadingFrame.origin.y += heightDiff;
        [synopsisTitle setFrame:synopsisHeadingFrame];
        
        CGRect synopsisFrame = synopsis.frame;
        synopsisFrame.origin.y += heightDiff;
        [synopsis setFrame:synopsisFrame];
    
        [self embedYouTube:trailer];
    } else {
        // Load an image instead
        [image addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        
        NSURL *url = [[[NSURL alloc] initWithString:[self.film objectForKey:@"poster_original"]] autorelease];
        image.imageURL = url;
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]) {        
        CGSize boundsSize = self.view.bounds.size;
        CGRect frameToCenter = image.frame;
        
        // center horizontally
        if (frameToCenter.size.width < boundsSize.width)
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        else
            frameToCenter.origin.x = 0;
        
        [image setFrame:frameToCenter];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    webView.scalesPageToFit = YES;
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    frame.size = CGSizeMake(frame.size.width, [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue]+ 30.0f);
    webView.frame = frame;
    
    [self resizeView];
    [theSuperView resizeFilmsView];
    [theSuperView resizeScrollView];
}

#pragma mark - View specific methods

-(id)initWithFilmAndSuperView:(NSDictionary *)theFilm view:(EventViewController *)aSuperView
{
    self.film = theFilm;
    
    theSuperView = aSuperView;
    
    NSString *nibName = @"";
    
    if ([self.film objectForKey:@"trailer"] == NULL) {
        nibName = @"FilmViewControllerWithoutTrailer";
    } else {
        nibName = @"FilmViewController";
    }
    
    self = [self initWithNibName:nibName bundle:nil];
    
    return self;
}

- (void) dealloc
{
    synopsis.delegate = nil;
    synopsis = nil;
    videoView.delegate = nil;
    videoView = nil;
    [super dealloc];
}

@end
