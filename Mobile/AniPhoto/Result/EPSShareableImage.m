//
//  EPSShareableImage.m
//  AniPhoto
//
//  Created by PhatCH on 24/4/24.
//

#import "EPSShareableImage.h"
#import "UIImage+EPS.h"

@interface EPSShareableImage ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@end

@implementation EPSShareableImage

- (instancetype)initWithImage:(UIImage *)image 
                        title:(NSString *)title {
    self = [super init];
    if (self) {
        _image = image;
        _title = title;
    }
    return self;
}

- (nullable id)activityViewController:(nonnull UIActivityViewController *)activityViewController itemForActivityType:(nullable UIActivityType)activityType { 
    return self.image;
}

- (nonnull id)activityViewControllerPlaceholderItem:(nonnull UIActivityViewController *)activityViewController { 
    return self.image;
}

- (LPLinkMetadata *)activityViewControllerLinkMetadata:(UIActivityViewController *)activityViewController {
    LPLinkMetadata *metaData = [[LPLinkMetadata alloc] init];
    metaData.iconProvider = [[NSItemProvider alloc] initWithObject:self.image];
    metaData.title = self.title;
    return metaData;
}

@end
