//
//  EPSRequestBuilder.h
//  AniPhoto
//
//  Created by PhatCH on 25/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    EPSHTTPRequestTypeGet       = 0,
    EPSHTTPRequestTypePost      = 1,
    EPSHTTPRequestTypePut       = 2,
} EPSHTTPRequestType;

@interface EPSRequestBuilder : NSObject

+ (NSURLSessionConfiguration *)defaultSessionConfiguration;

+ (NSURLSessionDataTask *)dataTaskForURL:(nullable NSURL *)url
                    sessionConfiguration:(nullable NSURLSessionConfiguration *)sessionConfiguration
                             requestType:(EPSHTTPRequestType)requestType
                                bodyData:(NSData *)bodyData
                              completion:(void (^)(NSDictionary *_Nullable response, NSError *_Nullable error))completion;



@end

NS_ASSUME_NONNULL_END
