//
//  EPSWeakProxy.h
//  AniPhoto
//
//  Created by PhatCH on 2023/12/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSWeakProxy : NSObject

@property (nonatomic, weak, readonly, nullable) id target;

- (nonnull instancetype)initWithTarget:(nonnull id)target NS_SWIFT_NAME(init(target:));
+ (nonnull instancetype)proxyWithTarget:(nonnull id)target NS_SWIFT_NAME(proxy(target:));

@end

NS_ASSUME_NONNULL_END
