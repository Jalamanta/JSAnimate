//
//  JSAsyncronousViewController.m
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

#import "JSAsyncronousViewController.h"
#import "UIView+JSAnimate.h"

@interface JSAsyncronousViewController ()

@property (nonatomic, readonly) UIView *squareView;
@property (assign) BOOL squareAnimating;

@end

@implementation JSAsyncronousViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _squareView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 50.0f, 50.0f)];
    [self.squareView setBackgroundColor:[[UIColor orangeColor] colorWithAlphaComponent:0.7f]];
    [[self.squareView layer] setBorderColor:[UIColor orangeColor].CGColor];
    [[self.squareView layer] setBorderWidth:2.0f];
    [[self.squareView layer] setCornerRadius:3.0f];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animate:)]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view addSubview:self.squareView];
    [self animateSquare];
}

#pragma mark - JSAnimationNode Example

-(void)animateSquare
{
    _squareAnimating = YES;

    [_squareView setCenter:self.view.center];
    [_squareView setBackgroundColor:[UIColor orangeColor]];
    [_squareView setTransform:CGAffineTransformIdentity];

    //
    // Move Animation Node
    
    JSAnimationNode *moveNode = [JSAnimationNode animationNodeWithAnimations:^{
        
        _squareView.center = CGPointMake( self.view.center.x, self.view.center.y - 180.0f);
        
    } options:UIViewAnimationOptionCurveEaseInOut duration:1.0f];

    //
    // Rotate Animation Node
    
    JSAnimationNode *rotateNode = [JSAnimationNode animationNodeWithAnimations:^{
        
        _squareView.transform = CGAffineTransformRotate( _squareView.transform, -M_PI);
        
    } options:UIViewAnimationOptionCurveEaseInOut duration:1.0f];
    
    //
    // Scale Animation Node
    
    JSAnimationNode *growNode = [JSAnimationNode animationNodeWithAnimations:^{
        
        _squareView.transform = CGAffineTransformScale( _squareView.transform, 3.0f, 3.0f);
        
    } options:UIViewAnimationOptionCurveEaseIn duration:1.0f];
    
    //
    // Color Animation Node
    
    JSAnimationNode *colorNode = [JSAnimationNode animationNodeWithAnimations:^{
        
        _squareView.backgroundColor = [UIColor brownColor];
        
    } options:UIViewAnimationOptionCurveEaseIn duration:1.0f];
    

    JSAnimationNode *asyncronousNode = [JSAnimationNode animationGroupWithNodes:@[ moveNode, rotateNode, growNode, colorNode]];
    
    
    [UIView animateNode:asyncronousNode withCompletionBlock:^(BOOL finished) {
        
        _squareAnimating = NO;
    }];
}

-(void)animate:(UIGestureRecognizer*)recognizer
{
    if (_squareAnimating == NO)
        [self animateSquare];
}

@end
