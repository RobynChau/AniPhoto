//
//  EPSRequestBuilder.m
//  AniPhoto
//
//  Created by PhatCH on 25/5/24.
//

#import "EPSRequestBuilder.h"
#import "EPSUserSessionManager.h"
#import "EPSDefines.h"

@implementation EPSRequestBuilder

+ (NSURLSessionConfiguration *)defaultSessionConfiguration {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSMutableDictionary *additionalHeaders = [NSMutableDictionary dictionary];

    // Device ID
    [additionalHeaders addEntriesFromDictionary:@{
        @"Device-Id" : EPSUserSessionManager.shared.deviceID,
    }];

    // Access Token
    if (EPSUserSessionManager.shared.userSession.isSignedIn) {
        NSString *authHeader = [@"Bearer " stringByAppendingString:EPSUserSessionManager.shared.userSession.accessToken];
        [additionalHeaders addEntriesFromDictionary:@{
            @"Authorization": authHeader
        }];
    }

    sessionConfiguration.HTTPAdditionalHeaders = [additionalHeaders copy];
    return sessionConfiguration;
}

+ (NSURLSessionDataTask *)dataTaskForURL:(nullable NSURL *)url
                    sessionConfiguration:(nullable NSURLSessionConfiguration *)sessionConfiguration
                             requestType:(EPSHTTPRequestType)requestType
                                bodyData:(NSData *)bodyData
                              completion:(void (^)(NSDictionary *_Nullable response, NSError *_Nullable error))completion {
    if (!CHECK_CLASS(url, NSURL)) {
        return nil;
    }

    if (!CHECK_CLASS(sessionConfiguration, NSURLSessionConfiguration)) {
        sessionConfiguration = EPSRequestBuilder.defaultSessionConfiguration;
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];

    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];

    // HTTP Method
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    switch (requestType) {
        case EPSHTTPRequestTypeGet:
            [urlRequest setHTTPMethod:@"GET"];
            break;
        case EPSHTTPRequestTypePost:
            [urlRequest setHTTPMethod:@"POST"];
            break;
        case EPSHTTPRequestTypePut:
            [urlRequest setHTTPMethod:@"PUT"];
            break;
    }

    // Body Data
    if (CHECK_CLASS(bodyData, NSData)) {
        [urlRequest setHTTPBody:bodyData];
    }

    NSURLSessionDataTask *dataTask = [session
                                      dataTaskWithRequest:urlRequest
                                      completionHandler:^(NSData *data,
                                                          NSURLResponse *response,
                                                          NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (completion) {
                completion(responseDictionary, parseError);
            }
        } else {
            if (completion) {
                completion(nil, error);
            }
        }
    }];

    [dataTask resume];
    return dataTask;
}
@end
