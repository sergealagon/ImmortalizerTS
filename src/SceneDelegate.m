/* 
    Copyright (C) 2025  Serge Alagon

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>. 
*/

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "AboutViewController.h"

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (strong, nonatomic) UIWindow * window;
@end

@implementation SceneDelegate
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    
    ViewController *mainViewController = [[ViewController alloc] init];
    UINavigationController *mainNavController = [[UINavigationController alloc] 
                                               initWithRootViewController:mainViewController];
    mainNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" 
                                                                 image:[UIImage systemImageNamed:@"hourglass.tophalf.fill"] 
                                                                   tag:0];
    
    AboutViewController *aboutViewController = [[AboutViewController alloc] init];
    UINavigationController *aboutNavController = [[UINavigationController alloc] 
                                                initWithRootViewController:aboutViewController];
    aboutNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"About" 
                                                                  image:[UIImage systemImageNamed:@"info.circle"] 
                                                                    tag:1];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[mainNavController, aboutNavController];
    
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
}
@end