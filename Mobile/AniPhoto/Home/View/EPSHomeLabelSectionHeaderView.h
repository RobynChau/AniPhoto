//
//  EPSHomeLabelSectionHeaderView.h
//  AniPhoto
//
//  Created by PhatCH on 17/4/24.
//

#import <UIKit/UIKit.h>
#import "EPSDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class EPSHomeLabelSectionHeaderView;

@protocol EPSHomeLabelSectionHeaderDelegate <NSObject>

@required
- (void)headerView:(EPSHomeLabelSectionHeaderView *)headerView didSelectHeader:(BOOL)didSelect;

@end

@interface EPSHomeLabelSectionHeaderView : UICollectionReusableView

@property (nonatomic, weak) id<EPSHomeLabelSectionHeaderDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger sectionIndex;

+ (NSString *)reusableViewIdentifier;

- (void)setName:(NSString *)name sectionIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
