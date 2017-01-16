/**
 * Copyright (C) 2015 Gimbal, Inc. All rights reserved.
 *
 * This software is the confidential and proprietary information of Gimbal, Inc.
 *
 * The following sample code illustrates various aspects of the Gimbal SDK.
 *
 * The sample code herein is provided for your convenience, and has not been
 * tested or designed to work on any particular system configuration. It is
 * provided AS IS and your use of this sample code, whether as provided or
 * with any modification, is at your own risk. Neither Gimbal, Inc.
 * nor any affiliate takes any liability nor responsibility with respect
 * to the sample code, and disclaims all warranties, express and
 * implied, including without limitation warranties on merchantability,
 * fitness for a specified purpose, and against infringement.
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@class GMBLCommunication;
@class GMBLVisit;

@protocol GMBLCommunicationManagerDelegate;

/*!
 The GMBLCommunicationManager defines the interface for delivering communication events to your Gimbal enabled
 application.
 
 In order to receive communications associated to place entry and exit events, you must assign a class that conforms to
 the GMBLCommunicationManagerDelegate protocol to the delegate property of GMBLCommunicationManager.
 */
@interface GMBLCommunicationManager : NSObject

/// The delegate object to receive communication events.
@property (weak, nonatomic) id<GMBLCommunicationManagerDelegate> delegate;

+ (void)startReceivingCommunications;

+ (void)stopReceivingCommunications;

+ (BOOL)isReceivingCommunications;

/*!
 @deprecated This method is deprecated starting in iOS 10
 @note Please use UserNotifications  @code[GMBLCommunicationManager communicationForNotificationResponse:response] @endcode
 
 Used to parse a Gimbal Communication from a remote notification userInfo
 @param userInfo The userInfo object representing the remote notification
 */
+ (GMBLCommunication *)communicationForRemoteNotification:(NSDictionary *)userInfo NS_DEPRECATED_IOS(4_0, 10_0, "Use UserNotifications in iOS 10 and above");

/*!
 @deprecated This method is deprecated starting in iOS 10
 @note Please use UserNotifications  @code[GMBLCommunicationManager communicationForNotificationResponse:response] @endcode

 Used to parse a Gimbal Communication from a local notification
 @param notification The local notification
 */
+ (GMBLCommunication *)communicationForLocalNotification:(UILocalNotification *)notification NS_DEPRECATED_IOS(4_0, 10_0, "Use UserNotifications in iOS 10 and above");


/*!
 For use with UserNotifications in iOS 10 and above.
 
 Used to parse a Gimbal Communication from a local notification
 @param notification The local notification
 */
+ (GMBLCommunication *)communicationForNotificationResponse:(UNNotificationResponse *)notificationResponse;

@end

/*!
 The GMBLCommunicationManagerDelegate protocol defines the methods used to receive events for the
 GMBLCommunicationManager object.
 */
@protocol GMBLCommunicationManagerDelegate <NSObject>

@optional

/*!
 Called when a Gimbal Event (for instance Place Arrival) triggers a Gimbal Communication. The communications returned in the array
 will be scheduled by Gimbal, while others will be ignored.
 
 Please note that frequency limit and delay are not honored for communications not returned.
 
 @param manager
 @param communications Communications retrieved from the Gimbal Manager
 @param visit The visit that triggered the communication
 @return An array containing all the GMBLCommunication objects you would like Gimbal to post a UILocalNotification
 */
- (NSArray *)communicationManager:(GMBLCommunicationManager *)manager presentLocalNotificationsForCommunications:(NSArray *)communications forVisit:(GMBLVisit *)visit;

/*!
 @deprecated This method is deprecated starting in iOS 10
 @note Please use UserNotifications  @code communicationManager:prepareNotificationContentForDisplay:forCommunication: @endcode
 
 Called when a Gimbal Event (for instance Place Arrival) results in Gimbal Communications. Returned UILocalNotification
 will be scheduled for display. If nil is returned, a default Notification will be displayed using the GMBLCommunication.
 
 @param manager
 @param notification Default notification for the received communication
 @param communication The communication received creating the notification
 @return The notification to be scheduled
 */
- (UILocalNotification *)communicationManager:(GMBLCommunicationManager *)manager prepareNotificationForDisplay:(UILocalNotification *)notification forCommunication:(GMBLCommunication *)communication NS_DEPRECATED_IOS(4_0, 10_0, "Use UserNotifications in iOS 10 and above");


/*!
 For use with UserNotifications in iOS 10 and above.
 
 Called when a Gimbal Event (for instance Place Arrival) results in Gimbal Communications. Returned UNMutableNotificationContent
 will be scheduled for display. If nil is returned, a default Notification will be displayed using the GMBLCommunication.
 
 @param manager
 @param notificationContent Default notification content for the received communication
 @param communication The communication received creating the notification
 @return The notificationContent to be added to scheduled UserNotification
 */
- (UNMutableNotificationContent *)communicationManager:(GMBLCommunicationManager *)manager prepareNotificationContentForDisplay:(UNMutableNotificationContent *)notificationContent forCommunication:(GMBLCommunication *)communication;

@end
