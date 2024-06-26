//
//  EPSPhotoGenerator.m
//  AniPhoto
//
//  Created by PhatCH on 24/4/24.
//

#import "EPSPhotoGenerator.h"
#import "AnimeGANv2_1024.h"
#import "EPSDefines.h"
#import "UIImage+EPS.h"
#import "EPSUserSessionManager.h"
#import <SDWebImage/SDWebImage.h>
#import "EPSDatabaseManager.h"
#import "EPSUserSessionManager.h"
@import FirebaseStorage;

@interface EPSPhotoGenerator () {
    dispatch_queue_t        _actionQueue;
    const char*             _actionQueueName;
    NSString*               _actionQueueNameStr;
}
@property (nonatomic, assign) BOOL shouldUseOnDevice;
@end

@implementation EPSPhotoGenerator

+ (EPSPhotoGenerator *)manager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self.class alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _actionQueueNameStr = @"com.PhatCH.ZASPhotoFeedBackgroundImageContext";
        _actionQueueName = [_actionQueueNameStr UTF8String];
        _actionQueue = createDispatchQueueWithObject(self, _actionQueueName, YES);

        _shouldUseOnDevice = NO;
    }
    return self;
}

- (void)generatePhotoWithUIImage:(UIImage *)uiImage 
                      completion:(EPSPhotoGeneratorCompletionBlock)completion {
    if (!uiImage) {
        completion(nil, nil);
        return;
    }
    dispatch_async(_actionQueue, ^{
        UIImage *processedUIImage = [self _preprocessedUIImage:uiImage];
        [self uploadImageToFirebase:processedUIImage
                             userID:EPSUserSessionManager.shared.deviceID
                         completion:^(NSURL * _Nullable photoURL, NSError * _Nullable error) {
            if (photoURL) {
                if (self.shouldUseOnDevice) {
                    [self _generatePhotoUsingOnDeviceModelWithUIImage:processedUIImage completion:completion];
                } else {
                    [self _generatePhotoUsingServerModelWithURL:photoURL 
                                                     completion:^(UIImage * _Nullable resultImage,
                                                                  NSError * _Nullable error) {
//                        if (!resultImage) {
//                            [self _generatePhotoUsingOnDeviceModelWithUIImage:processedUIImage completion:completion];
//                        } else {
                            completion(resultImage, nil);
//                        }
                    }];
                }
            } else {
                completion(nil, error);
            }
        }];
    });
}

- (void)uploadImageToFirebase:(UIImage *)image
                       userID:(NSString *)userID
                   completion:(EPSPhotoGeneratorUploadCompletionBlock)completion {
    NSData *uploadData = UIImageJPEGRepresentation(image, 0.8);
    NSString *fileID = [NSString stringWithFormat:@"%0.f.jpg", ceil(NSDate.now.timeIntervalSince1970)];
    FIRStorageMetadata *metaData = [[FIRStorageMetadata alloc] init];
    metaData.contentType = @"image/jpeg";
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage reference];
    FIRStorageReference *userRef = [storageRef child:userID];
    FIRStorageReference *userRawRef = [userRef child:@"raw"];
    FIRStorageReference *photoRawRef = [userRawRef child:fileID];
    FIRStorageUploadTask *uploadTask = [photoRawRef
                                        putData:uploadData
                                        metadata:metaData
                                        completion:^(FIRStorageMetadata * _Nullable metadata,
                                                     NSError * _Nullable error) {
        if (error != nil) {
            completion(nil, error);
        } else {
            [photoRawRef downloadURLWithCompletion:^(NSURL * _Nullable rawFirebaseURL, NSError * _Nullable error) {
                if (rawFirebaseURL) {
                    completion(rawFirebaseURL, nil);
                } else {
                    completion(nil, error);
                }
            }];
        }
    }];
}

- (void)_generatePhotoUsingServerModelWithURL:(NSURL *)photoUrl
                                   completion:(EPSPhotoGeneratorCompletionBlock)completion {
    NSString *urlString = [NSString stringWithFormat:@"%@/v2/ml/anime", kServerEndPointURL];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionConfiguration *sessionConfiguration = EPSRequestBuilder.defaultSessionConfiguration;

    NSDictionary *mapData = @{
        @"source_img_path" : photoUrl.absoluteString,
    };

    NSError *convertPostDataError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&convertPostDataError];

    if (!bodyData) {
        completion(nil, convertPostDataError);
        return;
    }

    [EPSRequestBuilder dataTaskForURL:url 
                 sessionConfiguration:sessionConfiguration
                          requestType:EPSHTTPRequestTypePost
                             bodyData:bodyData
                           completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        if ([response eps_stringForKey:@"processed_url"]) {
            [EPSUserSessionManager.shared fetchUserCredit];

            NSInteger currentCreditCount = EPSUserSessionManager.shared.userSession.totalCreditCount;
            [EPSUserSessionManager.shared.userSession updateTempCreditCount:currentCreditCount - 1];

            NSString *processedImageURL = [response eps_stringForKey:@"processed_url"];
            [[SDWebImageDownloader sharedDownloader]
             downloadImageWithURL:[NSURL URLWithString:processedImageURL]
             completed:^(UIImage * _Nullable image,
                         NSData * _Nullable data,
                         NSError * _Nullable error,
                         BOOL finished) {
                completion(image, error);
            }];
        } else {
            NSLog(@"PhatCH Failed Gen Anime");
            completion(nil, error);
        }
    }];
}

- (void)_generatePhotoUsingOnDeviceModelWithUIImage:(UIImage *)uiImage 
                                         completion:(EPSPhotoGeneratorCompletionBlock)completion {
    if (@available(iOS 14.0, *)) {
        NSError *error;

        AnimeGANv2_1024 *model = [[AnimeGANv2_1024 alloc] init];
        AnimeGANv2_1024Input *input = [[AnimeGANv2_1024Input alloc] initWithInputFromCGImage:uiImage.CGImage error:nil];
        AnimeGANv2_1024Output *output = [model predictionFromFeatures:input error:&error];

        UIImage *result = [UIImage imageWithCIImage:[CIImage imageWithCVPixelBuffer:output.output]];
        completion(result, error);
    } else {
        NSError *error = [NSError errorWithDomain:@"PhotoGenerateError" code:0 userInfo:nil];
        completion(nil, error);
    }
}

- (UIImage *)_preprocessedUIImage:(UIImage *)uiImage {
    UIImage *normalizedUIImage = [uiImage normalizedImage];
    return normalizedUIImage;
}

@end
