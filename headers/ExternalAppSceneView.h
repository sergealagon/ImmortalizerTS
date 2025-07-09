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
#import "PrivateHeaders.h"

@protocol ExternalAppSceneView <NSObject>
- (void)removePresentedSceneByBundleId:(NSString *)bundleId;
@end

@interface ExternalAppSceneView : UIView
@property (nonatomic, weak) id<ExternalAppSceneView> delegate;
- (instancetype)initExternalWindowWithScene:(FBScene *)scene withAppName:(NSString *)appName withSettings:(UIMutableApplicationSceneSettings *)settings;
@end

@interface UIScreen(Private)
- (CGRect)_referenceBounds;
- (id)displayConfiguration;
@end