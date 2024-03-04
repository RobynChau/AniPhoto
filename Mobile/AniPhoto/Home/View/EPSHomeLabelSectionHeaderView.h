//
//  EPSHomeLabelSectionHeaderView.h
//  AniPhoto
//
//  Created by PhatCH on 17/4/24.
//

#import <UIKit/UIKit.h>
#import "EPSDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface EPSHomeLabelSectionHeaderView : UICollectionReusableView

+ (NSString *)reusableViewIdentifier;

- (void)setSectionType:(HomeModelSectionType)sectionType
           sectionName:(NSString *)sectionName;
@end

NS_ASSUME_NONNULL_END
