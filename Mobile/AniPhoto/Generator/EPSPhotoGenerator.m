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
#import <SDWebImage/SDWebImage.h>
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
        dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
        _actionQueue = dispatch_queue_create(_actionQueueName, qos);

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
                             userID:@"21062001"
                         completion:^(NSURL * _Nullable photoURL, NSError * _Nullable error) {
            if (photoURL) {
                if (self.shouldUseOnDevice) {
                    [self _generatePhotoUsingOnDeviceModelWithUIImage:processedUIImage completion:completion];
                } else {
                    [self _generatePhotoUsingServerModelWithURL:photoURL 
                                                     completion:^(UIImage * _Nullable resultImage,
                                                                  NSError * _Nullable error) {
                        if (!resultImage) {
                            [self _generatePhotoUsingOnDeviceModelWithUIImage:processedUIImage completion:completion];
                        } else {
                            completion(resultImage, nil);
                        }
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
    NSString *urlString = [NSString stringWithFormat:@"%@/process/", kModelServerLink];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];

    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPMethod:@"POST"];
    NSDictionary *mapData = @{
        @"source_img_path" : photoUrl.absoluteString,
    };

    NSError *convertPostDataError;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&convertPostDataError];

    if (!postData) {
        completion(nil, convertPostDataError);
        return;
    }

    [urlRequest setHTTPBody:postData];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session
                                      dataTaskWithRequest:urlRequest
                                      completionHandler:^(NSData *data,
                                                          NSURLResponse *response,
                                                          NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

            if ([[responseDictionary objectForKey:@"processed_url"] isKindOfClass:NSString.class]) {
                NSString *processedImageURL = [responseDictionary objectForKey:@"processed_url"];
                [[SDWebImageDownloader sharedDownloader]
                 downloadImageWithURL:[NSURL URLWithString:processedImageURL]
                 completed:^(UIImage * _Nullable image,
                             NSData * _Nullable data,
                             NSError * _Nullable error,
                             BOOL finished) {
                    completion(image, error);
                }];
            }
        } else {
            completion(nil, error);
        }
    }];
    [dataTask resume];
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
