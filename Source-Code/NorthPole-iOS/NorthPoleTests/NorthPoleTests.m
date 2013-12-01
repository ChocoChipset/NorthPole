//
//  NorthPoleTests.m
//  NorthPoleTests
//
//  Created by Hector Zarate on 11/30/13.
//  Copyright (c) 2013 Hector Zarate. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NPFunctions.h"

@interface NorthPoleTests : XCTestCase

@end

@implementation NorthPoleTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAbbreviation
{
    NSString *abbreviation;
    
    abbreviation = NPAbbreviationForDirection(0);
    XCTAssertEqualObjects(abbreviation, @"N", @"Failed to abbreviate degrees (N)");

    abbreviation = NPAbbreviationForDirection(45);
    XCTAssertEqualObjects(abbreviation, @"NW", @"Failed to abbreviate degrees (W)");
    
    abbreviation = NPAbbreviationForDirection(90);
    XCTAssertEqualObjects(abbreviation, @"W", @"Failed to abbreviate degrees (W)");
    
    abbreviation = NPAbbreviationForDirection(180);
    XCTAssertEqualObjects(abbreviation, @"S", @"Failed to abbreviate degrees (S)");
    
    abbreviation = NPAbbreviationForDirection(270);
    XCTAssertEqualObjects(abbreviation, @"E", @"Failed to abbreviate degrees (E)");
    
}


@end
