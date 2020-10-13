/*
 * Copyright (C) 10/01/2020 VX APPS <sales@vxapps.com>
 *
 * This document is property of VX APPS. It is strictly prohibited
 * to modify, sell or publish it in any way. In case you have access
 * to this document, you are obligated to ensure its nondisclosure.
 * Noncompliances will be prosecuted.
 *
 * Diese Datei ist Eigentum der VX APPS. Jegliche Änderung, Verkauf
 * oder andere Verbreitung und Veröffentlichung ist strikt untersagt.
 * Falls Sie Zugang zu dieser Datei haben, sind Sie verpflichtet,
 * alles in Ihrer Macht stehende für deren Geheimhaltung zu tun.
 * Zuwiderhandlungen werden strafrechtlich verfolgt.
 */

/* modules */
@import Foundation;

/**
 * @~english
 * @brief The Device class.
 * Delivers information about current device.
 *
 * @~german
 * @brief Die Klasse Device.
 * Liefert Informationen zum aktuellen Gerät.
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
   * @brief The unique device identifier.
   *
   * @~german
   * @brief Die eindeutige Id des Geräts.
   */
  NSString *m_uniqueIdentifier;
}

/**
 * @~english
 * @brief Returns true, if the device run in dark mode.
 * @return True, if the device run in dark mode - otherwise false.
 *
 * @~german
 * @brief Gibt wahr zurück, wenn die Plattform den Darkmode verwendet.
 * @return Wahr, wenn die Plattform den Darkmode verwendet - sonst falsch.
 */
+ (BOOL)useDarkMode;

/**
 * @~english
 * @brief Returns true, if the device is jailbroken - otherwiese false.
 * @return True, if the device is jailbroken - otherweise false.
 *
 * @~german
 * @brief Gibt wahr zurück, wenn das Gerät gejailbreakt ist - sonst falsch.
 * @return Wahr, wenn das Gerät gejailbreakt ist - sonst falsch.
 */
+ (BOOL)isJailbroken;

/**
 * @~english
 * @brief Returns the internal string for the platform.
 * @return The internal string for the platform.
 *
 * @~german
 * @brief Gibt den internen String für die Plattform zurück.
 * @return Der interne String für die Plattform.
 */
- (NSString *)platformString;

/**
 * @~english
 * @brief Returns the device model. E.g. iPhone
 * @return The device model.
 *
 * @~german
 * @brief Gibt das Gerätemodell zurück. Bsp.: iPhone
 * @return Das Gerätemodell.
 */
- (NSString *)model;

/**
 * @~english
 * @brief Returns the device version. E.g. 8,1
 * @return The device version.
 *
 * @~english
 * @brief Gibt die Geräteversion zurück. Bsp.: 8,1
 * @return Die Geräteversion.
 */
- (NSString *)version;

/**
 * @~english
 * @brief Returns the name of the operating system, e.g. iOS
 * @return The name of the operating system.
 *
 * @~german
 * @brief Gibt den Namen des Betriebssystems zurück, z.B. iOS
 * @return Der Name des Betriebssystems.
 */
+ (NSString *)osName;

/**
 * @~english
 * @brief Returns the version of the operating system, e.g. 9.3.3
 * @return The version of the operating system.
 *
 * @~german
 * @brief Gibt die Version des Betriebssystems zurück, z.B. 9.3.3
 * @return Die Version des Betriebssystems.
 */
+ (NSString *)osVersion;

/**
 * @~english
 * @brief Unique identifier for current device.
 * @return The unique identifier for the current device.
 *
 * @~german
 * @brief Eindeutige Id des Geräts.
 * @return Eindeutige Id des Geräts.
 */
- (NSString *)uniqueIdentifier;

/**
 * @~english
 * @brief Instance of Device. C++11 Singleton thread-safe.
 * @return Singleton of Device.
 *
 * @~german
 * @brief Instanz von Device.
 * @return Einzige Instanz von Device.
 */
+ (Device *)currentDevice;

@end
