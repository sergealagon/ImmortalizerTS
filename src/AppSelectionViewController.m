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

#import "AppSelectionViewController.h"

@interface AppSelectionViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSMutableArray<LSApplicationProxy *> *installedApps;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray<LSApplicationProxy *> *filteredApps;
@end

@implementation AppSelectionViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Select an app to immortalize";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.installedApps = [NSMutableArray new];
    self.filteredApps = [NSArray new]; 
    
    [self setupNavigationBar];
    [self setupTableView];
    [self setupSearchController];
    [self loadApplist];
}

- (void)setupSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Search apps";
    self.navigationItem.searchController = self.searchController;
    self.definesPresentationContext = YES;
}

- (void)setupNavigationBar {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                   target:self 
                                   action:@selector(cancelButtonTapped)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
}

- (void)loadApplist {
    NSArray *allApps = [LSApplicationWorkspace.defaultWorkspace allInstalledApplications];
    for (LSApplicationProxy *app in allApps) {
        if ([app.applicationType isEqual:@"User"] || 
        ([app.applicationType isEqual:@"System"] && ![app.appTags containsObject:@"hidden"] 
        && !app.launchProhibited && !app.placeholder && !app.removedSystemApp)) {
            [self.installedApps addObject:app];
        }
    }

    [self.installedApps sortUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"localizedName" ascending:YES]
    ]];

    [self.tableView reloadData];
}

- (void)cancelButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchController.isActive ? self.filteredApps.count : self.installedApps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    LSApplicationProxy *app = self.searchController.isActive ? self.filteredApps[indexPath.row] : self.installedApps[indexPath.row];
    cell.textLabel.text = app.localizedName;
    cell.detailTextLabel.text = app.bundleIdentifier;
    cell.imageView.image = [UIImage _applicationIconImageForBundleIdentifier:app.bundleIdentifier format:0 scale:UIScreen.mainScreen.scale];
    
    return cell;
}

/* calls didSelectApp method from viewcontroller */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LSApplicationProxy *selectedApp = self.searchController.isActive ? self.filteredApps[indexPath.row] : self.installedApps[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(didSelectApp:)]) [self.delegate didSelectApp:selectedApp];

    if (self.searchController.isActive) [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localizedName CONTAINS[cd] %@", searchText];
        self.filteredApps = [self.installedApps filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredApps = self.installedApps;
    }
    
    [self.tableView reloadData];
}
@end