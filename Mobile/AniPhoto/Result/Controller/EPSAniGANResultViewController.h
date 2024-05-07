//
//  EPSAniGANResultViewController.h
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSAniGANResultViewController : UIViewController

- (instancetype)initWithOriginImage:(UIImage *)image shouldGenerate:(BOOL)shouldGenerate isStandAloneVC:(BOOL)isStandAloneVC;

@end

NS_ASSUME_NONNULL_END
