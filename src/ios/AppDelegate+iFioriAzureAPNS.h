#import "AppDelegate.h"

@interface AppDelegate (iFioriAzureAPNS)

// Apple registration success --------------------------------------------------------------------->
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

// Apple registration error ----------------------------------------------------------------------->
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

// Silence notification --------------------------------------------------------------------------->
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

@end
