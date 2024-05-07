//
//  NSDateFormatter+MediumDateFormatter.h
//  FlickZDemo
//
//  Created by Robyn Chau on 18/07/2022.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (MediumDateFormatter)

+ (NSDateFormatter *)serverParser;
+ (NSDateFormatter *)shared;

@end
