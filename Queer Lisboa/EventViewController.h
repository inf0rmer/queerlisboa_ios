//
//  EventViewController.h
//  Queer Lisboa
//
//  Created by Bruno Abrantes on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventViewController : UIViewController {
    IBOutlet UIScrollView* scrollView;
    IBOutlet UILabel *dateLabel;
    IBOutlet UILabel *venueLabel;
    IBOutlet UILabel *noteLabel;
    IBOutlet UIView  *filmsView;
    IBOutlet UIView *contentView;
    IBOutlet UILabel *titleLabel;
}

@property (retain, nonatomic) NSDictionary *event;
- (id)initWithEvent:(NSDictionary *)theEvent;

-(void)resizeFilmsView;
-(void)resizeScrollView;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *buffer;
@property (nonatomic, retain) NSMutableArray *results;
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) NSMutableString *films;
@property (retain, nonatomic) IBOutlet UIView *filmsLabel;

@end
