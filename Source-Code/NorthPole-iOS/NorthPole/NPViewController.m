//
//  NPViewController.m
//  NorthPole
//
//  Created by Hector Zarate on 11/30/13.
//  Copyright (c) 2013 Hector Zarate. All rights reserved.
//


#import "NPViewController.h"
#import <PebbleKit/PebbleKit.h>
#import "NPFunctions.h"
#import <CoreLocation/CoreLocation.h>

#pragma mark - Local Constants


static const NSUInteger NPDictionaryCompassAltimeterValueKey = 0x0;
static const NSUInteger NPDictionaryCompassCompassAbbreviationKey = 0x1;
static const NSUInteger NPDictionaryCompassCompassDirectionValueKey = 0x2;


static const CLLocationDistance NPDefaultDistanceFilter         = 0.0;  // [m]
static const NSTimeInterval NPDefaultRecentTimeInterval         = 15.0; // [s]


#pragma mark -

@interface NPViewController () <CLLocationManagerDelegate, PBPebbleCentralDelegate>

@property (nonatomic, strong) IBOutlet UILabel *altitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *directionLabel;

@property (nonatomic, strong) NSMutableDictionary *transmissionDictionary;

@property (nonatomic, strong) PBWatch* pebbleWatch;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation NPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupTransmissionDictionary];
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

- (void)setupTransmissionDictionary
{
    self.transmissionDictionary = [@{@(NPDictionaryCompassAltimeterValueKey): @"2500 m",
                                    @(NPDictionaryCompassCompassDirectionValueKey): @"SW",
                                    @(NPDictionaryCompassCompassAbbreviationKey): @"250º"
                                    } mutableCopy];
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
    locationManager.headingFilter = 4.5;
    self.locationManager = locationManager;
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
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
        
        [self.transmissionDictionary setObject:altitudeString
                                        forKey:@(NPDictionaryCompassAltimeterValueKey)];
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


- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    CLLocationDirection magneticHeadingDirection = newHeading.magneticHeading;

    NSString *magneticDirectionValueString = [NSString stringWithFormat:@"%0.1f", magneticHeadingDirection]; // º
    NSString *magneticAbbreviationString = NPAbbreviationForDirection(magneticHeadingDirection);
    
    NSDate *timestampForMeasurement  = newHeading.timestamp;
    NSTimeInterval howRecentMeasurementIs = [timestampForMeasurement timeIntervalSinceNow];
    
    if (abs(howRecentMeasurementIs) < NPDefaultRecentTimeInterval)
    {
        [self.transmissionDictionary setObject:magneticDirectionValueString
                                        forKey:@(NPDictionaryCompassCompassDirectionValueKey)];
        
        [self.transmissionDictionary setObject:magneticAbbreviationString
                                        forKey:@(NPDictionaryCompassCompassAbbreviationKey)];
        
        self.directionLabel.text = [NSString stringWithFormat:@"%@, %@", magneticAbbreviationString, magneticDirectionValueString];
        
        [self.pebbleWatch appMessagesPushUpdate:self.transmissionDictionary
                                         onSent:
         ^(PBWatch *watch, NSDictionary *update, NSError *error)
        {
            if (error)
            {
                NSLog(@"Error sending message: %@", error);
            }
            else {
                NSLog(@"Successfully sent message.");
            }
        }];
    }
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
