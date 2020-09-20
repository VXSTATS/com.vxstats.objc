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
 * @brief Information about the application.
 *
 * @~german
 * @brief Informationen über die Anwendung.
 */
@interface App : NSObject {}

/**
 * @~english
 * @brief Has the DRM been deleted from the application?
 + @return True, DRM exists - otherwise false.
 *
 * @~german
 * @brief Wurde das DRM aus der Anwendung entfernt?
 * @return Wahr, DRM ist vorhanden - sonst Falsch.
 */
+ (BOOL)fairUse;

/**
 * @~english
 * @brief The name of the application as defined under CFBundleDisplayName.
 * @return The name of the application.
 *
 * @~german
 * @brief Der Name der Anwendung, wie definiert unter CFBundleDisplayName.
 * @return Der Name der Anwendung.
 */
+ (NSString *)name;

/**
 * @~english
 * @brief The version of the application as defined under CFBundleShortVersionString.
 * @return The version of the application.
 *
 * @~german
 * @brief Die Version der Anwendung, wie definiert unter CFBundleShortVersionString.
 * @return Die Version der Anwendung.
 */
+ (NSString *)version;

/**
 * @~english
 * @brief The build of the application as defined under CFBundleVersion.
 * @return The build of the application.
 *
 * @~german
 * @brief Die Buildnummer der Anwendung, wie definiert unter CFBundleVersion.
 * @return Die Buildnummer der Anwendung.
 */
+ (NSString *)build;

/**
 * @~english
 * @brief The identifier of the application as defined under CFBundleIdentifier.
 * @return The identifier of the application.
 *
 * @~german
 * @brief Der Identifier der Anwendung, wie definiert unter CFBundleIdentifier.
 * @return Der Identifier der Anwendung.
 */
+ (NSString *)identifier;

/**
 * @~english
 * @brief Object for the current application.
 * @return The instance for the current application.
 *
 * @~german
 * @brief Objekt für die aktuelle Anwendung.
 * @return Die Instanz für die aktuelle Anwendung.
 */
+ (App *)currentApp;

@end
