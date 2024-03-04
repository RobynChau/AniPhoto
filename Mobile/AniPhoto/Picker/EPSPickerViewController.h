//
//  EPSPickerViewController.h
//  AniPhoto
//
//  Created by PhatCH on 01/01/2024.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSPickerViewController : UIViewController

- (instancetype)initWithImage:(UIImage *)image
                    modelName:(NSString *)modelName
                     modelDes:(NSString *)modelDes;

@end

NS_ASSUME_NONNULL_END
