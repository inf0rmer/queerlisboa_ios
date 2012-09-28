//
//  EventsListViewController.m
//  Queer Lisboa
//
//  Created by Bruno Abrantes on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventsListViewController.h"
#import "EventViewController.h"
#import "JSONKit.h"
#import "helpers.h"
#import "GTMNSString+HTML.h"

@interface EventsListViewController ()
- (void)loadQuery;
- (void)handleError:(NSError *)error;
- (NSMutableDictionary *)indexKeyedDictionaryFromArray:(NSArray *)array;
@end

@implementation EventsListViewController

@synthesize date=_date;
@synthesize connection=_connection;
@synthesize buffer=_buffer;
@synthesize results=_results;
@synthesize activityIndicator=_activityIndicator;
@synthesize sorted;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0xE76588);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  	indicator.hidesWhenStopped = YES;
  	[indicator stopAnimating];
  	self.activityIndicator = indicator;
  	[indicator release];
    
  	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:indicator];
  	self.navigationItem.rightBarButtonItem = rightButton;
  	[rightButton release];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadQuery];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSMutableArray *hours = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.sorted count]; i++) {
        NSString *object = [[[self.sorted objectAtIndex:i] objectForKey:@"node"] objectForKey:@"hour"];
        if ([hours indexOfObject:object] == NSNotFound) {
            [hours addObject:object];
        }
    }
    
    int count = [hours count];
    [hours release];
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSMutableArray *hours = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.sorted count]; i++) {
        NSString *object = [[[self.sorted objectAtIndex:i] objectForKey:@"node"] objectForKey:@"hour"];
        if ([hours indexOfObject:object] == NSNotFound) {
            [hours addObject:object];
        }
    }
    
    NSMutableArray *nonUniqueHours = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.sorted count]; i++) {
        NSString *object = [[[self.sorted objectAtIndex:i] objectForKey:@"node"] objectForKey:@"hour"];
        [nonUniqueHours addObject:object];
    }
    
    NSString *hour = [hours objectAtIndex:section];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", hour];
    
    NSArray *hoursArray = [nonUniqueHours filteredArrayUsingPredicate:pred];
    
    [hours release];
    [nonUniqueHours release];
    
    return [hoursArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSMutableArray *hours = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.sorted count]; i++) {
        NSString *object = [[[self.sorted objectAtIndex:i] objectForKey:@"node"] objectForKey:@"hour"];
        if ([hours indexOfObject:object] == NSNotFound) {
            [hours addObject:object];
        }
    }
    
    NSString *hour = [hours objectAtIndex:section];
    
    NSString *name = [NSString stringWithFormat:@"%@", hour];
    
    [hours release];
    return name;
}

/*
- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    iDeck *deck = [fetchedResultsController objectAtIndexPath: indexPath];
    if (deck == self.selectedDeck) {
        return nil;
    } else {
        return indexPath;
    }
}
*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    int index = 0;
    for(int i=0; i<indexPath.section; ++i) {
        index += [tableView numberOfRowsInSection:i];
    }
    index += indexPath.row;
    
    
    NSString *title = [NSString stringWithString:[[[[self.sorted objectAtIndex:index] objectForKey:@"node" ] objectForKey:@"title"] gtm_stringByUnescapingFromHTML]];
    cell.textLabel.text = title;
    
    NSString *type = [[[self.sorted objectAtIndex:index] objectForKey:@"node" ] objectForKey:@"type"];
    type = [type lowercaseString];
    type = [type stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"ql-icon-20-%@", type] ofType:@"png"];
    NSString *pathWhite = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"ql-icon-20-%@-white", type] ofType:@"png"];
    UIImage *typeImage = [UIImage imageWithContentsOfFile:path];
    UIImage *typeImageWhite = [UIImage imageWithContentsOfFile:pathWhite];
    
    cell.imageView.image = typeImage;
    
    cell.imageView.highlightedImage = typeImageWhite;
    
    cell.textLabel.textColor = UIColorFromRGB(0x333333);
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:UIColorFromRGB(0xE76588)];
    [cell setSelectedBackgroundView:bgColorView];
    [bgColorView release];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = 0;
    for(int i=0; i<indexPath.section; ++i) {
        index += [tableView numberOfRowsInSection:i];
    }
    index += indexPath.row;
    
    // Navigation logic may go here. Create and push another view controller.
    EventViewController *eventViewController = [[EventViewController alloc] initWithEvent:[[self.sorted objectAtIndex:index] objectForKey:@"node"]];
    
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:eventViewController animated:YES];
    [eventViewController release];
}

#pragma mark - Specific view methods

- (id)initWithDate:(NSDate *)theDate {
    self.date = theDate;
    
    // Convert date for display in title
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"d MMM."];
    NSString *strDate = [dateFormatter stringFromDate:theDate];
    
    self.title = strDate;
    
    self = [super init];
    
  	return self;
}

- (void)loadQuery {
    
    [self.activityIndicator startAnimating];
    
    // Convert date for use in URL
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *urlDate = [dateFormatter stringFromDate:self.date];
    
    NSString *path = [NSString stringWithFormat:@"http://queerlisboa.pt/api/programme/json/get/%@urlDate", urlDate];
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease]; 
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
    self.results = [jsonResults objectForKey:@"nodes"];
    
    self.sorted = [self.results sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                       {
                           NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                           [formatter setDateFormat:@"EEE MM dd yyyy hh:mm"];
                           NSDate *first = [formatter dateFromString:[(NSDictionary*)[(NSDictionary*)a objectForKey:@"node"] objectForKey:@"date"]];
                           NSDate *second = [formatter dateFromString:[(NSDictionary*)[(NSDictionary*)b objectForKey:@"node"] objectForKey:@"date"]];
                           
                           [formatter release];
                           return [first compare:second];
                       }];
    
    [jsonString release];
    self.buffer = nil;
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
    
    [self.activityIndicator stopAnimating];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.connection = nil;
    self.buffer = nil;
    
    [self handleError:error];
    [self.tableView reloadData];
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

#pragma mark - Helper functions

- (NSDictionary *) indexKeyedDictionaryFromArray:(NSArray *)array 
{
    id objectInstance;
    NSUInteger indexKey = 0;
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (objectInstance in array) {
        [mutableDictionary setObject:objectInstance forKey:[NSNumber numberWithUnsignedInt:indexKey]];
        indexKey++;
    }
    
    return (NSDictionary *)[mutableDictionary autorelease];
}

#pragma mark - dealloc

- (void) dealloc {
    [self.connection cancel];
    [_connection release];
    [_buffer release];
    [_results release];
    [_date release];
    [super dealloc];
}

@end
