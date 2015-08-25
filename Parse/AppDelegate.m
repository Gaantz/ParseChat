//
//  AppDelegate.m
//  Parse
//
//  Created by Cristian on 24/08/15.
//  Copyright (c) 2015 Cristian. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "ChatViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Parse setApplicationId:@"zSYUSJ5i3zX41RSJHjcFZBw1xW7z5CbEU5Rkyew0"
                  clientKey:@"wCNY5dI7wdhELnHQ9nwJLggFeUI5EekUzhH8WRZp"];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                      categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    
    @try {
        NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        NSString *mensaje = [notificationPayload objectForKey:@"mensaje"];
        NSDictionary *uinfo = @{@"mensaje": mensaje};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView"
                                                            object:nil
                                                          userInfo:uinfo];
    }
    @catch (NSException *exception) {
        
    }

    
    
//    PFObject *targetPhoto = [PFObject objectWithoutDataWithClassName:@"Photo"
//                                                            objectId:photoId];
//    [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        // Show photo view controller
//        if (!error) {
//            ChatViewController *viewController = [[ChatViewController alloc] initWithPhoto:object];
//            [self.navController pushViewController:viewController animated:YES];
//        }
//    }];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    /*
     {
     "alert": "PRUEBA",
     "mensaje":
     {
     "senderId" : "-1",
     "senderDisplayName" : "Admin",
     "date" : "Now",
     "text" : "Mensajon"
     } ,
     "sound": "chime",
     "title": "Baseball News" 
     }
     */
    
    [PFPush handlePush:userInfo];
    NSString *mensaje = [userInfo objectForKey:@"mensaje"];

    NSDictionary *uinfo = @{@"mensaje": mensaje};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView"
                                                        object:nil
                                                      userInfo:uinfo];

//    PFObject *targetPhoto = [PFObject objectWithoutDataWithClassName:@"Photo"   objectId:photoId];
//    
//    // Fetch photo object
//    [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        // Show photo view controller
//        if (error) {
//            handler(UIBackgroundFetchResultFailed);
//        } else if ([PFUser currentUser]) {
//            PhotoVC *viewController = [[PhotoVC alloc] initWithPhoto:object];
//            [self.navController pushViewController:viewController animated:YES];
//            handler(UIBackgroundFetchResultNewData);
//        } else {
//            handler(UIBackgroundModeNoData);
//        }
//    }];
}

@end
