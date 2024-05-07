//
//  EPSAniGANResultSecondaryToolView.h
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EPSAniGANResultSecondaryToolView;

typedef enum : NSUInteger {
    EPSAniGANResultSecondaryToolTypeShare       = 0,
    EPSAniGANResultSecondaryToolTypeDownload    = 1,
} EPSAniGANResultSecondaryToolType;

@protocol EPSAniGANResultSecondaryToolViewDelegate <NSObject>

@required
- (void)toolView:(EPSAniGANResultSecondaryToolView *)toolView didSelectToolType:(EPSAniGANResultSecondaryToolType)toolType;

@end

@interface EPSAniGANResultSecondaryToolView : UIView

@property (nonatomic, weak) id<EPSAniGANResultSecondaryToolViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
