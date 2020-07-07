#import "iFioriAzureAPNS.h"

@implementation iFioriAzureAPNS

// FLP User and Azure Notification Hub settings -->
NSString* user             = nil;
NSString* hubName          = nil;
NSString* connectionString = nil;

// Call from Fiori Client to Apple registration --------------------------------------------------->
// 1. Start Apple device registration -->
- (void)registerDevice:(CDVInvokedUrlCommand *)command {
    
    // TEST ---------->
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *azureRegister = [prefs stringForKey:@"AzureRegister"];
    
    
    if ([azureRegister  isEqual: @"false"] || azureRegister == nil ) {
        
        NSLog(@"Native registerDevice started");

        // 1.1 Get FLP User and Azure Notification Hub settings -->
        user             = command.arguments[0];
        hubName          = command.arguments[1];
        connectionString = command.arguments[2];

        // 1.2 Start Apple registra tion -->
        [self registerDeviceApple];

        // 1.3 Plugin result -->
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Device registered"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
              
        NSLog(@"Native registerDevice ended");
        
    };
}

// 2. Apple device registration -->
- (void)registerDeviceApple {
    NSLog(@"Native registerDeviceApple started");

    // 2.1 Client push notification authorization -->
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options =  UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
    [center requestAuthorizationWithOptions:(options) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error requesting for authorization: %@", error);
        }
    }];

    // 2.2 Apple registration -->
    [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    NSLog(@"Native registerDeviceApple ended");
}

// Call from didRegisterForRemoteNotificationsWithDeviceToken to Azure registration --------------->
// 3. Start Azure device registration -->
- (void)registerDeviceAzure:(NSData *)deviceToken {
    NSLog(@"Native registerDeviceAzure started");
    
    // 3.1 Set tag with user -->
    NSMutableSet *tags = [[NSMutableSet alloc] init];
    [tags addObject:user];
    
    // 3.2 Azure registration -->
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:connectionString notificationHubPath:hubName];
    [hub registerNativeWithDeviceToken:deviceToken tags:tags completion:^(NSError* error) {
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
        }
    }];
    
    // TEST ---------->
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"true" forKey:@"AzureRegister"];
    
    NSLog(@"Native registerDeviceAzure ended");
}

// Call from Fiori Client to Azure unregistration ------------------------------------------------->
// 4. Start Azuree device unregistration -->
- (void)unRegisterDevice:(CDVInvokedUrlCommand *)command {
    NSLog(@"unRegisterDevice started");
    
    // 4.1 Get User and Azure Notification Hub settings -->
    hubName          = command.arguments[0];
    connectionString = command.arguments[1];
    
    // 4.2 Azure unregistration -->
    [self unregisterDeviceAzure];

    // 4.3 Plugin result -->
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Device unregistered"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    NSLog(@"unRegisterDevice ended");
}

// 5. Azure device unregistration -------------->
- (void)unregisterDeviceAzure {
    NSLog(@"Native unregisterDeviceAzure started");
    
    // 5.1 Azure unregistration -->
    SBNotificationHub *hub = [[SBNotificationHub alloc] initWithConnectionString:connectionString notificationHubPath:hubName];
    [hub unregisterNativeWithCompletion:^(NSError* error) {
        if (error != nil) {
            NSLog(@"Error unregistering for push: %@", error);
        }
    }];
    
    // TEST ---------->
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"false" forKey:@"AzureRegister"];
    
    NSLog(@"Native unregisterDeviceAzure ended");
}

@end
