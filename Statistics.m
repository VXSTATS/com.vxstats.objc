/*
 * Copyright (C) 01/10/2020 VX APPS <sales@vxapps.com>
 *
 * The ownership of this document rests with the VX APPS. It is
 * strictly prohibited to change, sell or publish it in any way. In case
 * you have access to this document, you are obligated to ensure its
 * nondisclosure. Noncompliances will be prosecuted.
 *
 * Diese Datei ist Eigentum der VX APPS. Ändern, verkaufen oder
 * auf eine andere Weise verbreiten und öffentlich machen ist strikt
 * untersagt. Falls Sie Zugang zu dieser Datei haben, sind Sie
 * verpflichtet alles Mögliche für deren Geheimhaltung zu tun.
 * Zuwiderhandlungen werden strafrechtlich verfolgt.
 */

/* local header */
#import "App.h"
#import "Device.h"
#import "Reachability.h"
#import "Statistics.h"

/* modules */
#if TARGET_OS_MAC && !(TARGET_OS_IPHONE)
@import AppKit;
#endif
#if TARGET_OS_IPHONE && !(TARGET_OS_WATCH) && !(TARGET_OS_TV)
@import CoreTelephony;
@import UIKit;
#endif

@interface Statistics (PrivateMethods)
- (NSString *)coreMessage;
- (void)sendMessage:(NSString *)message;
- (void)addOutstandingMessage:(NSString *)message;
- (void)sendOutstandingMessages;
- (void)updateInterfaceWithReachability:(Reachability *)reachability;
@end

@implementation Statistics

@synthesize lastPageName;

static Statistics *m_statisticInstance;

#pragma mark - Life cycle

- (id)init {

  m_status = @"Offline";
  m_serverFilePath = nil;
  lastPageName = nil;
  m_lastMessage = nil;

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

  m_reachability = [Reachability reachabilityForInternetConnection];
  [m_reachability startNotifier];
  [self updateInterfaceWithReachability:m_reachability];

  return self;
}

- (void)manualUpdate { [self updateInterfaceWithReachability:m_reachability]; }
- (void)serverFilePath:(NSString *)serverFilePath { m_serverFilePath = serverFilePath; }

- (void)page:(NSString *)pageName {

  if ( [pageName length] == 0 ) {

    NSLog(@"%s %i: Bad implementation - page with empty 'pageName'", __PRETTY_FUNCTION__, __LINE__);
    return;
  }
  else if ( [pageName length] > 255 ) {

    NSLog(@"%s %i: Bad implementation - 'pageName': '%@' is larger than 255 signs", __PRETTY_FUNCTION__, __LINE__, pageName);
    pageName = [pageName substringToIndex:255];
  }

  pageName = [pageName stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
  pageName = [pageName stringByReplacingOccurrencesOfString:@"'" withString:@"%2F'"];
  pageName = [pageName stringByReplacingOccurrencesOfString:@"|" withString:@"%7C"];

  NSString *tmpString = [pageName copy];
  lastPageName = tmpString;

  [self event:nil withValue:nil];
}

- (void)event:(NSString *)eventName withValue:(NSString *)value {

  if ( [lastPageName length] == 0 )
    NSLog(@"%s %i: Bad implementation - 'event': '%@' with empty 'pageName'", __PRETTY_FUNCTION__, __LINE__, eventName);

  eventName = [eventName stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
  eventName = [eventName stringByReplacingOccurrencesOfString:@"'" withString:@"%2F'"];
  eventName = [eventName stringByReplacingOccurrencesOfString:@"|" withString:@"%7C"];

  value = [value stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
  value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"%2F'"];
  value = [value stringByReplacingOccurrencesOfString:@"|" withString:@"%7C"];

  NSMutableString *message = [[NSMutableString alloc] init];
  [message appendString:[self coreMessage]];
  if ( [eventName length] > 0 )
    [message appendString:[NSString stringWithFormat:@"&action=%@", eventName]];
  if ( [value length] > 0 )
    [message appendString:[NSString stringWithFormat:@"&value=%@", value]];
  [self sendMessage:message];
}

- (void)ads:(NSString *)campaign {

  if ( [campaign length] == 0 )
    NSLog(@"%s %i: Bad implementation - 'ads' with empty 'campaign' name, pageName: %@", __PRETTY_FUNCTION__, __LINE__, lastPageName);
  else if ( [campaign length] > 255 ) {

    NSLog(@"%s %i: Bad implementation - 'campaign': '%@' is larger than 255 signs", __PRETTY_FUNCTION__, __LINE__, campaign);
    campaign = [campaign substringToIndex:255];
  }
  [self event:@"ads" withValue:campaign];
}

- (void)move:(float)latitude longitude:(float)longitude {

  if ( latitude == 0.0 || longitude == 0.0 )
    NSLog(@"%s %i: Bad implementation - 'move' with empty 'latitude' or 'longitude'", __PRETTY_FUNCTION__, __LINE__);
  [self event:@"move" withValue:[NSString stringWithFormat:@"%f,%f", latitude, longitude]];
}

- (void)open:(NSString *)urlOrName {

  if ( [urlOrName length] == 0 )
    NSLog(@"%s %i: Bad implementation - 'open' with empty 'urlOrName', pageName: '%@'", __PRETTY_FUNCTION__, __LINE__, lastPageName);
  else if ( [urlOrName length] > 255 ) {

    NSLog(@"%s %i: Bad implementation - 'urlOrName': '%@' is larger than 255 signs", __PRETTY_FUNCTION__, __LINE__, urlOrName);
    urlOrName = [urlOrName substringToIndex:255];
  }
  [self event:@"open" withValue:urlOrName];
}

- (void)play:(NSString *)urlOrName {

  if ( [urlOrName length] == 0 )
    NSLog(@"%s %i: Bad implementation - 'play' with empty 'urlOrName', pageName: '%@'", __PRETTY_FUNCTION__, __LINE__, lastPageName);
  else if ( [urlOrName length] > 255 ) {

    NSLog(@"%s %i: Bad implementation - 'urlOrName': '%@' is larger than 255 signs", __PRETTY_FUNCTION__, __LINE__, urlOrName);
    urlOrName = [urlOrName substringToIndex:255];
  }
  [self event:@"play" withValue:urlOrName];
}

- (void)search:(NSString *)text {

  if ( [text length] == 0 )
    NSLog(@"%s %i: Bad implementation - 'search' with empty 'text', pageName: '%@'", __PRETTY_FUNCTION__, __LINE__, lastPageName);
  else if ( [text length] > 255 ) {

    NSLog(@"%s %i: Bad implementation - 'text': '%@' is larger than 255 signs", __PRETTY_FUNCTION__, __LINE__, text);
    text = [text substringToIndex:255];
  }
  [self event:@"search" withValue:text];
}

- (void)shake { [self event:@"shake" withValue:nil]; }

- (void)touch:(NSString *)action {

  if ( [action length] == 0 )
    NSLog(@"%s %i: Bad implementation - 'touch' with empty 'action', pageName: '%@'", __PRETTY_FUNCTION__, __LINE__, lastPageName);
  else if ( [action length] > 255 ) {

    NSLog(@"%s %i: Bad implementation - 'action': '%@' is larger than 255 signs", __PRETTY_FUNCTION__, __LINE__, action);
    action = [action substringToIndex:255];
  }
  [self event:@"touch" withValue:action];
}

- (NSString *)coreMessage {

  NSMutableString *core = [[NSMutableString alloc] init];
  /* device block */
  [core appendString:[NSString stringWithFormat:@"uuid=%@&", [[Device currentDevice] uniqueIdentifier]]];
  [core appendString:[NSString stringWithFormat:@"os=%@&", [Device osName]]];
  [core appendString:[NSString stringWithFormat:@"osversion=%@&", [Device osVersion]]];
  [core appendString:[NSString stringWithFormat:@"model=%@&", [[Device currentDevice] model]]];
  [core appendString:[NSString stringWithFormat:@"modelversion=%@&", [[Device currentDevice] version]]];
  [core appendString:[NSString stringWithFormat:@"vendor=%@&", @"Apple Inc."]];

  /* locale */
  [core appendString:[NSString stringWithFormat:@"language=%@&", [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]]];
  [core appendString:[NSString stringWithFormat:@"country=%@&", [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]]];

  /* connection - wlan, wan, none */
  [core appendString:[NSString stringWithFormat:@"connection=%@&", m_status]];

  /* radio - */
  #if TARGET_OS_IPHONE && !(TARGET_OS_WATCH) && !(TARGET_OS_TV)
//  CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
//  NSString *currentRadioAccess = [telephonyInfo.currentRadioAccessTechnology stringByReplacingOccurrencesOfString:@"CTRadioAccessTechnology" withString:@""];
//  if ( [currentRadioAccess length] == 0 )
//    currentRadioAccess = @"None";
//  if ( ![currentRadioAccess isEqualToString:@"None"] )
//    [core appendString:[NSString stringWithFormat:@"radio=%@&", currentRadioAccess]];
  #endif

  /* app block */
  [core appendString:[NSString stringWithFormat:@"appid=%@&", [App identifier]]];
  [core appendString:[NSString stringWithFormat:@"appversion=%@&", [App version]]];
  if ( [[App build] length] > 0 && ![[App version] isEqualToString:[App build]] )
    [core appendString:[NSString stringWithFormat:@"appbuild=%@&", [App build]]];

  /* is this app fairly used? */
  if ( [App fairUse] )
    [core appendString:[NSString stringWithFormat:@"fair=%i&", 1]];

  /* is the device jailbroken? */
  if ( [Device isJailbroken] )
    [core appendString:[NSString stringWithFormat:@"free=%i&", 1]];
  /* is the device in tabletmode */
  [core appendString:[NSString stringWithFormat:@"tabletmode=%i&", 1]];
  /* is the device with touch screen */
  [core appendString:[NSString stringWithFormat:@"touch=%i&", 1]];

  /* does the user use voiceover? */
  #if TARGET_OS_IPHONE && !(TARGET_OS_WATCH)
  if ( UIAccessibilityIsVoiceOverRunning() )
  #else
  Boolean value = false;
  Boolean result = CFPreferencesGetAppBooleanValue( CFSTR( "voiceOverOnOffKey" ), CFSTR( "com.apple.universalaccess" ), &value );
  if ( value && result )
  #endif
    [core appendString:[NSString stringWithFormat:@"voiceover=%i&", 1]];

  /* Screen Resolution */
  #if TARGET_OS_IPHONE
  [core appendString:[NSString stringWithFormat:@"width=%.0f&", [[UIScreen mainScreen] bounds].size.width]];
  [core appendString:[NSString stringWithFormat:@"height=%.0f&", [[UIScreen mainScreen] bounds].size.height]];
  if ( [[UIScreen mainScreen] scale] != 1.0 )
    [core appendString:[NSString stringWithFormat:@"dpr=%.2f&", [[UIScreen mainScreen] scale]]];
  #else
  [core appendString:[NSString stringWithFormat:@"width=%.0f&", [[NSScreen mainScreen] frame].size.width]];
  [core appendString:[NSString stringWithFormat:@"height=%.0f&", [[NSScreen mainScreen] frame].size.height]];
  if ( [[NSScreen mainScreen] backingScaleFactor] != 1.0 )
    [core appendString:[NSString stringWithFormat:@"dpr=%.2f&", [[NSScreen mainScreen] backingScaleFactor]]];
  #endif

  /* time block */
  [core appendString:[NSString stringWithFormat:@"created=%.0f&", [[NSDate date] timeIntervalSince1970]]];

  /* data block */
  [core appendString:[NSString stringWithFormat:@"page=%@", lastPageName]];
  return core;
}

- (void)sendMessage:(NSString *)message {

  if ( [message length] == 0 ) {

    NSLog(@"%s %i: Bad implementation - 'message' is empty", __PRETTY_FUNCTION__, __LINE__);
    return;
  }

  if ( [m_serverFilePath length] == 0 ) {

    NSLog(@"%s %i: Bad implementation - 'serverFilePath' is empty", __PRETTY_FUNCTION__, __LINE__);
    return;
  }

  BOOL tracking = YES;
  if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"tracking"] )
    tracking = [[NSUserDefaults standardUserDefaults] boolForKey:@"tracking"];
  if ( tracking ) {

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:m_serverFilePath]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[message dataUsingEncoding:NSUTF8StringEncoding]];

    if ( [NSThread isMainThread] ) {

      m_lastMessage = message;
      [NSURLConnection connectionWithRequest:request delegate:self];
    }
    else {

      NSError *error = nil;
      NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
      if ( response == nil || error != nil ) {

        #ifdef DEBUG
        NSLog(@"%s %i: Synchronous connection (not in main thread) failed with error: '%@'", __PRETTY_FUNCTION__, __LINE__, error);
        #endif
        [self addOutstandingMessage:message];
      }
    }
  }
  else
    [self addOutstandingMessage:message];
}

- (void)addOutstandingMessage:(NSString *)message {

  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.vx.statistics"];
  /* add to queue */
  NSMutableArray *messages = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"offline"]];
  [messages addObject:message];
  [userDefaults setObject:messages forKey:@"offline"];
  [userDefaults synchronize];
}

- (void)sendOutstandingMessages {

  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.vx.statistics"];
  NSArray *messages = [userDefaults objectForKey:@"offline"];
  [userDefaults removeObjectForKey:@"offline"];
  [userDefaults synchronize];
  for ( NSUInteger x = 0; x < [messages count]; ++x )
    [self sendMessage:[messages objectAtIndex:x]];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability {

  if ( reachability == m_reachability ) {

    if ( [reachability currentReachabilityStatus] == ReachableViaWiFi ) {

      [self sendOutstandingMessages];
      m_status = @"Wifi";
    }
    else if ( [reachability currentReachabilityStatus] == ReachableViaWWAN ) {

      [self sendOutstandingMessages];
      m_status = @"WWAN";
    }
    else
      m_status = @"Offline";
  }
}

- (void)reachabilityChanged:(NSNotification *)notification {

  Reachability *reachability = [notification object];
  [self updateInterfaceWithReachability:reachability];
}

#pragma mark - URLConnection delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

  #ifdef DEBUG
  NSLog(@"%s %i: Asynchronous connection (run in main thread) failed with error: %@ %@", __PRETTY_FUNCTION__, __LINE__, error, connection);
  #endif
  [self addOutstandingMessage:m_lastMessage];
}

#pragma mark - Statistics instance

+ (Statistics *)instance {

  if ( m_statisticInstance == nil )
    m_statisticInstance = [[Statistics alloc] init];
  return m_statisticInstance;
}

@end
