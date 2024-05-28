//
//  AniPhotoUnitTests.m
//  AniPhotoUnitTests
//
//  Created by LAP14667 on 30/5/24.
//

#import <XCTest/XCTest.h>
#import "EPSDefines.h"

@interface AniPhotoUnitTests : XCTestCase

@end

@implementation AniPhotoUnitTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testFetchUserCredit {
    NSString *urlString = [NSString stringWithFormat:@"%@/quotas/total", kServerEndPointURL];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionConfiguration *sessionConfiguration = [EPSRequestBuilder defaultSessionConfiguration];

    [EPSRequestBuilder dataTaskForURL:url
                 sessionConfiguration:sessionConfiguration
                          requestType:EPSHTTPRequestTypeGet
                             bodyData:nil
                           completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        if (IS_NONEMPTY_DICT(response)) {
        } else {
            NSLog(@"PhatCH Error Fetching User Credit");
        }
    }];
}

- (void)testFetchUserInfo {
    NSString *urlString = [NSString stringWithFormat:@"%@/user/", kServerEndPointURL];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionConfiguration *sessionConfiguration = [EPSRequestBuilder defaultSessionConfiguration];

    [EPSRequestBuilder dataTaskForURL:url
                 sessionConfiguration:sessionConfiguration
                          requestType:EPSHTTPRequestTypeGet
                             bodyData:nil
                           completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        if (IS_NONEMPTY_DICT(response)) {

        } else {
        }
    }];
}

- (void)testFetchUserSubscription {
    NSString *urlString = [NSString stringWithFormat:@"%@/subscriptions/active-subscription", kServerEndPointURL];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionConfiguration *sessionConfiguration = [EPSRequestBuilder defaultSessionConfiguration];

    [EPSRequestBuilder dataTaskForURL:url
                 sessionConfiguration:sessionConfiguration
                          requestType:EPSHTTPRequestTypeGet
                             bodyData:nil
                           completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {

        if (IS_NONEMPTY_DICT(response)) {
            
        }  else {
            
        }
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
