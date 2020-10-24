/*
 * Copyright (C) 10/01/2020 VX STATS <sales@vxstats.com>
 *
 * This document is property of VX STATS. It is strictly prohibited
 * to modify, sell or publish it in any way. In case you have access
 * to this document, you are obligated to ensure its nondisclosure.
 * Noncompliances will be prosecuted.
 *
 * Diese Datei ist Eigentum der VX STATS. Jegliche Änderung, Verkauf
 * oder andere Verbreitung und Veröffentlichung ist strikt untersagt.
 * Falls Sie Zugang zu dieser Datei haben, sind Sie verpflichtet,
 * alles in Ihrer Macht stehende für deren Geheimhaltung zu tun.
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

static Statistics *m_statisticInstance;

@interface Statistics (PrivateMethods)
- (NSString *)coreMessage;
- (void)sendMessage:(NSString *)message;
- (void)addOutstandingMessage:(NSString *)message;
- (void)sendOutstandingMessages;
- (void)updateInterfaceWithReachability:(Reachability *)reachability;
@end

@implementation Statistics

@synthesize lastPageName;

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
- (void)username:(NSString *)username { m_username = username; }
- (void)password:(NSString *)password { m_password = password; }

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

  if ( [lastPageName length] == 0 ) {

    NSLog(@"%s %i: Bad implementation - 'event': '%@' with empty 'pageName'", __PRETTY_FUNCTION__, __LINE__, eventName);
  }

  eventName = [eventName stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
  eventName = [eventName stringByReplacingOccurrencesOfString:@"'" withString:@"%2F'"];
  eventName = [eventName stringByReplacingOccurrencesOfString:@"|" withString:@"%7C"];

  value = [value stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
  value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"%2F'"];
  value = [value stringByReplacingOccurrencesOfString:@"|" withString:@"%7C"];

  NSMutableString *message = [[NSMutableString alloc] init];
  [message appendString:[self coreMessage]];
  if ( [eventName length] > 0 ) {

    [message appendString:[NSString stringWithFormat:@"&action=%@", eventName]];
  }
  if ( [value length] > 0 ) {

    [message appendString:[NSString stringWithFormat:@"&value=%@", value]];
  }
  [self sendMessage:message];
}

- (void)ads:(NSString *)campaign {

  if ( [campaign length] == 0 ) {

    NSLog(@"%s %i: Bad implementation - 'ads' with empty 'campaign' name, pageName: %@", __PRETTY_FUNCTION__, __LINE__, lastPageName);
  }
  else if ( [campaign length] > 255 ) {

    NSLog(@"%s %i: Bad implementation - 'campaign': '%@' is larger than 255 signs", __PRETTY_FUNCTION__, __LINE__, campaign);
    campaign = [campaign substringToIndex:255];
  }
  [self event:@"ads" withValue:campaign];
}

- (void)move:(float)latitude longitude:(float)longitude {

  if ( latitude == 0.0 || longitude == 0.0 ) {

    NSLog(@"%s %i: Bad implementation - 'move' with empty 'latitude' or 'longitude'", __PRETTY_FUNCTION__, __LINE__);
  }
  [self event:@"move" withValue:[NSString stringWithFormat:@"%f,%f", latitude, longitude]];
}

- (void)open:(NSString *)urlOrName {

  if ( [urlOrName length] == 0 ) {

    NSLog(@"%s %i: Bad implementation - 'open' with empty 'urlOrName', pageName: '%@'", __PRETTY_FUNCTION__, __LINE__, lastPageName);
  }
  else if ( [urlOrName length] > 255 ) {

    NSLog(@"%s %i: Bad implementation - 'urlOrName': '%@' is larger than 255 signs", __PRETTY_FUNCTION__, __LINE__, urlOrName);
    urlOrName = [urlOrName substringToIndex:255];
  }
  [self event:@"open" withValue:urlOrName];
}

- (void)play:(NSString *)urlOrName {

  if ( [urlOrName length] == 0 ) {

    NSLog(@"%s %i: Bad implementation - 'play' with empty 'urlOrName', pageName: '%@'", __PRETTY_FUNCTION__, __LINE__, lastPageName);
  }
  else if ( [urlOrName length] > 255 ) {

    NSLog(@"%s %i: Bad implementation - 'urlOrName': '%@' is larger than 255 signs", __PRETTY_FUNCTION__, __LINE__, urlOrName);
    urlOrName = [urlOrName substringToIndex:255];
  }
  [self event:@"play" withValue:urlOrName];
}

- (void)search:(NSString *)text {

  if ( [text length] == 0 ) {

    NSLog(@"%s %i: Bad implementation - 'search' with empty 'text', pageName: '%@'", __PRETTY_FUNCTION__, __LINE__, lastPageName);
  }
  else if ( [text length] > 255 ) {

    NSLog(@"%s %i: Bad implementation - 'text': '%@' is larger than 255 signs", __PRETTY_FUNCTION__, __LINE__, text);
    text = [text substringToIndex:255];
  }
  [self event:@"search" withValue:text];
}

- (void)shake { [self event:@"shake" withValue:nil]; }

- (void)touch:(NSString *)action {

  if ( [action length] == 0 ) {

    NSLog(@"%s %i: Bad implementation - 'touch' with empty 'action', pageName: '%@'", __PRETTY_FUNCTION__, __LINE__, lastPageName);
  }
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
  NSLocale *locale = [NSLocale currentLocale];
  [core appendString:[NSString stringWithFormat:@"language=%@&", [locale objectForKey:NSLocaleLanguageCode]]];
  NSString *country = [locale objectForKey:NSLocaleCountryCode];
  if ( [country length] == 0 ) {

#if TARGET_OS_IPHONE && !(TARGET_OS_WATCH) && !(TARGET_OS_TV)
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_12_1
    CTCarrier *provider = nil;
    NSDictionary<NSString *, CTCarrier *> *providers = [[CTTelephonyNetworkInfo new] serviceSubscriberCellularProviders];
    for ( NSString *key in providers ) {

      provider = providers[key];
      break;
    }
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_12_0
    CTCarrier *provider = nil;
    NSDictionary<NSString *, CTCarrier *> *providers = [[CTTelephonyNetworkInfo new] valueForKey:@"serviceSubscriberCellularProvider"];
    for ( NSString *key in providers ) {

      provider = providers[key];
      break;
    }
#else
    CTCarrier *provider = [[CTTelephonyNetworkInfo new] subscriberCellularProvider];
#endif
    country = provider.isoCountryCode;
#else
    country = @"US";
#endif
  }
  [core appendString:[NSString stringWithFormat:@"country=%@&", country]];

  /* connection - wlan, wan, none */
  [core appendString:[NSString stringWithFormat:@"connection=%@&", m_status]];

  /* radio - */
#if TARGET_OS_IPHONE && !(TARGET_OS_WATCH) && !(TARGET_OS_TV)
  CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_12_1
  NSDictionary<NSString *, NSString *> *radioAccessTechnologies = [telephonyInfo serviceCurrentRadioAccessTechnology];
  NSString *currentRadioAccess = @"";
  for ( NSString *key in radioAccessTechnologies ) {

    currentRadioAccess = radioAccessTechnologies[key];
    break;
  }
  currentRadioAccess = [currentRadioAccess stringByReplacingOccurrencesOfString:@"CTRadioAccessTechnology" withString:@""];
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_12_0
  NSDictionary<NSString *, NSString *> *radioAccessTechnologies = [telephonyInfo valueForKey:@"serviceCurrentRadioAccessTechnology"];
  NSString *currentRadioAccess = @"";
  for ( NSString *key in radioAccessTechnologies ) {

    currentRadioAccess = radioAccessTechnologies[key];
    break;
  }
  currentRadioAccess = [currentRadioAccess stringByReplacingOccurrencesOfString:@"CTRadioAccessTechnology" withString:@""];
#else
  NSString *currentRadioAccess = [telephonyInfo.currentRadioAccessTechnology stringByReplacingOccurrencesOfString:@"CTRadioAccessTechnology" withString:@""];
#endif
  if ( [currentRadioAccess length] == 0 ) {

    currentRadioAccess = @"None";
  }
  if ( ![currentRadioAccess isEqualToString:@"None"] ) {

    [core appendString:[NSString stringWithFormat:@"radio=%@&", currentRadioAccess]];
  }
#endif

  /* app block */
  [core appendString:[NSString stringWithFormat:@"appid=%@&", [App identifier]]];
  [core appendString:[NSString stringWithFormat:@"appversion=%@&", [App version]]];
  if ( [[App build] length] > 0 && ![[App version] isEqualToString:[App build]] ) {

    [core appendString:[NSString stringWithFormat:@"appbuild=%@&", [App build]]];
  }

  /* is this app fairly used? */
  if ( [Device useDarkMode] ) {

    [core appendString:[NSString stringWithFormat:@"dark=%i&", 1]];
  }

  /* is this app fairly used? */
  if ( [App fairUse] ) {

    [core appendString:[NSString stringWithFormat:@"fair=%i&", 1]];
  }

  /* is the device jailbroken? */
  if ( [Device isJailbroken] ) {

    [core appendString:[NSString stringWithFormat:@"free=%i&", 1]];
  }
  /* is the device in tabletmode */
  [core appendString:[NSString stringWithFormat:@"tabletmode=%i&", 1]];
  /* is the device with touch screen */
  [core appendString:[NSString stringWithFormat:@"touch=%i&", 1]];

  /* does the user use voiceover? */
#if TARGET_OS_IPHONE && !(TARGET_OS_WATCH)
  if ( UIAccessibilityIsVoiceOverRunning() ) {

    [core appendString:[NSString stringWithFormat:@"voiceover=%i&", 1]];
  }
#else
  Boolean value = false;
  Boolean result = CFPreferencesGetAppBooleanValue( CFSTR( "voiceOverOnOffKey" ), CFSTR( "com.apple.universalaccess" ), &value );
  if ( value && result ) {

    [core appendString:[NSString stringWithFormat:@"voiceover=%i&", 1]];
  }
#endif

  /* Screen Resolution */
#if TARGET_OS_IPHONE
  [core appendString:[NSString stringWithFormat:@"width=%.0f&", [[UIScreen mainScreen] bounds].size.width]];
  [core appendString:[NSString stringWithFormat:@"height=%.0f&", [[UIScreen mainScreen] bounds].size.height]];
  if ( [[UIScreen mainScreen] scale] != 1.0 ) {

    [core appendString:[NSString stringWithFormat:@"dpr=%.2f&", [[UIScreen mainScreen] scale]]];
  }
#else
  [core appendString:[NSString stringWithFormat:@"width=%.0f&", [[NSScreen mainScreen] frame].size.width]];
  [core appendString:[NSString stringWithFormat:@"height=%.0f&", [[NSScreen mainScreen] frame].size.height]];
  if ( [[NSScreen mainScreen] backingScaleFactor] != 1.0 ) {

    [core appendString:[NSString stringWithFormat:@"dpr=%.2f&", [[NSScreen mainScreen] backingScaleFactor]]];
  }
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

    NSLog(@"%s %i: Bad implementation - 'serverFilePath' is empty - using: 'https://sandbox.vxstats.com'", __PRETTY_FUNCTION__, __LINE__);
    m_serverFilePath = @"https://sandbox.vxstats.com";
  }

  BOOL tracking = YES;
  if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"tracking"] ) {

    tracking = [[NSUserDefaults standardUserDefaults] boolForKey:@"tracking"];
  }

  NSURL *url = [NSURL URLWithString:m_serverFilePath];
  if ( tracking && url ) {

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[message dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *session = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

#pragma unused(data)
      if ( response == nil || error != nil ) {

#ifdef DEBUG
        NSLog(@"%s %i: Request failed with error: '%@'", __PRETTY_FUNCTION__, __LINE__, error);
#endif
        [self addOutstandingMessage:message];
      }
    }];
    [session resume];
  }
  else {

    [self addOutstandingMessage:message];
  }
}

- (void)addOutstandingMessage:(NSString *)message {

  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.vxstats.statistics"];
  /* add to queue */
  NSArray *existingMessages = [userDefaults objectForKey:@"offline"];
  NSMutableArray *messages = [NSMutableArray alloc];
  if ( existingMessages != nil ) {

    [messages addObjectsFromArray:existingMessages];
  }
  [messages addObject:message];
  [userDefaults setObject:messages forKey:@"offline"];
  [userDefaults synchronize];
}

- (void)sendOutstandingMessages {

  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.vxstats.statistics"];
  NSArray *messages = [userDefaults objectForKey:@"offline"];
  [userDefaults removeObjectForKey:@"offline"];
  [userDefaults synchronize];
  for ( NSUInteger x = 0; x < [messages count]; ++x ) {

    [self sendMessage:[messages objectAtIndex:x]];
  }
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
    else {

      m_status = @"Offline";
    }
  }
}

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification *)notification {

  Reachability *reachability = [notification object];
  [self updateInterfaceWithReachability:reachability];
}

#pragma mark - NSURLSession delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {

  NSString *authMethod = [[challenge protectionSpace] authenticationMethod];
  if ([authMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {

    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
  }
  else {

    if ( m_username == nil || m_password == nil ) {

      NSLog(@"%s %i: Authentication not possible, username or password empty.", __PRETTY_FUNCTION__, __LINE__);
      return;
    }
    NSURLCredential *credential = [NSURLCredential credentialWithUser:m_username password:m_password persistence:NSURLCredentialPersistencePermanent];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
  }
}

#pragma mark - Statistics instance

+ (Statistics *)instance {

  if ( m_statisticInstance == nil ) {

    m_statisticInstance = [[Statistics alloc] init];
  }
  return m_statisticInstance;
}

@end
