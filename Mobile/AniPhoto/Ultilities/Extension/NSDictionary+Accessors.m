//
//  NSDictionary+Accessors.m
//  AniPhoto
//
//  Created by PhatCH on 29/4/24.
//

#import "NSDictionary+Accessors.h"

@implementation NSDictionary (Accessors)

- (BOOL)eps_isKindOfClass:(Class)aClass forKey:(NSString *)key {
    id value = [self objectForKey:key];
    return [value isKindOfClass:aClass];
}

- (BOOL)eps_isMemberOfClass:(Class)aClass forKey:(NSString *)key {
    id value = [self objectForKey:key];
    return [value isMemberOfClass:aClass];
}

- (BOOL)eps_isArrayForKey:(NSString *)key {
    return [self eps_isKindOfClass:[NSArray class] forKey:key];
}

- (BOOL)eps_isDictionaryForKey:(NSString *)key {
    return [self eps_isKindOfClass:[NSDictionary class] forKey:key];
}

- (BOOL)eps_isStringForKey:(NSString *)key {
    return [self eps_isKindOfClass:[NSString class] forKey:key];
}

- (BOOL)eps_isNumberForKey:(NSString *)key {
    return [self eps_isKindOfClass:[NSNumber class] forKey:key];
}

- (NSArray *)eps_arrayForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    return nil;
}

- (NSDictionary *)eps_dictionaryForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    return nil;
}

- (NSString *)eps_stringForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value respondsToSelector:@selector(description)]) {
        return [value description];
    }
    return nil;
}

- (NSNumber *)eps_numberForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        return [nf numberFromString:value];
    }
    return nil;
}

- (double)eps_doubleForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value doubleValue];
    }
    return 0;
}

- (float)eps_floatForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value floatValue];
    }
    return 0;
}

- (int)eps_intForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value intValue];
    }
    return 0;
}

- (unsigned int)eps_unsignedIntForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        value = [nf numberFromString:value];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value unsignedIntValue];
    }
    return 0;
}

- (NSInteger)eps_integerForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value integerValue];
    }
    return 0;
}

- (NSUInteger)eps_unsignedIntegerForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        value = [nf numberFromString:value];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value unsignedIntegerValue];
    }
    return 0;
}

- (long long)eps_longLongForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value longLongValue];
    }
    return 0;
}

- (unsigned long long)eps_unsignedLongLongForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        value = [nf numberFromString:value];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value unsignedLongLongValue];
    }
    return 0;
}

- (BOOL)eps_boolForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
    return NO;
}

@end
