//
//  EPSPhotoGenerator.h
//  AniPhoto
//
//  Created by PhatCH on 24/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^EPSPhotoGeneratorUploadCompletionBlock)(NSURL *_Nullable photoURL, NSError *_Nullable error);
typedef void(^EPSPhotoGeneratorCompletionBlock)(UIImage *_Nullable resultImage, NSError *_Nullable error);

@interface EPSPhotoGenerator : NSObject

+ (EPSPhotoGenerator *)manager;

- (void)generatePhotoWithUIImage:(UIImage *)uiImage
                      completion:(EPSPhotoGeneratorCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
