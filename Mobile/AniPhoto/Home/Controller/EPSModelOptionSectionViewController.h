//
//  EPSModelOptionSectionViewController.h
//  AniPhoto
//
//  Created by PhatCH on 16/4/24.
//

#import <UIKit/UIKit.h>
#import "EPSDefines.h"
#import "EPSModelOption.h"

NS_ASSUME_NONNULL_BEGIN

@interface EPSModelOptionSectionViewController : UIViewController

- (instancetype)initWithType:(HomeModelSectionType)sectionType
                 sectionName:(NSString *)sectionName
                 isExclusive:(BOOL)isExclusive
                modelOptions:(NSArray<EPSModelOption *> *)modelOptions;

@end

NS_ASSUME_NONNULL_END
