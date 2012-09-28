//
//  EventViewController.m
//  Queer Lisboa
//
//  Created by Bruno Abrantes on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"
#import "FilmViewController.h"
#import "JSONKit.h"
#import "GTMNSString+HTML.h"

@interface EventViewController ()
- (void)loadFilms;
- (void)handleError:(NSError *)error;
- (void)populateFilms;
@end

@implementation EventViewController

@synthesize event=_event;
@synthesize films=_films;
@synthesize activityIndicator=_activityIndicator;
@synthesize connection=_connection;
@synthesize buffer=_buffer;
@synthesize results=_results;
@synthesize filmsLabel;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [NSString stringWithString:[[self.event objectForKey:@"title"] gtm_stringByUnescapingFromHTML]];
    
    [titleLabel setText:self.title];
                  
    // Convert date for display in label
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *localeEN = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    [dateFormatter setLocale:localeEN];
    [dateFormatter setDateFormat:@"EEE MM dd yyyy kk:mm z"];
    
    NSDate *date = [dateFormatter dateFromString:[self.event objectForKey:@"date"]];
    
    NSLocale *localePT = [[[NSLocale alloc] initWithLocaleIdentifier:@"pt_PT"] autorelease];
    [dateFormatter setLocale:localePT];
    
    [dateFormatter setDateFormat:@"EEEE, d MMMM - kk:mm"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
    
    dateLabel.text = strDate;
    dateLabel.adjustsFontSizeToFitWidth = YES;
    
    venueLabel.text = [NSString stringWithFormat:@"%@ - %@", 
                                        [[self.event objectForKey:@"venue"] objectForKey:@"main"],
                                        [[self.event objectForKey:@"venue"] objectForKey:@"sub"]
                       ];
    
    venueLabel.adjustsFontSizeToFitWidth = YES;
    NSString *note = [self.event objectForKey:@"note"];
    
    noteLabel.text = note;

    // Automatically set label height
    CGSize suggestedSize = [note sizeWithFont:noteLabel.font constrainedToSize:CGSizeMake(noteLabel.frame.size.width, FLT_MAX) lineBreakMode:noteLabel.lineBreakMode];
    [noteLabel setFrame:CGRectMake(noteLabel.frame.origin.x, noteLabel.frame.origin.y, noteLabel.frame.size.width, suggestedSize.height)];
    
    
    // Add film subview
    if ([self.event objectForKey:@"related"] != @"" && [self.event objectForKey:@"related"] != NULL) {        
        self.films = [NSMutableString stringWithString:[[self.event objectForKey:@"related"] stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        [self.films replaceOccurrencesOfString:@", ," withString:@"," options:NSCaseInsensitiveSearch range:NSMakeRange(0, self.films.length)];
        
        [self.films replaceOccurrencesOfString:@", " withString:@"," options:NSCaseInsensitiveSearch range:NSMakeRange(0, self.films.length)];
        
        [self loadFilms];
    } else {
        // Remove films label
        [filmsLabel removeFromSuperview];
    }
    
	scrollView.contentSize = CGSizeMake(contentView.frame.size.width, contentView.frame.size.height);
    
	[scrollView flashScrollIndicators];
    
}

- (void)populateFilms 
{   
    for (NSDictionary *result in self.results) {
        FilmViewController *filmView = [[[FilmViewController alloc] initWithFilmAndSuperView:[result objectForKey:@"film"] view:self] retain];
        [filmsView addSubview:filmView.view];
        CGRect window = [self.view frame];
        [filmView.view setFrame:CGRectMake(filmView.view.frame.origin.x, filmView.view.frame.origin.y, window.size.width, filmView.view.frame.size.height)];
    }
    
    [self resizeFilmsView];
    [self resizeScrollView];
}

- (void)loadFilms {
    
    [self.activityIndicator startAnimating];
    
    NSString *path = [NSString stringWithFormat:@"http://queerlisboa.pt/api/films/json/get/%@", self.films];
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease]; 
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)resizeFilmsView {

    CGFloat viewHeight = 0.0f;
    CGFloat previousViewOriginY = 0.0f;
    for (UIView* view in filmsView.subviews) {
        if (!view.hidden) {
            CGFloat y = view.frame.origin.y;
            CGFloat h = view.frame.size.height;
            
            if (y + h > viewHeight) {
                viewHeight = h + y;
            }
            
            CGRect viewFrame = view.frame;
            viewFrame.origin.y = previousViewOriginY;
            view.frame = viewFrame;
            previousViewOriginY += view.frame.size.height;
        }
    }
    
    [filmsView setFrame:CGRectMake(filmsView.frame.origin.x, filmsView.frame.origin.y, filmsView.frame.size.width, viewHeight)];
}

- (void)resizeScrollView {
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;

    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in contentView.subviews)
    {
        if (!view.hidden)
        {
            CGFloat y = view.frame.origin.y;
            CGFloat h = view.frame.size.height;
            
            if (y + h > scrollViewHeight)
            {
                scrollViewHeight = h + y;
            }
        }
    }
    
    [scrollView setContentSize:(CGSizeMake(320, scrollViewHeight))];
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.showsVerticalScrollIndicator = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    self.buffer = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.connection = nil;
    
    NSString *jsonString = [[NSString alloc] initWithData:self.buffer encoding:NSUTF8StringEncoding];
    NSDictionary *jsonResults = [jsonString objectFromJSONString];
    self.results = [jsonResults objectForKey:@"films"];
    
    [jsonString release];
    self.buffer = nil;
    
    [self populateFilms];
    
    [self.activityIndicator stopAnimating];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.connection = nil;
    self.buffer = nil;
    
    [self handleError:error];
}

- (void) handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [dateLabel release];
    [venueLabel release];
    [noteLabel release];
    [self.films release];
    
    for (UIView *view in filmsView.subviews) {
        [view release];
    }
    
    [filmsView release];
}

#pragma mark - Specific view controller methods

- (id)initWithEvent:(NSDictionary *)theEvent
{
    self.event = theEvent;
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
