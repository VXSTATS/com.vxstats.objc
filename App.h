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

/* modules */
@import Foundation;

/**
 * @~english
 * @brief The App class.
 * General information about the running app including validation of fair use.
 *
 * @~german
 * @brief Die Klasse App.
 * Bietet allgemeine Informationen über die Anwendung und eine Überprüfung
 * der fairen Verwendung.
 */
@interface App : NSObject {}

/**
 * @~english
 * @brief Returns true, if the app is fairly used.
 * @return True, if the app is fairly used - otherwise false.
 *
 * @~german
 * @brief Gibt wahr zurück, wenn die Anwendung fair verwendet wird.
 * @return Wahr, wenn die Anwendung fair verwendet wird - sonst falsch.
 */
+ (BOOL)fairUse;

/**
 * @~english
 * @brief Returns the name of application. E.g. My Application (CFBundleDisplayName)
 * @return Name of application.
 *
 * @~german
 * @brief Gibt den Namen der Anwendung zurück. Bsp.: Meine Anwendung (CFBundleDisplayName)
 * @return Name der Anwendug.
 */
+ (NSString *)name;

/**
 * @~english
 * @brief Returns the version of application. E.g. 1.0 (CFBundleShortVersionString)
 * @return Version of application.
 *
 * @~german
 * @brief Gibt die Version der Anwendung zurück. Bsp.: 1.0 (CFBundleShortVersionString)
 * @return Version der Anwendung.
 */
+ (NSString *)version;

/**
 * @~english
 * @brief Returns the build of application. E.g. 100, 3A4E (CFBundleVersion)
 * @return Build of application.
 *
 * @~german
 * @brief Gibt den Build der Anwendung zurück. Bsp.: 100, 3A4E (CFBundleVersion)
 * @return Build der Anwendung.
 */
+ (NSString *)build;

/**
 * @~english
 * @brief Returns the identifier of application. E.g. com.app.name (CFBundleIdentifier)
 * @return Identifier of application.
 *
 * @~german
 * @brief Gibt die Id der Anwendung zurück. Bsp.: de.anwendung.name (CFBundleIdentifier)
 * @return Id der Anwendug.
 */
+ (NSString *)identifier;

/**
 * @~english
 * @brief Instance of App.
 * @return Singleton of App.
 *
 * @~german
 * @brief Instanz von App.
 * @return Einzige Instanz von App.
 */
+ (App *)currentApp;

@end
