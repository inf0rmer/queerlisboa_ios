//
//  RootViewController.h
//  Queer Lisboa
//
//  Created by Bruno Abrantes on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *buffer;
@property (nonatomic, retain) NSMutableArray *results;
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;

@end
