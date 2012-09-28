//
//  EventsListViewController.h
//  Queer Lisboa
//
//  Created by Bruno Abrantes on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsListViewController : UITableViewController

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *buffer;
@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSArray *sorted;
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;

- (id)initWithDate:(NSDate *)theDate;

@end
