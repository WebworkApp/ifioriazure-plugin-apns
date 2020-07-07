var exec = require('cordova/exec');
    
var PLUGIN_NAME = 'iFioriAzureAPNS';
var AppPreferencesAzure = null;
             
var iFioriAzureAPNS = {
  // Get Azure Notification Hub setting --------------------------------------------------------->
  getNotificationHubSettings: function() {
      return new Promise(function (resolve, reject) {
          const aSettings = ["hubNameAzure", "connectionStringAzure"];
          
          if (window["sap"] && sap.AppPreferences) {
              sap.AppPreferences.getPreferenceValues(aSettings,
                  function successCallback(oSettings) {
                      if (oSettings &&
                          oSettings.hubNameAzure &&
                          oSettings.connectionStringAzure) {
                          
                          AppPreferencesAzure = {
                              "hubNameAzure": oSettings.hubNameAzure,
                              "connectionStringAzure": oSettings.connectionStringAzure
                          };

                          resolve();
                          
                      } else {
                          reject("An error occurs while retrieving preference values with keys!");
                      }
                  }.bind(this), reject);
              
          } else {
              reject("Kapsel Application Preferences Plugin is not available!");
          }
      }.bind(this));
  },
        
  // Native device registration ----------------------------------------------------------------->
  // 1. Before Registration checks -->
  registerDeviceStart: function() {
      // Get user from Fiori Lautchpad -->
      //if (window["sap"] && sap.ushell && sap.ushell.Container) {
      if (window["sap"] && sap.Logger) {
          //var user = sap.ushell.Container.getService("UserInfo").getId();
          //user = user.toUpperCase();
          user = "EXL574";
             
          // Start registration with User -->
          if (user) {
              sap.Logger.debug("Request user: " + user);
              
              // Continue registration with User and Azure Notification Hub settings -->
              iFioriAzureAPNS.getNotificationHubSettings().then(function(oNotificationHubSettings) {
                  //iFioriAzureAPNS.settings = oNotificationHubSettings;
                  return iFioriAzureAPNS.registerDevice(user);
                                                               
              }, function(oError) {
                  sap.Logger.error("Register Device: " + oError);
              });
          }
      }
  },
             
  // 2. Registration -->
  registerDevice: function(user) {
      return new Promise(function(resolve, reject) {
          exec(resolve, reject, PLUGIN_NAME, 'registerDevice', [user, AppPreferencesAzure.hubNameAzure, AppPreferencesAzure.connectionStringAzure]);
      });
  },
             
  // Native device unregistration --------------------------------------------------------------->
  // 1. Before Unregistration -->
  unRegisterDeviceStart: function() {
      // Continue unregistration with Azure Notification Hub settings -->
      iFioriAzureAPNS.getNotificationHubSettings().then(function(oNotificationHubSettings) {
         return iFioriAzureAPNS.unRegisterDevice();
                                                      
      }, function(oError) {
         sap.Logger.error("Unregister Device: " + oError);
      });
  },
             
  // 2. Unregistration -->
  unRegisterDevice: function() {
      return new Promise(function(resolve, reject) {
             exec(resolve, reject, PLUGIN_NAME, 'unRegisterDevice', [AppPreferencesAzure.hubNameAzure, AppPreferencesAzure.connectionStringAzure]);
      });
  }
             
};
             
// Export --------------------------------------------------------------------------------------->
module.exports = iFioriAzureAPNS;
             
// Raise from Fiori Client on FLP Logon: Call native device registration ------------------------>
document.addEventListener("onSapLogonSuccess", iFioriAzureAPNS.registerDeviceStart, false);
//document.addEventListener("deviceready", iFioriAzureAPNS.registerDeviceStart, false);
             
// Call from Fiori Client on Clear All Application Setting: Call native device unregistration --->
if (window["sap"] && sap.logon && sap.logon.Core) {
    const fn = sap.logon.Core.deleteRegistration;
    
    sap.logon.Core.deleteRegistration = function(successCallback, errorCallback) {
      iFioriAzureAPNS.unRegisterDeviceStart();
      fn.call(null, successCallback, errorCallback);
    }
}
             
// Extend Fiori register success to stop Kapsle Push plugin ------------------------------------->
if (window["sap"] && sap.Push) {
    sap.Push.RegisterSuccess = function() { return; }
}
