//
//  EPSModelOption.m
//  AniPhoto
//
//  Created by PhatCH on 16/4/24.
//

#import "EPSModelOption.h"

@implementation EPSModelOption

- (instancetype)initWithModelID:(NSString *)modelID
                      modelName:(NSString *)modelName
                       modelURL:(NSString *)modelURL
                  modelResource:(NSString *)modelResource {
    self = [super init];
    if (self) {
        _modelID = modelID;
        _modelName = modelName;
        _modelURL = modelURL;
        _modelResource = modelResource;
    }
    return self;
}

@end
