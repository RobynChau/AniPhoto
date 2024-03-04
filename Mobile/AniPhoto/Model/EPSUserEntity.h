//
//  EPSUserEntity.h
//  AniPhoto
//
//  Created by PhatCH on 23/01/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSUserEntity : NSObject

@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, copy, readonly) NSString *userName;
@property (nonatomic, copy, readonly) NSString *userEmail;
@property (nonatomic, copy, readonly) NSString *userFirstName;
@property (nonatomic, copy, readonly) NSString *userLastName;

@end

NS_ASSUME_NONNULL_END
