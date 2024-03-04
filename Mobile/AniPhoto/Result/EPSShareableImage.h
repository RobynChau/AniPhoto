//
//  EPSShareableImage.h
//  AniPhoto
//
//  Created by PhatCH on 24/4/24.
//

#import <UIKit/UIKit.h>
#import <LinkPresentation/LinkPresentation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSShareableImage : NSObject <UIActivityItemSource>

- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
