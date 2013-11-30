//
//  NPViewController.m
//  NorthPole
//
//  Created by Hector Zarate on 11/30/13.
//  Copyright (c) 2013 Hector Zarate. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "NPViewController.h"

static const CLLocationDistance NPDefaultDistanceFilter         = 0.0;  // [m]
static const NSTimeInterval NPDefaultRecentTimeInterval         = 15.0; // [s]

@interface NPViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *altitudeLabel;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation NPViewController

- (void)viewDidLoad
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    // TODO: Consider and ponder Significant-Change Location Service
    [locationManager startUpdatingLocation];
    
    self.locationManager = locationManager  ;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LocationManagerDelegate


-(void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(NSArray *)locations
{
    CLLocation* lastLocation = [locations lastObject];
    NSDate *timestampForLastLocation  = lastLocation.timestamp;
    
    NSTimeInterval howRecentLocationIs = [timestampForLastLocation timeIntervalSinceNow];
    
    if (abs(howRecentLocationIs) < NPDefaultRecentTimeInterval)
    {
        self.altitudeLabel.text = [NSString stringWithFormat:@"%0.3f m", lastLocation.altitude];
    }
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"There was an error while retrieving location"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}


@end
