//
//  FilmViewController.h
//  Queer Lisboa
//
//  Created by Bruno Abrantes on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "EventViewController.h"

@interface FilmViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *synopsis;
    IBOutlet AsyncImageView *image;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIWebView *videoView;
    IBOutlet UIView *synopsisTitle;
    IBOutlet UIView *trailerTitle;
    EventViewController *theSuperView;
}

-(id)initWithFilmAndSuperView:(NSDictionary *)theFilm view:(UIViewController *)aSuperView;

@property (retain, nonatomic) NSDictionary *film;
@property (retain, nonatomic) AsyncImageView *image;
@property (retain, nonatomic) UILabel *titleLabel;
@property (nonatomic, retain) UIViewController *theSuperView;

@end
