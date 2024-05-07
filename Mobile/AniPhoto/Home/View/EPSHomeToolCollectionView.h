//
//  EPSHomeToolCollectionView.h
//  AniPhoto
//
//  Created by PhatCH on 19/5/24.
//

#import <UIKit/UIKit.h>
#import "EPSHomeToolCell.h"

NS_ASSUME_NONNULL_BEGIN

@class EPSHomeToolCollectionView;

@protocol EPSHomeToolViewDelegate <NSObject>
@required
- (void)toolView:(EPSHomeToolCollectionView *)toolView didSelectTool:(EPSHomeToolType)toolType;
@end

@interface EPSHomeToolCollectionView : UIView
@property (nonatomic, weak) id<EPSHomeToolViewDelegate> delegate;
- (instancetype)initWithShouldScroll:(BOOL)shouldScroll;

@end

NS_ASSUME_NONNULL_END
