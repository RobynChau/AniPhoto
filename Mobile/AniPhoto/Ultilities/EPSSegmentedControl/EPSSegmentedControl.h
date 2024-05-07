//
//  EPSSegmentedControl.h
//  AniPhoto
//
//  Created by PhatCH on 04/03/2024.
//

#import <UIKit/UIKit.h>
@class EPSSegmentedControl;

/**
 *  @brief Style of transition between selected and unselected state of segments.
 */
typedef NS_ENUM(NSUInteger, EPSSegmentedControlTransitionStyle) {
    /**
     *  @brief No transition. This style is preffered with custom transition provided by delegate.
     */
    EPSSegmentedControlTransitionStyleNone = 0,
    /**
     *  @brief Selected state view cutted by selection is showed on top of the unselected state view.
     */
    EPSSegmentedControlTransitionStyleSlide,
    /**
     *  @brief Selected state view alpha is changing to 1.0 and unselected stata view alpha is changing to 0.0 based on current position of selection.
     */
    EPSSegmentedControlTransitionStyleFade
};

/**
 *  @brief Style of selection shape.
 */
typedef NS_ENUM(NSUInteger, EPSSegmentedControlShapeStyle) {
    /**
     *  @brief Rounded rectangle shape.
     */
    EPSSegmentedControlShapeStyleRoundedRect,
    /**
     *  @brief Liquid shape.
     */
    EPSSegmentedControlShapeStyleLiquid
};

/**
 *  @brief Enumeration that represents bounces.
 */
typedef NS_ENUM(NSUInteger, EPSSegmentedControlBounce) {
    /**
     *  @brief Represent left bounce.
     */
    EPSSegmentedControlBounceLeft,
    /**
     *  @brief Represent right bounce.
     */
    EPSSegmentedControlBounceRight
};

/**
 *  @brief EPSSegmentedControl delegate protocol.
 */
@protocol EPSSegmentedControlDelegate <NSObject>

@optional
/**
 *  @brief Tells the delegate that state of segmented control has been just changed.
 *
 *  @param segmentedControl EPSSegmentedControl instance that informs delegate about this event.
 *  @param fromIndex        Previous state of control.
 *  @param toIndex          Currently selected state of control.
 */
- (void)segmentedControl:(EPSSegmentedControl *)segmentedControl didChangeStateFromStateAtIndex:(NSInteger)fromIndex toStateAtIndex:(NSInteger)toIndex;
/**
 *  @brief Tells the delegate that state of segmented control will be changed.
 *
 *  @param segmentedControl EPSSegmentedControl instance that informs delegate about this event.
 *  @param fromIndex        Currently selected state of control.
 */
- (void)segmentedControl:(EPSSegmentedControl *)segmentedControl willChangeStateFromStateAtIndex:(NSInteger)fromIndex;
/**
 *  @brief Tells the delegate that offset of segmented control has been changed.
 *
 *  @param segmentedControl EPSSegmentedControl instance that informs delegate about this event.
 *  @param offset           X coordinate of current segmented control offset.
 */
- (void)segmentedControl:(EPSSegmentedControl *)segmentedControl didScrollWithXOffset:(CGFloat)offset;
/**
 *  @brief Asks the delegate to setup segment with custom transition style.
 *
 *  @param segmentedControl EPSSegmentedControl instance that asks delegate.
 *  @param stateIndex       Index of segment to setup.
 *  @param stateView        View for unselected state of segment.
 *  @param selectedView     View for selected state of segment.
 *  @param percent          Percent of selection. This value is in range [-1..1]. Value -1 represents state when selection right edge is coincident with the left edge of segment. Values from -1 to 0 represent states when selection right edge is moving from the left edge to the right edge of segment. Value 0 represents fully selected state. Values from 0 to 1 represent states when selection left edge is moving from the left edge to the right edge of segment. Value 1 represents state when selection left edge is coincident with the right edge of segment.
 */
- (void)segmentedControl:(EPSSegmentedControl *)segmentedControl setupStateAtIndex:(NSInteger)stateIndex stateView:(UIView *)stateView selectedView:(UIView *)selectedView withSelectionPercent:(CGFloat)percent;
/**
 *  @brief Asks the delegate to reset all customization that had been done in segmentedControl:setupStateAtIndex:stateView:selectedView:withSelectionPercent:. This method is designed to handle switching between transition styles.
 *
 *  @param segmentedControl EPSSegmentedControl instance that asks delegate.
 *  @param stateIndex       Index of segment to reset.
 *  @param stateView        View for unselected state of segment.
 *  @param selectedView     View for selected state of segment.
 *  @see segmentedControl:setupStateAtIndex:stateView:selectedView:withSelectionPercent:
 */
- (void)segmentedControl:(EPSSegmentedControl *)segmentedControl resetStateAtIndex:(NSInteger)stateIndex stateView:(UIView *)stateView selectedView:(UIView *)selectedView;

@end

/**
 *  @brief EPSSegmentedControl data source protocol.
 */
@protocol EPSSegmentedControlDataSource <NSObject>

@required
/**
 *  @brief Tells the data source to return the number of segments in a segmented control.
 *
 *  @param segmentedControl EPSSegmentedControl instance that asks data source.
 *
 *  @return Number of segments.
 */
- (NSInteger)numberOfStatesInSegmentedControl:(EPSSegmentedControl *)segmentedControl;

@optional
/**
 *  @brief Tells the data source to return colors for selection in segment at index in a segmented control. Returned colors will form a gradient.
 *
 *  @param segmentedControl EPSSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return Array of colors to form a gradient.
 */
- (NSArray <UIColor *> *)segmentedControl:(EPSSegmentedControl *)segmentedControl gradientColorsForStateAtIndex:(NSInteger)index;
/**
 *  @brief Tells the data source to return colors for bounce in segment at index in a segmented control. Returned colors will form a gradient.
 *
 *  @param segmentedControl EPSSegmentedControl instance that asks data source.
 *  @param bounce           Member of EPSSegmentedControlBounce enumeration.
 *
 *  @return Array of colors to form a gradient.
 */
- (NSArray <UIColor *> *)segmentedControl:(EPSSegmentedControl *)segmentedControl gradientColorsForBounce:(EPSSegmentedControlBounce)bounce;
/**
 *  @brief Tells the data source to return title for segment at index in a segmented control.
 *
 *  @param segmentedControl EPSSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return String to be title for segment.
 */
- (NSString *)segmentedControl:(EPSSegmentedControl *)segmentedControl titleForStateAtIndex:(NSInteger)index;
/**
 *  @brief Tells the data source to return attributed title for segment at index in a segmented control.
 *
 *  @param segmentedControl EPSSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return Attributed string to be title for segment.
 */
- (NSAttributedString *)segmentedControl:(EPSSegmentedControl *)segmentedControl attributedTitleForStateAtIndex:(NSInteger)index;
/**
 *  @brief Tells the data source to return title for selected state of segment at index in a segmented control.
 *
 *  @param segmentedControl EPSSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return String to be title for segment in selected state.
 */
- (NSString *)segmentedControl:(EPSSegmentedControl *)segmentedControl titleForSelectedStateAtIndex:(NSInteger)index;
/**
 *  @brief Tells the data source to return attributed title for selected state of segment at index in a segmented control.
 *
 *  @param segmentedControl EPSSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return Attributed string to be title for segment in selected state.
 */
- (NSAttributedString *)segmentedControl:(EPSSegmentedControl *)segmentedControl attributedTitleForSelectedStateAtIndex:(NSInteger)index;
/**
 *  @brief Tells the data source to return view for segment at index in a segmented control.
 *
 *  @param segmentedControl EPSSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return View for segment.
 */
- (UIView *)segmentedControl:(EPSSegmentedControl *)segmentedControl viewForStateAtIndex:(NSInteger)index;
/**
 *  @brief Tells the data source to return view for selected state of segment at index in a segmented control.
 *
 *  @param segmentedControl EPSSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return View for selected state of segment.
 */
- (UIView *)segmentedControl:(EPSSegmentedControl *)segmentedControl viewForSelectedStateAtIndex:(NSInteger)index;

@end

/**
 *  @brief Control designed to let user switch between number of states. It provides many ways of customization.
 */
@interface EPSSegmentedControl : UIView

/**
 *  @brief Delegate of EPSSegmentedControl.
 */
@property (nonatomic, weak) IBOutlet id <EPSSegmentedControlDelegate> delegate;
/**
 *  @brief Data source of EPSSegmentedControl.
 */
@property (nonatomic, weak) IBOutlet id <EPSSegmentedControlDataSource> dataSource;

/**
 *  @brief Number of currently selected segment. It is in range [0..stateCount-1].
 */
@property (nonatomic, assign) NSInteger currentState;
/**
 *  @brief Number of segments in control.
 */
@property (nonatomic, assign) NSInteger statesCount;

/**
 *  @brief Style of transition between selected and unselected state of segments.
 */
@property (nonatomic, assign) EPSSegmentedControlTransitionStyle transitionStyle;
/**
 *  @brief Style of selection shape.
 */
@property (nonatomic, assign) EPSSegmentedControlShapeStyle shapeStyle;
/**
 *  @brief Corner radius of control.
 */
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
/**
 *  @brief Text color applied to title if data source does not provide attributed titles or views.
 */
@property (nonatomic, strong) IBInspectable UIColor *textColor;
/**
 *  @brief Text color applied to title in selected state if data source does not provide attributed titles for selected state or views for selected state.
 */
@property (nonatomic, strong) IBInspectable UIColor *selectedStateTextColor;
/**
 *  @brief Color of selection. It will be overlayed on top of gradient state colors.
 */
@property (nonatomic, strong) IBInspectable UIColor *selectorViewColor;
/**
 *  @brief Text font applied to title in both selected and unselected state if data source does not provide attributed titles or views.
 */
@property (nonatomic, strong) UIFont *textFont;
/**
 *  @brief Value that determine whether shape of selection should be cutted by corner radius of segmented control.
 */
@property (nonatomic, assign) BOOL applyCornerRadiusToSelectorView;
/**
 *  @brief Color applied for bounce if data source does not provide color for bounces.
 */
@property (nonatomic, strong) UIColor *gradientBounceColor;
/**
 *  @brief Duration of shadow showing.
 */
@property (nonatomic, assign) CGFloat shadowShowDuration;
/**
 *  @brief Duration of shadow hiding.
 */
@property (nonatomic, assign) CGFloat shadowHideDuration;
/**
 *  @brief Value that determine wheter shadow should be applied.
 */
@property (nonatomic, assign) BOOL shadowsEnabled;

/**
 *  @brief Reload all data of control.
 */
- (void)reloadData;

@end
