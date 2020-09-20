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

/* openssl header */
#include <openssl/pkcs7.h>
#include <openssl/objects.h>
#include <openssl/sha.h>
#include <openssl/x509.h>
#include <openssl/err.h>

/* local header */
#import "App.h"

@implementation App

static App *m_appInstance;

- (id)init {

  if ( ( self = [super init] ) ) {

    ;
  }
  return self;
}

+ (BOOL)fairUse {

  NSBundle *mainBundle = [NSBundle mainBundle];
  NSURL *receiptURL = [mainBundle appStoreReceiptURL];
  NSError *receiptError;
  BOOL isPresent = [receiptURL checkResourceIsReachableAndReturnError:&receiptError];
  if ( !isPresent ) {

    return NO;
  }

  /* Load the receipt file */
  NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];

  /* Create a memory buffer to extract the PKCS #7 container */
  BIO *receiptBIO = BIO_new(BIO_s_mem());
  BIO_write(receiptBIO, [receiptData bytes], (int)[receiptData length]);
  PKCS7 *receiptPKCS7 = d2i_PKCS7_bio(receiptBIO, NULL);
  if (!receiptPKCS7) {

    return NO;
  }

  /* Check that the container has a signature */
  if ( !PKCS7_type_is_signed(receiptPKCS7) ) {

    return NO;
  }

  /* Check that the signed container has actual data */
  if ( !PKCS7_type_is_data(receiptPKCS7->d.sign->contents) ) {

    return NO;
  }
  /* Load the Apple Root CA (downloaded from https://www.apple.com/certificateauthority/) */
  NSURL *appleRootURL = [[NSBundle mainBundle] URLForResource:@"AppleIncRootCertificate" withExtension:@"cer"];
  NSData *appleRootData = [NSData dataWithContentsOfURL:appleRootURL];
  BIO *appleRootBIO = BIO_new(BIO_s_mem());
  BIO_write(appleRootBIO, (const void *)[appleRootData bytes], (int)[appleRootData length]);
  X509 *appleRootX509 = d2i_X509_bio(appleRootBIO, NULL);

  /* Create a certificate store */
  X509_STORE *store = X509_STORE_new();
  X509_STORE_add_cert(store, appleRootX509);

  /* Be sure to load the digests before the verification */
  OpenSSL_add_all_digests();

  /* Check the signature */
  int result = PKCS7_verify(receiptPKCS7, NULL, store, NULL, NULL, 0);
  if ( result != 1 ) {

    return NO;
  }
  return YES;
}

+ (NSString *)name { return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleExecutableKey]; }
+ (NSString *)version { return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]; }
+ (NSString *)build { return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]; }
+ (NSString *)identifier { return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey]; }

+ (App *)currentApp {

  if ( m_appInstance == nil )
    m_appInstance = [[App alloc] init];
  return m_appInstance;
}

@end
