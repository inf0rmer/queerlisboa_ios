//
//  RootViewController.m
//  Queer Lisboa
//
//  Created by Bruno Abrantes on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "EventsListViewController.h"
#import "JSONKit.h"
#import "helpers.h"

@interface RootViewController ()
- (void)loadQuery;
- (void)handleError:(NSError *)error;;
@end
    

@implementation RootViewController

@synthesize connection=_connection;
@synthesize buffer=_buffer;
@synthesize results=_results;
@synthesize activityIndicator=_activityIndicator;


# pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Queer Lisboa";
    
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0xE76588);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  	indicator.hidesWhenStopped = YES;
  	[indicator stopAnimating];
  	self.activityIndicator = indicator;
  	[indicator release];
    
  	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:indicator];
  	self.navigationItem.rightBarButtonItem = rightButton;
  	[rightButton release];
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

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell.
    
    // Prettify the date for display in the cell
   
    NSString *dateStr = [[[self.results objectAtIndex:indexPath.row] objectForKey:@"date" ] objectForKey:@"value"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy/MM/dd"];
	NSDate *date = [dateFormat dateFromString:dateStr];
    
    // Convert date for display in title
    [dateFormat setDateFormat:@"d MMMM, YYYY"];
    NSString *prettyDate = [dateFormat stringFromDate:date];
    [dateFormat release];
    
    cell.textLabel.text = prettyDate;
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
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *theDate = [self.results objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy/MM/dd"];
	NSDate *date = [dateFormat dateFromString:[[theDate objectForKey:@"date"] objectForKey:@"value"]];
    
    [dateFormat release];
    
    EventsListViewController *nextController = [[EventsListViewController alloc] initWithDate:date];
    [self.navigationController pushViewController:nextController animated:YES];
    [nextController release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

# pragma mark Specific view methods

- (void)loadQuery {
    
    [self.activityIndicator startAnimating];
    
    NSString *path = [NSString stringWithFormat:@"http://queerlisboa.pt/api/dates/json/get"];
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
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
    self.results = [jsonResults objectForKey:@"dates"];
    
    [jsonString release];
    self.buffer = nil;
    [self.tableView setDataSource:self];
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

- (void)dealloc
{
    [self.connection cancel];
    [_connection release];
    [_buffer release];
    [_results release];
    [super dealloc];
}

@end
