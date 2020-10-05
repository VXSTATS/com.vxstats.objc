* [Preparation](#preparation)
* [Implementation](#implementation)
   * [Pre-Setup](#pre-setup)
   * [Setup](#setup)
   * [Page](#page)
   * [Event](#event)
      * [Ads](#ads)
      * [Move](#move)
      * [Open](#open)
      * [Play](#play)
      * [Search](#search)
      * [Shake](#shake)
      * [Touch](#touch)
* [Compatiblity](#compatiblity)
   * [macOS](#macos)
   * [iOS](#ios)
* [Pending Issues](#pending-issues)
   * [App Store](#app-store)

# Preparation
Checkout and open project with XCode. You need openssl.framework (https://github.com/krzyzanowskim/OpenSSL) inside same folder.

# Implementation
## Pre-Setup
All values are defined over Info.plist and used from there.

## Setup
Set up your environment with your credentials. Please insert your username, password and url here. For obfuscation please follow our best practice documentation.
```objective-c
[[Statistics instance] username:@"sandbox"];
[[Statistics instance] password:@"sandbox"];
[[Statistics instance] serverFilePath:@"https://sandbox.vxstats.com"];
```

## Page
This is the global context that you are currently in in your application. Just give it a simple name with logical app structure to identify where the user stays.
```objective-c
[[Statistics instance] page:@"Main"];
```

## Event
If you want to request a page with dynamic content please use this function.
```objective-c
[[Statistics instance] event:@"$action" value:@"$value"];
```

### Ads
To capture ads - correspondingly the shown ad.
```objective-c
[[Statistics instance] ads:@"$campain"];
```

### Move
To capture map shifts - correspondingly the new center.
```objective-c
[[Statistics instance] move:$latitude longitude:$longitude];
```

### Open
To capture open websites or documents including the information which page or document has been requested.
```objective-c
[[Statistics instance] open:@"$urlOrName"];
```

### Play
To capture played files including the information which file/action has been played.
```objective-c
[[Statistics instance] play:@"$urlOrName"];
```

### Search
To capture searches including the information for what has been searched.
```objective-c
[[Statistics instance] search:@"$search"];
```

### Shake
To capture when the device was shaken.
```objective-c
[[Statistics instance] shake];
```

### Touch
To capture typed/touched actions.
```objective-c
[[Statistics instance] touch:@"$action"];
```

# Compatiblity
## macOS
- *macOS 10.16  - (not yet supported)*
- macOS 10.15
- macOS 10.14
- macOS 10.13
- macOS 10.12
- macOS 10.11
- macOS 10.10

## iOS
- iOS 14
- iOS 13
- iOS 12
- iOS 11
- iOS 10
- iOS 9
- iOS 8

# Pending Issues
## App Store
We have successfully passed the review process already. If you have problems with the review process, please let us know and ask for support@vxapps.com to solve the issue.
