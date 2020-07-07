@import Foundation;
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <UserNotifications/UserNotifications.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

@interface iFioriAzureAPNS : CDVPlugin

// Call from Fiori Client to Apple registration --------------------------------------------------->
- (void)registerDevice:(CDVInvokedUrlCommand *)command;

// Call from didRegisterForRemoteNotificationsWithDeviceToken to Azure registration --------------->
- (void)registerDeviceAzure:(NSData *)deviceToken;

// Call from Fiori Client to Azure unregistration ------------------------------------------------->
- (void)unRegisterDevice:(CDVInvokedUrlCommand *)command;

@end
