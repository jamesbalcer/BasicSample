
#import "AppDelegate.h"
#import <Gimbal/Gimbal.h>
#import <UserNotifications/UserNotifications.h>

#import "ViewController.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // To get started with an API key, go to https://manager.gimbal.com/
#warning Insert your Gimbal Application API key below in order to see this sample application work
    [Gimbal setAPIKey:@"9c5069a7-6407-4489-81fe-2f288c85885a" options:nil];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasBeenPresentedWithOptInScreen"] == NO)
    {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Opt-In" bundle:nil] instantiateInitialViewController];
    }
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey])
    {
        [self processRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey])
    {
        [self processLocalNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] withApplicationState:[[UIApplication sharedApplication] applicationState]];
    }
    
    [self registerForNotifications:application];
    
    return YES;
}

# pragma mark - Remote Notification Support

- (void)registerForNotifications:(UIApplication *)application
{
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error)
     {
         if(error){
             NSLog(@"Error registering for UserNotifications %@", error);
         } else {
             NSLog(@"Registered for UserNotifications");
         }
     }];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [Gimbal setPushDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Registration for remote notifications failed with error %@", error.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self processRemoteNotification:userInfo];
}

# pragma mark -  GMBLCommunicationManager Delegate Callbacks for legacy notifications

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    [self processLocalNotification:notification withApplicationState:state];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)())completionHandler {
    [self processNotificationResponse:response];
    completionHandler();
}

# pragma mark -  GMBLCommunicationManager Delegate Callbacks for User Notifications

-(void)userNotificationCenter:(UNUserNotificationCenter *)center
      willPresentNotification:(UNNotification *)notification
       withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    completionHandler(UNNotificationPresentationOptionAlert);
}

# pragma mark -  Notificaion Helper Methods

- (void)processRemoteNotification:(NSDictionary *)userInfo
{
    GMBLCommunication *communication = [GMBLCommunicationManager communicationForRemoteNotification:userInfo];
    
    if (communication)
    {
        [self storeCommunication:communication];
    }
}

- (void)processNotificationResponse:(UNNotificationResponse *)response
{
    GMBLCommunication *communication = [GMBLCommunicationManager communicationForNotificationResponse:response];
    if (communication)
    {
        [self storeCommunication:communication];
    }    
}

- (void)processLocalNotification:(UILocalNotification *)notification withApplicationState:(UIApplicationState)state
{
    GMBLCommunication *communication = [GMBLCommunicationManager communicationForLocalNotification:notification];
    GMBLAction *action = [GMBLExperienceManager actionForLocalNotification:notification];
    
    if (communication)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
        [self storeCommunication:communication];
    } else if (action) {
        if (state == UIApplicationStateInactive){
            [GMBLExperienceManager didReceiveExperienceAction:action];
        }
    }
}

- (void)storeCommunication:(GMBLCommunication *)communication
{
    UINavigationController *nv = (UINavigationController *)self.window.rootViewController;
    if ([nv.topViewController isKindOfClass:[ViewController class]])
    {
        ViewController *vc = (ViewController *)nv.topViewController;
        [vc addCommunication:communication];
    }
}

@end
