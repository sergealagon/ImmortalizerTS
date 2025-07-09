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

#import "AppSceneCell.h"

@interface AppSceneCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@end

@implementation AppSceneCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor systemGray6Color];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.imageView];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.nameLabel];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.deleteButton setTitle:@"✕" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    self.deleteButton.backgroundColor = [UIColor systemBackgroundColor];
    self.deleteButton.layer.cornerRadius = 12;
    self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.deleteButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.imageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.imageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor constant:-10],
        [self.imageView.widthAnchor constraintEqualToConstant:60],
        [self.imageView.heightAnchor constraintEqualToConstant:60],
        
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8],
        [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8],
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.imageView.bottomAnchor constant:8],
        [self.nameLabel.heightAnchor constraintEqualToConstant:20],
        
        [self.deleteButton.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
        [self.deleteButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8],
        [self.deleteButton.widthAnchor constraintEqualToConstant:27],
        [self.deleteButton.heightAnchor constraintEqualToConstant:27]
    ]];
}

- (void)configureAppSceneCellDetails:(LSApplicationProxy *)app {
    self.nameLabel.text = [NSString stringWithFormat:@"Open %@", app.localizedName];
    self.imageView.image = [UIImage _applicationIconImageForBundleIdentifier:app.bundleIdentifier format:0 scale:UIScreen.mainScreen.scale];
}

- (void)deleteButtonTapped {
    if (self.deleteBlock) {
        self.deleteBlock(self);
    }
}
@end