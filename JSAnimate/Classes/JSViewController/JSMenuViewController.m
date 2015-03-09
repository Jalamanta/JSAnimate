//
//  JSMenuViewController.m
//  JSAnimate
//
//  Created on 8/03/2015.
//
//  Copyright (c) 2015 Jalamanta
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgement in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
//

#import "JSMenuViewController.h"

#import "JSSimpleAnimationViewController.h"
#import "JSSyncronousViewController.h"
#import "JSAsyncronousViewController.h"
#import "JSCombinedViewController.h"
#import "JSFunOneViewController.h"
#import "JSFunTwoViewController.h"

typedef NS_ENUM(NSUInteger, JSMenuViewRow)
{
    JSMenuViewRowSimpleAnimation = 0,
    JSMenuViewRowSyncronousAnimation,
    JSMenuViewRowAsyncronousAnimation,
    JSMenuViewRowCombinedAnimation,
    JSMenuViewRowFunOneAnimation, 
    JSMenuViewRowFunTwoAnimation
};


@interface JSMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) NSArray *rows;
@property (nonatomic, readonly) NSArray *rowTitles;

@end

@implementation JSMenuViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    _rows = @[ @(JSMenuViewRowSimpleAnimation),
               @(JSMenuViewRowSyncronousAnimation),
               @(JSMenuViewRowAsyncronousAnimation),
               @(JSMenuViewRowCombinedAnimation),
               @(JSMenuViewRowFunOneAnimation),
               @(JSMenuViewRowFunTwoAnimation)];
    
    _rowTitles = @[ @"Simple example",
                    @"Syncronous example",
                    @"Asyncronous example",
                    @"Combined example",
                    @"Fun One",
                    @"Fun Two"];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setTableFooterView:[UIView new]];
    [self.view addSubview:_tableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"JSAnimate examples";
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rows.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];

    [[cell textLabel] setText:self.rowTitles[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *viewController = nil;
    
    switch (indexPath.row)
    {
        case JSMenuViewRowSimpleAnimation:
            viewController = [JSSimpleAnimationViewController new];
            break;
            
        case JSMenuViewRowSyncronousAnimation:
            viewController = [JSSyncronousViewController new];
            break;
 
        case JSMenuViewRowAsyncronousAnimation:
            viewController = [JSAsyncronousViewController new];
            break;

        case JSMenuViewRowCombinedAnimation:
            viewController = [JSCombinedViewController new];
            break;
            
        case JSMenuViewRowFunOneAnimation:
            viewController = [JSFunOneViewController new];
            break;

        case JSMenuViewRowFunTwoAnimation:
            viewController = [JSFunTwoViewController new];
            break;
            
        default:
            break;
    }
    
    if (viewController)
    {
        viewController.title = _rowTitles[indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
