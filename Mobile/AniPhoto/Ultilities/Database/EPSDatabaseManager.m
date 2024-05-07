//
//  EPSDatabaseManager.m
//  AniPhoto
//
//  Created by PhatCH on 8/5/24.
//

#import "EPSDatabaseManager.h"
@import FMDB;

@implementation EPSDatabaseManager {
    FMDatabase *database;
}

+ (instancetype)sharedInstance {
    static EPSDatabaseManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EPSDatabaseManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *docsDir;
        NSArray *dirPaths;

        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = dirPaths[0];

        // Build the path to the database file
        NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"images.db"]];

        // Initialize the FMDatabase object
        database = [FMDatabase databaseWithPath:databasePath];

        // Open the database
        if (![database open]) {
            NSLog(@"Failed to open database.");
        } else {
            NSString *createTableQuery = @"CREATE TABLE IF NOT EXISTS Images (id INTEGER PRIMARY KEY AUTOINCREMENT, image_data BLOB, creation_time INTEGER)";
            [database executeUpdate:createTableQuery];
        }
    }
    return self;
}

- (BOOL)saveImage:(UIImage *)image withCreationTime:(NSDate *)creationDate {
    NSData *imageData = UIImagePNGRepresentation(image);
    NSNumber *creationTime = @(creationDate.timeIntervalSince1970);
    return [database executeUpdate:@"INSERT INTO Images (image_data, creation_time) VALUES (?, ?)", imageData, creationTime];
}

- (NSArray *)loadImages {
    NSMutableArray *images = [NSMutableArray array];
    FMResultSet *resultSet = [database executeQuery:@"SELECT * FROM Images ORDER BY creation_time DESC"];
    while ([resultSet next]) {
        NSData *imageData = [resultSet dataForColumn:@"image_data"];
        UIImage *image = [UIImage imageWithData:imageData];
        NSString *creationTimeString = [resultSet stringForColumn:@"creation_time"];
        NSDate *creationTime = [self dateFromString:creationTimeString];
        [images addObject:image];
    }
    [resultSet close];
    return images;
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

- (NSDate *)dateFromString:(NSString *)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter dateFromString:string];
}


@end
