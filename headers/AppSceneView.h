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

@protocol AppSceneViewDelegate <NSObject>
- (void)removePresentedSceneByBundleId:(NSString *)bundleId;
@end

@interface AppSceneView : UIView
@property (nonatomic, weak) id<AppSceneViewDelegate> delegate;
@property (nonatomic) UIView *titleBar;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *closeButton;
- (instancetype)initWithScene:(FBScene *)scene withSettings:(UIMutableApplicationSceneSettings *)settings;
@end