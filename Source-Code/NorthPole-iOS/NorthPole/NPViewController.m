//
//  NPViewController.m
//  NorthPole
//
//  Created by Hector Zarate on 11/30/13.
//  Copyright (c) 2013 Hector Zarate. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "NPViewController.h"
#import <PebbleKit/PebbleKit.h>


static const CLLocationDistance NPDefaultDistanceFilter         = 0.0;  // [m]
static const NSTimeInterval NPDefaultRecentTimeInterval         = 15.0; // [s]

@interface NPViewController () <CLLocationManagerDelegate, PBPebbleCentralDelegate>

@property (nonatomic, strong) IBOutlet UILabel *altitudeLabel;

@property (nonatomic, strong) PBWatch* pebbleWatch;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation NPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupPebble];
    [self setupCoreLocation];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.pebbleWatch closeSession:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupPebble
{
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"226834ae-786e-4302-a52f-6e7efc9f990c"];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    self.pebbleWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    [PBPebbleCentral defaultCentral].delegate = self;
    
    [self.pebbleWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
        if (!error) {
            NSLog(@"Successfully launched app.");
        }
        else {
            NSLog(@"Error launching app - Error: %@", error);
        }
    }
     ];
    

    
}



- (void)setupCoreLocation
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    self.locationManager = locationManager;
    
    [self.locationManager startUpdatingLocation];
}

- (void) setupPebbleWatch: (PBWatch *)paramPebbleWatch
{

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
        NSString *altitudeString = [NSString stringWithFormat:@"%0.0f m", lastLocation.altitude];
        
        self.altitudeLabel.text = altitudeString;
        
        NSDictionary *update = @{@(0):altitudeString };
        
        [self.pebbleWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            if (!error) {
                NSLog(@"Successfully sent message.");
            }
            else {
                NSLog(@"Error sending message: %@", error);
            }
        }];

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


#pragma mark - Pebble WatchDelegate

- (void)pebbleCentral:(PBPebbleCentral*)central
      watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew
{
    NSLog(@"Connected Watch!");
    
    self.pebbleWatch = watch;
}


- (void)pebbleCentral:(PBPebbleCentral*)central
   watchDidDisconnect:(PBWatch*)watch
{
    
    if (self.pebbleWatch == watch ||
        [watch isEqual:self.pebbleWatch])
    {
        self.pebbleWatch = nil;
    }
}


@end
