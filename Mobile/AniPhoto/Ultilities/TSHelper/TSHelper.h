//
//  TSHelper.h
//  AniPhoto
//
//  Created by PhatCH on 25/5/24.
//

#import <Foundation/Foundation.h>

#if defined(__cplusplus)
extern "C" {
#endif
    void setMainQueueIdentifier(void);
    BOOL isMainQueue(void);
    BOOL isCurrentQueue(dispatch_queue_t queue, const char* queueName);

    NSString* createQueueNameWithObjectFoundation(NSObject* object);
    NSString* createQueueNameWithObjectAndPrefix(NSObject* object,NSString* prefix);

    dispatch_queue_t createDispatchQueueWithObject(NSObject* object, const char* name, BOOL serial);

    void dispatchOnQueue(dispatch_queue_t queue, const char* name, dispatch_block_t block, BOOL sync);


#if defined(__cplusplus)
}
#endif

#if DEBUG
    #define ASSERT_ON_MAIN_QUEUE NSAssert(isMainQueue(), @"Should be run on main queue.");
#else // DEBUG
    #define ASSERT_ON_MAIN_QUEUE {}
#endif // DEBUG

@interface TSHelper : NSObject

#pragma mark - Create Queue
+ (NSString*)createDispatchQueueName:(NSObject*)object;
+ (dispatch_queue_t)createDispatchQueue:(NSObject*)object withName:(const char*)queueName isSerial:(BOOL)isSerial;

#pragma mark - Check Queue

+ (BOOL)isCurrentQueue:(dispatch_queue_t)queue withName:(const char*)queueName;

#pragma mark - Dispatch

+ (void)dispatchSyncOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block;
+ (void)dispatchAsyncOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block;

+ (void)dispatchBarrierSyncOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block;
+ (void)dispatchBarrierOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block;

+ (void)dispatchOnQueue:(dispatch_queue_t)queue withName:(const char*)queueName withTask:(dispatch_block_t)block;

#pragma mark - Dispatch Main
+ (void)dispatchOnMainQueue:(dispatch_block_t)block;
+ (void)dispatchAsyncMainQueue:(dispatch_block_t)block;

+ (void)dispatchTask:(dispatch_block_t)block afterDelay:(float)delay onQueue:(dispatch_queue_t)queue;
+ (void)dispatchTaskMainQueue:(dispatch_block_t)block afterDelay:(float)delay;

@end
