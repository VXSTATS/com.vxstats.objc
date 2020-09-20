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

/* sys header */
#include <sys/sysctl.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>

/* objc header */
#import <CommonCrypto/CommonDigest.h>

/* local header */
#import "Device.h"

/* modules */
@import Foundation;
#if TARGET_OS_IPHONE
@import UIKit;
#endif

@interface Device (PrivateMethods)
- (NSString *)firstMacAddress;
@end

@implementation Device

static Device *m_deviceInstance;

- (id)init {

  if ( ( self = [super init] ) ) {

    /* check for system */
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    m_platform = platform;

    /* calculate unique id or read from settings */
    NSString *address = [self firstMacAddress];
    if ( address.length <= 0 || address.length > 17 || [address isEqualToString:@"00:00:00:00:00:00"] || [address isEqualToString:@"02:00:00:00:00:00"] ) {

      NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.vx.statistics"];
      NSString *uuid = [userDefaults objectForKey:@"uuid"];
      if ( uuid == nil ) {

        uuid = [[NSUUID UUID] UUIDString];
        [userDefaults setObject:uuid forKey:@"uuid"];
        [userDefaults synchronize];
      }
      m_uniqueIdentifier = uuid;
    }
    else {

      /* Create pointer to the string as UTF8 */
      const char *ptr = [address UTF8String];

      /* Create byte array of unsigned chars */
      unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

      /* Create 16 byte MD5 hash value, store in buffer */
      CC_MD5(ptr, ( unsigned int )strlen(ptr), md5Buffer);

      /* Convert MD5 value in the buffer to NSString of hex values */
      NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
      for ( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ )
        [output appendFormat:@"%02x", md5Buffer[i]];

      m_uniqueIdentifier = [NSString stringWithFormat:@"%@-%@-%@-%@-%@", [output substringWithRange:NSMakeRange(0, 8)], [output substringWithRange:NSMakeRange(8, 4)], [output substringWithRange:NSMakeRange(12, 4)], [output substringWithRange:NSMakeRange(16, 4)], [output substringWithRange:NSMakeRange(20, 12)]];
    }
  }
  return self;
}

#pragma mark - Hacked

+ (BOOL)isJailbroken {

  #if TARGET_OS_IPHONE && !(TARGET_IPHONE_SIMULATOR)
  if ( [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] )
    return YES;
  else if ( [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] )
    return YES;
  else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"] )
    return YES;
  else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"] )
    return YES;
  else if ( [[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"] )
    return YES;

  NSError *error;
  NSString *stringToBeWritten = @"This is a test.";
  [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
  if ( error == nil )
    /* Device is jailbroken */
    return YES;
  else
    [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];

  /* This will not work until you handle correct ATS, but this created warnings, so this is not save enought to use */
//  if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]] )
//    /* Device is jailbroken */
//    return YES;
  #endif

  /* All checks have failed. Most probably, the device is not jailbroken */
  return NO;
}

#pragma mark - Info

- (NSString *)platformString { return m_platform; }

#pragma mark - Global info

- (NSString *)model {

  #if TARGET_IPHONE_SIMULATOR
  return @"iOS Simulator";
  #else
  NSString *platform = m_platform;
  NSRange range = [platform rangeOfString:@","];
  NSInteger versionBegin = range.location;
  if ( versionBegin > 1 ) {

    unichar chr = [platform characterAtIndex:versionBegin - 1];
    if ( chr >= '0' && chr <= '9' )
      --versionBegin;
  }
  if ( versionBegin > 1 ) {

    unichar chr = [platform characterAtIndex:versionBegin - 1];
    if ( chr >= '0' && chr <= '9' )
      --versionBegin;
  }
  return [platform substringWithRange:NSMakeRange(0, versionBegin)];
  #endif
}

- (NSString *)version {

  NSString *platform = m_platform;
  #if TARGET_IPHONE_SIMULATOR
  return platform;
  #else
  NSRange range = [platform rangeOfString:@","];
  NSInteger versionBegin = range.location;
  if ( versionBegin > 1 ) {

    unichar chr = [platform characterAtIndex:versionBegin - 1];
    if ( chr >= '0' && chr <= '9' )
      --versionBegin;
  }
  if ( versionBegin > 1 ) {

    unichar chr = [platform characterAtIndex:versionBegin - 1];
    if ( chr >= '0' && chr <= '9' )
      --versionBegin;
  }

  return [platform substringWithRange:NSMakeRange(versionBegin, [platform length] - versionBegin)];
  #endif
}

+ (NSString *)osName {

  #if TARGET_OS_MAC && !(TARGET_OS_IPHONE)
  return @"macOS";
  #endif
  #if TARGET_OS_IPHONE
  return @"iOS";
  #endif
  #if TARGET_OS_WATCH
  return @"watchOS";
  #endif
  #if TARGET_OS_TV
  return @"tvOS";
  #endif
}

+ (NSString *)osVersion {

  NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
  return [NSString stringWithFormat:@"%zd.%zd.%zd", version.majorVersion, version.minorVersion, version.patchVersion];
}

- (NSString *)firstMacAddress {

  int mgmtInfoBase[6];
  char *msgBuffer = nil;
  size_t length;
  unsigned char macAddress[6];
  struct if_msghdr *interfaceMsgStruct;
  struct sockaddr_dl *socketStruct;
  NSString *errorFlag = nil;

  /* Setup the management Information Base (mib) */
  mgmtInfoBase[0] = CTL_NET; /* Request network subsystem */
  mgmtInfoBase[1] = AF_ROUTE; /* Routing table info */
  mgmtInfoBase[2] = 0;
  mgmtInfoBase[3] = AF_LINK; /* Request link layer information */
  mgmtInfoBase[4] = NET_RT_IFLIST; /* Request all configured interfaces */

  /* With all configured interfaces requested, get handle index */
  if ( ( mgmtInfoBase[5] = if_nametoindex( "en0" ) ) == 0)
    errorFlag = @"if_nametoindex failure";
  else {

    /* Get the size of the data available (store in len) */
    if ( sysctl( mgmtInfoBase, 6, NULL, &length, NULL, 0 ) < 0 )
      errorFlag = @"sysctl mgmtInfoBase failure";
    else {

      /* Alloc memory based on above call */
      if ( ( msgBuffer = malloc( length ) ) == NULL )
        errorFlag = @"buffer allocation failure";
      else {

        /* Get system information, store in buffer */
        if ( sysctl( mgmtInfoBase, 6, msgBuffer, &length, NULL, 0 ) < 0 )
          errorFlag = @"sysctl msgBuffer failure";
      }
    }
  }

  /* Befor going any further... */
  if ( errorFlag.length > 0 ) {

    #ifdef DEBUG
    NSLog(@"Error: %@", errorFlag);
    #endif
    return nil;
  }

  /* Map msgbuffer to interface message structure */
  interfaceMsgStruct = (struct if_msghdr *) msgBuffer;

  /* Map to link-level socket structure */
  socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);

  /* Copy link layer address data in socket structure to an array */
  memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);

  /* Read from char array into a string object, into traditional Mac address format */
  NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
  #ifdef DEBUG
//  NSLog(@"Mac Address: %@", macAddressString);
  #endif

  /* Release the buffer memory */
  free(msgBuffer);

  return macAddressString;
}

- (NSString *)uniqueIdentifier {

  return m_uniqueIdentifier;
}

#pragma mark - Instance

+ (Device *)currentDevice {

  if ( m_deviceInstance == nil )
    m_deviceInstance = [[Device alloc] init];
  return m_deviceInstance;
}

@end
