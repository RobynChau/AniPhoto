//
//  TSHelper.m
//  AniPhoto
//
//  Created by PhatCH on 25/5/24.
//

#import "TSHelper.h"
#import <Foundation/Foundation.h>
static NSString* const mainQueueStr = @"AniPhoto-Main-Queue";
static const char* mainQueueName;

void setMainQueueIdentifier(void)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        const char* mainQueueNameTmp = [mainQueueStr UTF8String];

        size_t length = strlen(mainQueueNameTmp);
        mainQueueName = (char *) malloc(length + 1);
        strcpy((char *) mainQueueName, mainQueueNameTmp);

        dispatch_queue_set_specific(dispatch_get_main_queue(), mainQueueName, (void*)mainQueueName, NULL);
    });
}

BOOL isMainQueue(void) {
    return dispatch_get_specific(mainQueueName) != NULL;
}

BOOL isCurrentQueue(dispatch_queue_t queue, const char* queueName) {
    return dispatch_get_specific(queueName) != NULL;
}

NSString* createQueueNameWithObjectFoundation(NSObject* object) {
    return createQueueNameWithObjectAndPrefix(object, @"com.PhatCH.AniPhoto.helper.queue");
}

inline NSString* createQueueNameWithObjectAndPrefix(NSObject* object,NSString* prefix) {
    return [NSString stringWithFormat:@"%@.%@.%p", prefix, [[object class] description], object];
}

dispatch_queue_t createDispatchQueueWithObject(NSObject* object, const char* name, BOOL serial) {

    dispatch_queue_t dispatchQueue = dispatch_queue_create(name, serial?DISPATCH_QUEUE_SERIAL:DISPATCH_QUEUE_CONCURRENT);

    dispatch_queue_set_specific(dispatchQueue, name, (void*) name, NULL);

    return dispatchQueue;
}

@implementation TSHelper

#pragma mark - Create Queue

+ (NSString*)createDispatchQueueName:(NSObject*)object {
    return [NSString stringWithFormat:@"%@_dispatchQueue_%p", [[object class] description], object];
}

+ (dispatch_queue_t)createDispatchQueue:(NSObject*)object withName:(const char*)queueName isSerial:(BOOL)isSerial {
    return createDispatchQueueWithObject(object, queueName, isSerial);
}

#pragma mark - Check Queue

+ (BOOL)isCurrentQueue:(dispatch_queue_t)queue withName:(const char*)queueName {
    return isCurrentQueue(queue, queueName);
}

#pragma mark - Dispatch

+ (void)dispatchSyncOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block {
    if (isCurrentQueue(queue, queueName))
    {
        block();
    }
    else
        dispatch_sync(queue, block);
}

+ (void)dispatchAsyncOnQueue:(dispatch_queue_t)queue withName:(const char *)queueName withTask:(dispatch_block_t)block {
    dispatch_async(queue, block);
}

+ (void)dispatchTask:(dispatch_block_t)block afterDelay:(float)delay onQueue:(dispatch_queue_t)queue {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), queue, block);
}

+ (void)dispatchOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block {
    if (isCurrentQueue(queue, queueName)) {
        block();
    } else {
        dispatch_async(queue, block);
    }
}

+ (void)dispatchBarrierSyncOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block {
    if (isCurrentQueue(queue, queueName))
    {
        block();
    }
    else
        dispatch_barrier_sync(queue, block);
}

+ (void)dispatchBarrierOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block {
    if (isCurrentQueue(queue, queueName))
    {
        block();
    }
    else
        dispatch_barrier_async(queue, block);
}

#pragma mark - Dispatch Main

+ (void)dispatchOnMainQueue:(dispatch_block_t)block {
    if (dispatch_get_specific(mainQueueName) != NULL)
    {
        block();
    }
    else
        dispatch_async(dispatch_get_main_queue(), block);
}

+ (void)dispatchAsyncMainQueue:(dispatch_block_t)block {
    dispatch_async(dispatch_get_main_queue(), block);
}

+ (void)dispatchTaskMainQueue:(dispatch_block_t)block afterDelay:(float)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}

@end
