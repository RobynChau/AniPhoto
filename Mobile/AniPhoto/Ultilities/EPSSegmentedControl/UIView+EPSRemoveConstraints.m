//
//  UIView+EPSRemoveConstraints.m
//  AniPhoto
//
//  Created by PhatCH on 04/03/2024.
//
#import "UIView+EPSRemoveConstraints.h"

@implementation UIView (EPSRemoveConstraints)

- (void)eps_removeConstraintsFromSubTree:(NSSet <NSLayoutConstraint *> *)constraints {
    NSMutableArray <NSLayoutConstraint *> *constraintsToRemove = [[NSMutableArray alloc] init];
    for (NSLayoutConstraint *constraint in self.constraints) {
        if ([constraints containsObject:constraint]) {
            [constraintsToRemove addObject:constraint];
        }
    }
    [self removeConstraints:constraintsToRemove];
    for (UIView *view in self.subviews) {
        [view eps_removeConstraintsFromSubTree:constraints];
    }
}

@end
