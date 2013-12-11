//
//  ViewController.m
//  GeoGuesser
//
//  Created by Stephen Silber on 12/10/13.
//  Copyright (c) 2013 Stephen Silber. All rights reserved.
//

#import "ViewController.h"
#include <stdlib.h>

@interface ViewController () {
    NSArray *coord_arr;
    GMSPanoramaService *req;
    CLLocationCoordinate2D guess_cord;
    CLLocationCoordinate2D pano_coord;
}

@end

#define boris_random(smallNumber, bigNumber) ((((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (bigNumber - smallNumber)) + smallNumber)

@implementation ViewController

- (void) toggleGuessView:(id) sender {
    CGRect containerFrame = containerView.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

    if (containerFrame.origin.y < 0) containerFrame.origin.y = 64; /* Guess view is hidden -- slide down */
    else containerFrame.origin.y -= containerFrame.size.height;    /* Guess view is down -- slide up */

    [containerView setFrame:containerFrame];
    [UIView commitAnimations];

}

- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [guessView clear];
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
    marker.title = [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude];
    marker.map = guessView;
    makeGuessButton.enabled = YES;
}

- (CLLocationCoordinate2D) getRandomCoord {
    int random_coord = arc4random() % coord_arr.count;
    NSArray *split_coord = [[coord_arr objectAtIndex:random_coord] componentsSeparatedByString:@" "];
    return (CLLocationCoordinate2DMake([[split_coord firstObject] floatValue], [[split_coord lastObject] floatValue]));
}

- (IBAction) checkCoordinateGuess:(id)sender {
    CLLocation *guess_location = [[CLLocation alloc] initWithLatitude:guess_cord.latitude longitude:guess_cord.longitude];
    CLLocation *pano_location = [[CLLocation alloc] initWithLatitude:pano_coord.latitude longitude:pano_coord.longitude];
    CLLocationDistance meters = [guess_location distanceFromLocation:pano_location];
    
    GMSMarker *pano_marker = [GMSMarker markerWithPosition:pano_coord];
    pano_marker.title = @"Actual Location";
    pano_marker.map = guessView;
    
    GMSMutablePath *guess_path = [[GMSMutablePath alloc] init];
    [guess_path addCoordinate:pano_coord];
    [guess_path addCoordinate:guess_cord];
    
    GMSPolyline *guess_line = [GMSPolyline polylineWithPath:guess_path];
    guess_line.map = guessView;
    
    NSLog(@"Guess in kilometers: %f", meters/1000);
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    [guessView setCamera:[GMSCameraPosition cameraWithLatitude:1.285 longitude:103.848 zoom:0]];
    panoView = [[GMSPanoramaView alloc] initWithFrame:panoContainerView.frame];
    [panoView setDelegate:self];
    [guessView setDelegate:self];
    [panoView setStreetNamesHidden:YES];
    [panoContainerView addSubview:panoView];

    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"coords" ofType:@"tsv"];
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    coord_arr = [fileContents componentsSeparatedByString:@"\n"];
    
    req = [[GMSPanoramaService alloc] init];
    [req requestPanoramaNearCoordinate:[self getRandomCoord] radius:9999 callback:^(GMSPanorama *panorama, NSError *error) {
        if(panorama) {
            [panoView setPanorama:panorama];
            pano_coord = panorama.coordinate;
        } else {
            NSLog(@"Coord did not work: %f %f", panorama.coordinate.latitude, panorama.coordinate.longitude);
        }
        if (error) {
            NSLog(@"Error: %@", error);
        }
    }];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleGuessView:)];
    [singleTap setNumberOfTapsRequired:1];
    [self.navigationController.navigationBar addGestureRecognizer:singleTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
