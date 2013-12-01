//
//  NPFunctions.h
//  NorthPole
//
//  Created by Hector Zarate on 12/1/13.
//  Copyright (c) 2013 Hector Zarate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#ifndef NorthPole_NPFunctions_h
#define NorthPole_NPFunctions_h


NSString* NPAbbreviationForDirection(CLLocationDirection paramDirection)
{
    // TODO: handle values larget than 360º
    
    static NSArray *allAbbreviations = nil;
    
    if (!allAbbreviations)
    {
        allAbbreviations = @[@"N", @"NW", @"W", @"SW", @"S", @"SE", @"E", @"NE"];
    }
    
    CGFloat widthForPointInDegrees = 360.0 / allAbbreviations.count;
    
    paramDirection = paramDirection + (360 + (widthForPointInDegrees / 2.0));
    
    paramDirection = (NSUInteger) paramDirection % 360;
    
    NSUInteger position = paramDirection / widthForPointInDegrees;
    
    return allAbbreviations[position];
}




#endif
