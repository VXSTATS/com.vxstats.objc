/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>

#import <CoreFoundation/CoreFoundation.h>

#import "Reachability.h"

#pragma mark IPv6 Support
//Reachability fully support IPv6.  For full details, see ReadMe.md.


NSString *kReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";


#pragma mark - Supporting functions

#define kShouldPrintReachabilityFlags 0

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)
{
#if kShouldPrintReachabilityFlags

    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)        ? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',

          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#else
#pragma unused(flags)
#pragma unused(comment)
#endif
}


static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
  NSCAssert(info != nil, @"info was nil in ReachabilityCallback");
  NSCAssert([(__bridge NSObject*) info isKindOfClass: [Reachability class]], @"info was wrong class in ReachabilityCallback");

    Reachability* noteObject = (__bridge Reachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];
}


#pragma mark - Reachability implementation

@implementation Reachability
{
  SCNetworkReachabilityRef _reachabilityRef;
}

+ (instancetype)reachabilityWithHostName:(NSString *)hostName
{
  Reachability* returnValue = nil;
  const char *host = [hostName UTF8String];
  if (host == nil) {
    
    return returnValue;
  }
  SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(nil, host);
  if (reachability != nil)
  {
    returnValue= [[self alloc] init];
    if (returnValue != nil)
    {
      returnValue->_reachabilityRef = reachability;
    }
        else {
            CFRelease(reachability);
        }
  }
  return returnValue;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress
{
  SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);

  Reachability* returnValue = nil;
  if (reachability != nil)
  {
    returnValue = [[self alloc] init];
    if (returnValue != nil)
    {
      returnValue->_reachabilityRef = reachability;
    }
        else {
            CFRelease(reachability);
        }
  }
  return returnValue;
}


+ (instancetype)reachabilityForInternetConnection
{
  struct sockaddr_in zeroAddress = { 0 };
  zeroAddress.sin_len = sizeof(zeroAddress);
  zeroAddress.sin_family = AF_INET;

  return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}


#pragma mark - Start and stop notifier

- (BOOL)startNotifier
{
  BOOL returnValue = NO;
  SCNetworkReachabilityContext context = {0, (__bridge void *)(self), nil, nil, nil};

  if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context))
  {
    if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
    {
      returnValue = YES;
    }
  }

  return returnValue;
}


- (void)stopNotifier
{
  if (_reachabilityRef != nil)
  {
    SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
  }
}


- (void)dealloc
{
  [self stopNotifier];
  if (_reachabilityRef != nil)
  {
    CFRelease(_reachabilityRef);
  }
}


#pragma mark - Network Flag Handling

- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
  PrintReachabilityFlags(flags, "networkStatusForFlags");
  if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
  {
    // The target host is not reachable.
    return NotReachable;
  }

    NetworkStatus returnValue = NotReachable;

  if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
  {
    /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
    returnValue = ReachableViaWiFi;
  }

  if ((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0 ||
      (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)
  {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = ReachableViaWiFi;
        }
    }

  #if TARGET_OS_IPHONE
  if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
  {
    /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
    returnValue = ReachableViaWWAN;
  }
  #endif

  return returnValue;
}


- (BOOL)connectionRequired
{
  NSAssert(_reachabilityRef != nil, @"connectionRequired called with nil reachabilityRef");
  SCNetworkReachabilityFlags flags;

  if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
  {
    return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
  }

    return NO;
}


- (NetworkStatus)currentReachabilityStatus
{
  NSAssert(_reachabilityRef != nil, @"currentNetworkStatus called with nil SCNetworkReachabilityRef");
  NetworkStatus returnValue = NotReachable;
  SCNetworkReachabilityFlags flags;

  if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
  {
        returnValue = [self networkStatusForFlags:flags];
  }

  return returnValue;
}


@end
