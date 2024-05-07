//
//  NSDictionary+Accessors.h
//  AniPhoto
//
//  Created by PhatCH on 29/4/24.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Accessors)

- (BOOL)eps_isKindOfClass:(Class)aClass forKey:(NSString *)key;
- (BOOL)eps_isMemberOfClass:(Class)aClass forKey:(NSString *)key;
- (BOOL)eps_isArrayForKey:(NSString *)key;
- (BOOL)eps_isDictionaryForKey:(NSString *)key;
- (BOOL)eps_isStringForKey:(NSString *)key;
- (BOOL)eps_isNumberForKey:(NSString *)key;

- (NSArray *)eps_arrayForKey:(NSString *)key;
- (NSDictionary *)eps_dictionaryForKey:(NSString *)key;
- (NSString *)eps_stringForKey:(NSString *)key;
- (NSNumber *)eps_numberForKey:(NSString *)key;
- (double)eps_doubleForKey:(NSString *)key;
- (float)eps_floatForKey:(NSString *)key;
- (int)eps_intForKey:(NSString *)key;
- (unsigned int)eps_unsignedIntForKey:(NSString *)key;
- (NSInteger)eps_integerForKey:(NSString *)key;
- (NSUInteger)eps_unsignedIntegerForKey:(NSString *)key;
- (long long)eps_longLongForKey:(NSString *)key;
- (unsigned long long)eps_unsignedLongLongForKey:(NSString *)key;
- (BOOL)eps_boolForKey:(NSString *)key;

@end
