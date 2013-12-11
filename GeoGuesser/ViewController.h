//
//  ViewController.h
//  GeoGuesser
//
//  Created by Stephen Silber on 12/10/13.
//  Copyright (c) 2013 Stephen Silber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController : UIViewController <GMSPanoramaViewDelegate, GMSMapViewDelegate> {
    IBOutlet UIView *panoContainerView;
    IBOutlet GMSPanoramaView *panoView;
    IBOutlet UIView *containerView;
    IBOutlet GMSMapView *guessView;
    IBOutlet UILabel *detailTextLabel;
    IBOutlet UIButton *makeGuessButton;
}

@end
