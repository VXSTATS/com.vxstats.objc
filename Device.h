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

/* modules */
@import Foundation;

/**
 * @~english
 * @brief Information of the device.
 *
 * @~german
 * @brief Informationen über das Gerät.
 */
@interface Device : NSObject {

@private
  /**
   * @~english
   * @brief Internal description of the platform.
   *
   * @~german
   * @brief Interne Bezeichnung der Plattform.
   */
  NSString *m_platform;

  /**
   * @~english
   * @brief The device unique identifier.
   *
   * @~german
   * @brief Die eindeutige Id des Gerätes.
   */
  NSString *m_uniqueIdentifier;
}

/**
 * @~english
 * @brief Has the device been jailbroken?
 * @return True, if the device is jailbroken - otherwise false.
 *
 * @~german
 * @brief Wurde das Gerät gejailbreakt?
 * @return Wahr, wenn das Gerät gejailbreakt wurde - sonst falsch.
 */
+ (BOOL)isJailbroken;

/**
 * @~english
 * @brief The internal string for the platform.
 * @return The internal string for the platform.
 *
 * @~german
 * @brief Der interne String für die Plattform.
 * @return Der interne String für die Plattform.
 */
- (NSString *)platformString;

/**
 * @~english
 * @brief The device, e.g. iPhone.
 * @return The device.
 *
 * @~german
 * @brief Das Gerät, z.B. iPhone.
 * @return Das Gerät.
 */
- (NSString *)model;

/**
 * @~english
 * @brief The version of the device, e.g. 8,1.
 * @return The version of the device.
 *
 * @~german
 * @brief Die Version des Gerätes, z.B. 8,1
 * @brief Die Version des Gerätes.
 */
- (NSString *)version;

/**
 * @~english
 * @brief The name of the operating system, e.g. iOS
 * @return The name of the operating system.
 *
 * @~german
 * @brief Der Name des Betriebssystems, z.B. iOS
 * @return Der Name des Betriebssystems.
 */
+ (NSString *)osName;

/**
 * @~english
 * @brief The version of the operating system, e.g. 9.3.3
 * @return The version of the operating system.
 *
 * @~german
 * @brief Die Version des Betriebssystems, z.B. 9.3.3
 * @return Die Version des Betriebssystems.
 */
+ (NSString *)osVersion;

/**
 * @~english
 * @brief An unique ID of the device, also known as MD5 over network address or
 * one time generated uuid.
 * @return An unique ID of the device.
 *
 * @~german
 * @brief Eine eindeutige ID des Gerätes oder auch bekannt als MD5 der Mac
 * Adresse oder einamlig generierte UUID.
 * @return Eine eindeutige ID des Gerätes.
 */
- (NSString *)uniqueIdentifier;

/**
 * @~english
 * @brief Object for the current device.
 * @return The instance for the current device.
 *
 * @~german
 * @brief Objekt für das aktuelle Gerät.
 * @return Die Instanz für das aktuelle Gerät.
 */
+ (Device *)currentDevice;

@end
