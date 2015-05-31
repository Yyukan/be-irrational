//
//  Logger.h
//  WorkingHours
//

#ifndef WorkingHours_Logger_h
#define WorkingHours_Logger_h

#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

#ifndef TRC_LEVEL
#if TARGET_IPHONE_SIMULATOR != 0
#define TRC_LEVEL 0
#else
#define TRC_LEVEL 5
#endif
#endif

/*****************************************************************************/
/* Entry/exit trace macros                                                   */
/*****************************************************************************/
#if TRC_LEVEL == 0
#define TRC_ENTRY    NSLog(@"ENTRY: %s:%d:", __PRETTY_FUNCTION__,__LINE__);
#define TRC_EXIT     NSLog(@"EXIT:  %s:%d:", __PRETTY_FUNCTION__,__LINE__);
#else
#define TRC_ENTRY
#define TRC_EXIT
#endif

/*****************************************************************************/
/* Debug trace macros                                                        */
/*****************************************************************************/
#if (TRC_LEVEL <= 1)
#define TRC_DBG(A, ...) NSLog(@"DEBUG: %s:%d:%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#else
#define TRC_DBG(A, ...)
#endif

#if (TRC_LEVEL <= 2)
#define TRC_NRM(A, ...) NSLog(@"NORMAL:%s:%d:%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#else
#define TRC_NRM(A, ...)
#endif

#if (TRC_LEVEL <= 3)
#define TRC_ALT(A, ...) NSLog(@"ALERT: %s:%d:%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#else
#define TRC_ALT(A, ...)
#endif

#if (TRC_LEVEL <= 4)
#define TRC_ERR(A, ...) NSLog(@"ERROR: %s:%d:%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#else
#define TRC_ERR(A, ...)
#endif

void ILog(id instance);
void ICLog(id instance, Class classType);

NSString *reflect(id instance);
NSString *reflectWithClass(id instance, Class classType);

#endif
