//
//  EPSModelOptionSectionLabel.h
//  AniPhoto
//
//  Created by PhatCH on 16/4/24.
//

#import <UIKit/UIKit.h>
#import "EPSDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface EPSModelOptionSectionLabel : UIView

- (instancetype)initWithType:(HomeModelSectionType)sectionType
                       title:(NSString *)title;

- (CGSize)calculatedSize;
@end

NS_ASSUME_NONNULL_END
