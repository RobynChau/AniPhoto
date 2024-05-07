//
//  NSDateFormatter+MediumDateFormatter.m
//  FlickZDemo
//
//  Created by Robyn Chau on 18/07/2022.
//

#import "NSDateFormatter+MediumDateFormatter.h"

@implementation NSDateFormatter (MediumDateFormatter)

static NSDateFormatter *_serverParser = nil;
static NSDateFormatter *_shared = nil;

+ (NSDateFormatter *)serverParser {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_serverParser) {
            _serverParser = [[NSDateFormatter alloc] init];
            _serverParser.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
            _serverParser.locale = NSLocale.currentLocale;
        }
    });
    return _serverParser;
}

+ (NSDateFormatter *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_shared) {
            _shared = [[NSDateFormatter alloc] init];
            _shared.dateStyle = NSDateFormatterMediumStyle;
            _shared.locale = NSLocale.currentLocale;
        }
    });
    return _shared;
}

@end
