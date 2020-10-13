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

/* local class */
@class Reachability;

/**
 * @~english
 * @brief Communication with the statistics server.
 *
 * @b General:
 * @n The class communicates with the statistics server in order to transfer a
 * page impression or an action/event.
 *
 * @b Security:
 * @n There is a multi-level security concept:
 * @n 1. Communication must be authenticated via htaccess.
 * @n 2. Configuration should be carried out via HTTPS only, so that all data is
 * encrypted and cannot be manipulated.
 * @n 3. Communication should be carried out via POST only. Only specific tools
 * make a manipulation of data possible.
 * @n 4. On the server part, all values are checked for validity; invalid entries
 * are excluded.
 *
 * @b Threads:
 * @n The class is thread-safe and can be executed in MainThread or in a
 * BackgroundThread of the application.
 * The queries are processed asynchronously or synchronously.
 *
 * @b Offline entries:
 * @n Statistic entries that have not been sent successfully are filed in a
 * queue of local settings and sent as soon as an 
 * internet connection is established. Estimations assume that there is
 * less than 5% not received statistic data.
 *
 * @b Data privacy:
 * @n Unique data is processed but no position data and also no user data that
 * can be allocated directly.
 * No third party is involved in the processing of data. The system with default
 * settings is configured for security and anonymity.
 *
 * @b Application:
 * @n Besides an API for iPhone/iPad/iPod touch and Android, e.g. C#, C, C++,
 * PHP, JavaScript, and Java is also supported. Further formats can be supported
 * upon request.
 *
 * @b Example:
 * @n 1. Define a path to the statistics server.
 * @code
 * [[Statistics instance] serverFilePath:@"https://sandbox.vxstats.com"];
 * @endcode
 * 2. Transfer page impression.
 * @code
 * [[Statistics instance] page:@"MyPage"];
 * [[Statistics instance] page:NSStringFromClass([self class])];
 * @endcode
 * 3. Transfer action.
 * @code
 * [[Statistics instance] event:@"action" value:@"value"];
 * @endcode
 *
 * @~german
 * @brief Kommunikation mit dem Statistikserver.
 *
 * @b Allgemein:
 * @n Diese Klasse kommuniziert zum Statistikserver um eine Seitenimpression
 * oder eine Aktion/ein Event zu übertragen.
 *
 * @b Sicherheit:
 * @n Es ist ein mehrstufiges Sicherheitskonzept vorhanden:
 * @n 1. Kommunikation muss über htaccess authentifiziert werden.
 * @n 2. Konfiguration sollte nur über HTTPS erfolgen, damit werden alle Daten
 * verschlüsselt und können nicht manipuliert werden.
 * @n 3. Kommunikation sollte ausschließlich über POST erfolgen. Nur spezielle Tools
 * erlauben somit eine Manipulation von Daten.
 * @n 4. Serverseitig werden alle Werte auf Gültigkeit überprüft, ungültige
 * Einträge sind ausgeschlossen.
 *
 * @b Threads:
 * @n Die Klasse ist threadsicher und kann sowohl im MainThread ausgeführt werden
 * oder in einem BackgroundThread der Anwendung. Die Anfragen werden
 * entsprechend asynchron oder synchron abgearbeitet.
 *
 * @b Offline-Einträge:
 * @n Nicht erfolgreich versendete Statistikeinträge werden in einer Queue der
 * lokalen Einstellungen abgelegt und versendet, sobald wieder eine
 * Internetverbindung besteht. Schätzungen gehen von weniger als 5% nicht
 * empfangener Statistikdaten aus.
 *
 * @b Datenschutz:
 * @n Es werden zwar eindeutige Daten verarbeitet, aber keine Positionsdaten und
 * auch keine Benutzerdaten, die direkt zugeordnet werden können. Dritte sind nicht an
 * der Verarbeitung der Daten beteiligt. Das System in der
 * Standardkonfiguration ist auf Sicherheit und Anonymität ausgelegt.
 *
 * @b Verwendung:
 * @n Neben einer API für iPhone/iPad/iPod touch und Android wird auch z.B. C#,
 * C, C++, PHP, JavaScript und Java unterstützt. Weitere Formate erstellen wir
 * natürlich gerne auf Anfrage.
 *
 * @b Beispiel:
 * @n 1. Angeben eines Pfads zum Statistikserver.
 * @code
 * [[Statistics instance] serverFilePath:@"https://sandbox.vxstats.com"];
 * @endcode
 * 2. Seitenimpression übermitteln.
 * @code
 * [[Statistics instance] page:@"MyPage"];
 * [[Statistics instance] page:NSStringFromClass([self class])];
 * @endcode
 * 3. Aktion übermitteln.
 * @code
 * [[Statistics instance] event:@"action" value:@"value"];
 * @endcode
 */
@interface Statistics : NSObject <NSURLSessionDelegate> {

@private
  /**
   * @~english
   * @brief The current network state.
   *
   * @~german
   * @brief Der aktuelle Netzwerkstatus.
   */
  NSString *m_status;

  /**
   * @~english
   * @brief Path to statistics server.
   *
   * @~german
   * @brief Der Pfad zum Statistikserver.
   */
  NSString *m_serverFilePath;

  /**
   * @~english
   * @brief Username for authorization.
   *
   * @~german
   * @brief Benutzername für die Autorisierung.
   */
  NSString *m_username;

  /**
   * @~english
   * @brief Password for authorization.
   *
   * @~german
   * @brief Passwort für die Autorisierung.
   */
  NSString *m_password;

  /**
   * @~english
   * @brief The last used page is buffered in order to use the actions and
   * search comfortably.
   *
   * @~german
   * @brief Die zuletzt verwendete Seite wird zwischengespeichert, um die
   * Aktionen und Suchen komfortabel zu verwenden.
   */
  NSString *lastPageName;

  /**
   * @~english
   * @brief The last message to the statistics service that has not been sent.
   *
   * @~german
   * @brief Die letzte nicht versendete Nachricht an den Statistiserver.
   */
  NSString *m_lastMessage;

  /**
   * @~english
   * @brief Checking connection in order to determine the connection speed or to
   * transfer pending data.
   *
   * @~german
   * @brief Überprüfen der Verbindung, um die Verbindungsgeschwindigkeit zu
   * ermitteln oder ausstehende Daten zu senden.
   */
  Reachability *m_reachability;
}

/**
 * @~english
 * @brief The last used page is buffered in order to use actions and searches
 * comfortably.
 *
 * @~german
 * @brief Die zuletzt verwendete Seite wird zwischengespeichert, um die Aktionen
 * und Suchen komfortabel zu verwenden.
 */
@property (nonatomic, copy, readonly) NSString *lastPageName;

/**
 * @~english
 * @brief Update on connectivity.
 *
 * @~german
 * @brief Update des Systems für die Art der Verbindung.
 */
- (void)manualUpdate;

/**
 * @~english
 * @brief Defines the path and name to the statistics server.
 * @param serverFilePath   The file name to the statistics server.
 *
 * @b Example:
 * @n for the HTTPS address sandbox.vxstats.com and the folder /.
 *
 * @~german
 * @brief Definiert den Pfad und Namen zum Statistikserver.
 * @param serverFilePath   Der Dateiname zum Statistikserver.
 *
 * @b Beispiel:
 * @n Für die HTTPS-Adresse sandbox.vxstats.com und das Verzeichnis /.
 *
 * @~
 * @code
 * [[Statistics instance] serverFilePath:@"https://sandbox.vxstats.com"];
 * @endcode
 */
- (void)serverFilePath:(NSString *)serverFilePath;

/**
 * @~english
 * @brief Defines the username to the statistics server.
 * @param username   The username to the statistics server.
 *
 * @~german
 * @brief Definiert den Benutzernamen zum Statistikserver.
 * @param username   Der Benutzername zum Statistikserver.
 *
 * @~
 * @code
 * [[Statistics instance] username:@"sandbox"];
 * @endcode
 */
- (void)username:(NSString *)username;

/**
 * @~english
 * @brief Defines the password to the statistics server.
 * @param password   The password to the statistics server.
 *
 * @~german
 * @brief Definiert das Passwort zum Statistikserver.
 * @param password   Das Passwoort zum Statistikserver.
 *
 * @~
 * @code
 * [[Statistics instance] password:@"sandbox"];
 * @endcode
 */
- (void)password:(NSString *)password;

/**
 * @~english
 * @brief Request a page with the name pageName in order to transfer it to the
 * statistics server.
 * @param pageName   The name of the requested page.
 * @note Limited to 255 characters.
 *
 * @~german
 * @brief Aufruf einer Seite mit dem Namen pageName um es an den Statistikserver
 * zu übermitteln.
 * @param pageName   Der Name der aufgerufenen Seite.
 * @note Auf 255 Zeichen begrenzt.
 */
- (void)page:(NSString *)pageName;

/**
 * @~english
 * @brief If you would like to request a page with dynamic content please use
 * this function.
 *
 * @b Example:
 * @n Page with ads.
 *
 * @~german
 * @brief Wenn Sie eine Seite mit dynamischem Inhalt aufrufen möchten, verwenden
 * Sie diese Funktion.
 *
 * @b Beispiel:
 * @n Seite mit Werbung.
 *
 * @~
 * @code
 * [[Statistics instance] event:@"ads" withValue:campaign];
 * [[Statistics instance] event:@"ads" withValue:@"Apple"];
 * @endcode
 *
 * @see Statistics#ads:
 *
 * @code
 * [[Statistics instance] ads:campaign];
 * @endcode
 *
 * @~english
 * @b Example:
 * @n Move map to geo position.
 *
 * @~german
 * @b Beispiel:
 * @n Karte auf Geoposition verschieben.
 *
 * @~
 * @code
 * [[Statistics instance] event:@"move" withValue:latitude,longitude];
 * [[Statistics instance] event:@"move" withValue:@"52.523405,13.411400"];
 * @endcode
 *
 * @see Statistics#move:longitude:
 *
 * @code
 * [[Statistics instance] move:latitude longitude:longitude];
 * @endcode
 *
 * @~english
 * @b Example:
 * @n Open browser with URL.
 *
 * @~german
 * @b Beispiel:
 * @n Browser mit URL öffnen.
 *
 * @~
 * @code
 * [[Statistics instance] event:@"open" withValue:urlOrName];
 * [[Statistics instance] event:@"open" withValue:@"https://www.vxstat.com"];
 * @endcode
 *
 * @see Statistics#open:
 *
 * @code
 * [[Statistics instance] open:urlOrName];
 * @endcode
 *
 * @~english
 * @b Example:
 * @n Play video.
 *
 * @~german
 * @b Beispiel:
 * @n Video abspielen.
 *
 * @~
 * @code
 * [[Statistics instance] event:@"play" withValue:urlOrName];
 * [[Statistics instance] event:@"play" withValue:@"https://www.vxstats.com/movie.m4v"];
 * @endcode
 *
 * @see Statistics#play:
 *
 * @code
 * [[Statistics instance] play:urlOrName];
 * @endcode
 *
 * @~english 
 * @b Example: 
 * @n Search for 'asdf'.
 *
 * @~german 
 * @b Beispiel:
 * @n Suchen nach 'asdf'.
 * @~
 *
 * @code
 * [[Statistics instance] event:@"search" withValue:text];
 * [[Statistics instance] event:@"search" withValue:@"asdf"];
 * @endcode
 *
 * @see Statistics#search:
 *
 * @code
 * [[Statistics instance] search:text];
 * @endcode
 *
 * @~english 
 * @b Example: 
 * @n Shake the device.
 *
 * @~german 
 * @b Beispiel:
 * @n @n Das Gerät schütteln.
 * @~
 *
 * @code
 * [[Statistics instance] event:@"shake" withValue:nil];
 * @endcode
 *
 * @see Statistics#shake
 *
 * @code
 * [[Statistics instance] shake];
 * @endcode
 *
 * @~english 
 * @b Example: 
 * @n Touch the button for navigation.
 *
 * @~german 
 * @b Beispiel:
 * @n Button für Navitation drücken.
 * @~
 *
 * @code
 * [[Statistics instance] event:@"touch" withValue:action];
 * [[Statistics instance] event:@"touch" withValue:@"Navigation"];
 * @endcode
 *
 * @see Statistics#touch:
 *
 * @code
 * [[Statistics instance] touch:action];
 * @endcode
 *
 * @~
 * @param eventName   @~english The event. @~german Das Event.
 * @~
 * @param value   @~english The value for the event. @~german Der Wert für das
 * Event.
 */
- (void)event:(NSString *)eventName withValue:(NSString *)value;

/**
 * @~english
 * @brief To capture ads - correspondingly the shown ad.
 * @param campaign   The displayed ad.
 * @note Limited to 255 characters.
 *
 * @~german
 * @brief Für das Erfassen von Werbeeinblendungen - entsprechend die angezeigte
 * Werbung.
 * @param campaign   Die angezeigte Werbung.
 * @note Auf 255 Zeichen begrenzt.
 *
 * @~
 * @see Statistics#event:withValue:
 *
 * @code
 * [[Statistics instance] event:@"ads" withValue:campaign];
 * @endcode
 */
- (void)ads:(NSString *)campaign;

/**
 * @~english
 * @brief To capture map shifts - correspondingly the new center.
 * @param latitude   Latitude of center.
 * @param longitude   Longitude of center.
 *
 * @~german
 * @brief Für die Erfassung von Kartenverschiebungen - entsprechend das neue Zentrum.
 * @param latitude   Latitude des Zentrums.
 * @param longitude   Longitude des Zentrums.
 *
 * @~
 * @see Statistics#event:withValue:
 *
 * @code
 * [[Statistics instance] event:@"move" withValue:latitude,longitude];
 * @endcode
 */
- (void)move:(float)latitude longitude:(float)longitude;

/**
 * @~english
 * @brief To capture open websites or documents including the information which
 * page or document has been requested.
 * @param urlOrName   The displayed website/document.
 * @note Limited to 255 characters.
 *
 * @~german
 * @brief Für die Erfassung von geöffneten Webseiten oder Dokumenten mit der
 * Information, welche Seite bzw. welches Dokument aufgerufen wurde.
 * @param urlOrName   Die angezeigte Webseite/das angezeigte Dokument.
 * @note Auf 255 Zeichen begrenzt.
 *
 * @~
 * @see Statistics#event:withValue:
 *
 * @code
 * [[Statistics instance] event:@"open" withValue:urlOrName];
 * @endcode
 */
- (void)open:(NSString *)urlOrName;

/**
 * @~english
 * @brief To capture played files including the information which file/action
 * has been played.
 * @param urlOrName   The played file.
 * @note Limited to 255 characters.
 *
 * @~german
 * @brief Für die Erfassung von abgespielten Dateien mit der Information,
 * welche Datei/Aktion abgespielt wurde.
 * @param urlOrName   Die abgespielte Datei.
 * @note Auf 255 Zeichen begrenzt.
 *
 * @~
 * @see Statistics#event:withValue:
 *
 * @code
 * [[Statistics instance] event:@"play" withValue:urlOrName];
 * @endcode
 */
- (void)play:(NSString *)urlOrName;

/**
 * @~english
 * @brief To capture searches including the information for what has been
 * searched.
 * @param text   The searched text.
 * @note Limited to 255 characters.
 *
 * @~german
 * @brief Für die Erfassung von Suchen mit der Information, nach was gesucht wurde.
 * @param text   Der gesuchte Text.
 * @note Auf 255 Zeichen begrenzt.
 *
 * @~
 * @see Statistics#event:withValue:
 *
 * @code
 * [[Statistics instance] event:@"search" withValue:text];
 * @endcode
 */
- (void)search:(NSString *)text;

/**
 * @~english
 * @brief To capture when the device has been shaken.
 *
 * @~german
 * @brief Für die Erfassung, wann das Gerät geschüttelt wurde.
 *
 * @~
 * @see Statistics#event:withValue:
 *
 * @code
 * [[Statistics instance] event:@"shake" withValue:nil];
 * @endcode
 */
- (void)shake;

/**
 * @~english
 * @brief To capture typed/touched actions.
 * @param action   The name of the touched action.
 * @note Limited to 255 characters.
 *
 * @~german
 * @brief Für die Erfassung von getippten/gedrückten Aktionen.
 * @param action   Der Name der getippten/gedrückten Aktion.
 * @note Auf 255 Zeichen begrenzt.
 *
 * @~
 * @see Statistics#event:withValue:
 *
 * @code
 * [[Statistics instance] event:@"touch" withValue:action];
 * @endcode
 */
- (void)touch:(NSString *)action;

/**
 * @~english
 * @brief The instance for statistics.
 * The statistics system is initialized and creates a database for offline
 * statistics that is only sent if a connection to the statistics server
 * could be established. Please provide necessary settings for the communication
 * to the server, its path, and which explicit values are also supposed to be collected.
 *
 * The communication to the server needs a token in order to get the
 * authorization to capture statistic values.
 * The complete communication is transfered by http or https protocol via POST.
 * @note Please use https with TLS 1.2 and HSTS or better and enabled ipv6
 * support.
 * @return The instance for statistics.
 *
 * @~german
 * @brief Die Instanz für Statistiken.
 * Das Statistisystem wird initalisiert und erstellt eine Datenbank für Offline
 * Statistik, die nur versendet wird, wenn eine Verbindung zum Statistikserver
 * hergestellt werden konnte. Bitte hinterlegen Sie nötige Einstellungen für die
 * Kommunikation zum Server, dessen Pfad und welche expliziten Werte ebenfalls
 * gesammelt werden sollen.
 *
 * Die Kommunikation zum Server verlangt einen Token, um die Erlaubnis zu
 * erhalten, statistische Werte zu erfassen.
 * Die gesamte Kommunikation wird über das http(s)-Protokoll via POST
 * übermittelt.
 * @note Bitte nur https mit TLS 1.2 und HSTS oder besser und ipv6-Unterstützung
 * verwenden.
 * @return Die Instanz für Statistiken.
 */
+ (Statistics *)instance;

@end
