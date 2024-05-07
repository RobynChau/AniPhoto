//
//  UIView+EPSRemoveConstraints.h
//  AniPhoto
//
//  Created by PhatCH on 04/03/2024.
//

#import <UIKit/UIKit.h>

/**
 *  @brief Category of UIView that provide method to remove set of constraints from view subtree.
 */
@interface UIView (EPSRemoveConstraints)

/**
 *  @brief Remove specified set of constraints from views in receiver subtree and from receiver itself.
 *
 *  @param constraints Set of constraints to remove.
 */
- (void)eps_removeConstraintsFromSubTree:(NSSet <NSLayoutConstraint *> *)constraints;

@end
