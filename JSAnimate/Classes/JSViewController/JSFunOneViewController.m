//
//  JSFunOneViewController.m
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

#import "JSFunOneViewController.h"
#import "UIView+JSAnimate.h"

@interface JSFunOneViewController ()

@property (assign) BOOL squaresAnimating;

@end

@implementation JSFunOneViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animate:)]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self animateSquares];
}


#pragma mark - JSAnimationGroupNode Example

-(void)animateSquares
{
    NSMutableArray *squares = [NSMutableArray new];
    
    //
    CGFloat length =  ceilf(self.view.bounds.size.width / 10.0f);
    
    for (NSUInteger x=0; x < 10; x++)
        for (NSUInteger y=0; y < self.view.bounds.size.height / length; y++)
        {
            UIView *squareView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, length, length)];
            [squareView setCenter:CGPointMake(x*length + length/2.0f, y*length + length/2.0f)];
            [squareView setBackgroundColor:[UIColor orangeColor]];
            [self.view addSubview:squareView];
            [squares addObject:squareView];
        }
    
    _squaresAnimating = YES;
    
    JSAnimationNode *colorChangeNode = [JSAnimationNode
                                    animationNodeWithAnimations:^{
                                        
                                        for (UIView *squareView in squares)
                                            squareView.transform = CGAffineTransformMakeRotation( M_PI);
                                        
                                    } options:0 duration:1.0f];
    
    JSAnimationNode *scaleDownNode = [JSAnimationNode
                                      animationNodeWithAnimations:^{
                                          
                                          for (UIView *squareView in squares)
                                              squareView.transform = CGAffineTransformScale( squareView.transform, 0.001f, 0.001f);
                                          
                                      } options:0 duration:1.0f delay:1.0f];
    
    // BM: Make a copy of scaleDownNode that has a faster duration.
    
    JSAnimationNode *scaleDownQuicklyNode = [scaleDownNode copy];
    [scaleDownQuicklyNode setDuration:0.3f];
    [scaleDownQuicklyNode setDelay:0.0f];

    JSAnimationNode *scaleResetNode = [JSAnimationNode
                                      animationNodeWithAnimations:^{
                                          
                                          for (UIView *squareView in squares)
                                              squareView.transform = CGAffineTransformScale( squareView.transform, 1.0f, 1.0f);
                                          
                                      } options:0 duration:1.0f];
    
    // BM: Create an Animation Node to animate these two nodes asyncronously.
    
    JSAnimationNode *colorScaleResetArrayNode = [JSAnimationNode animationGroupWithNodes:@[colorChangeNode, scaleResetNode]];
    
    // BM: Create an Animation Node to animate these nodes syncronously (which includes an asyncronous node in the middle).
    
    JSAnimationNode *arrayNode = [JSAnimationNode animationSequenceWithNodes:@[ scaleDownNode, colorScaleResetArrayNode, scaleDownQuicklyNode]];
    
    // BM: Actually animate the arrayNode
    
    [UIView animateNode:arrayNode withCompletionBlock:^(BOOL finished) {
        
        _squaresAnimating = NO;
        
        [squares makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
}

-(void)animate:(UIGestureRecognizer*)recognizer
{
    if (_squaresAnimating == NO)
        [self animateSquares];
}


@end
