//
//  JSFunTwoViewController.m
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

#import "JSFunTwoViewController.h"
#import "UIView+JSAnimate.h"

static inline float radians( double degrees) { return degrees * M_PI / 180.0; }

#define isOdd( x) ((x) % 2 != 0)

@interface JSFunTwoViewController ()

@property (nonatomic, assign) BOOL circlesAnimating;

@end

@implementation JSFunTwoViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
 
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self animateCircles];
}

-(UIView*)createCircleViewWithRadius:(CGFloat)radius
{
    UIView *circleView = [UIView new];
    [circleView setBounds:CGRectMake( 0.0f, 0.0f, radius*2.0f, radius*2.0)];
    [[circleView layer] setCornerRadius:radius];
    [[circleView layer] setBorderWidth:1.0f];
    [[circleView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[circleView layer] setMasksToBounds:YES];
    
    return circleView;
}


-(void)animateCircles
{
    NSMutableArray *circles = [NSMutableArray new];
    
    CGFloat radius = 5;
    CGFloat difference = 0.5;
    for (NSUInteger i=0; i<=35; i++)
    {
        UIView *circleView = [self createCircleViewWithRadius:radius];
        [circleView setBackgroundColor:isOdd(i)?[UIColor orangeColor]:[UIColor yellowColor]];
        [[circleView layer] setBorderColor:isOdd(i)?[UIColor yellowColor].CGColor:[UIColor orangeColor].CGColor];
        [circleView setCenter:self.view.center];
        [self.view insertSubview:circleView atIndex:0];
        [circles addObject:circleView];
        
        radius += difference;
        if (i > 16) difference = -0.5;
    }
    
    NSMutableArray *circleNodes = [NSMutableArray new];
    
    __block NSUInteger circleIndex = 0;

    for (UILabel *circleView in circles)
    {
        circleView.alpha = 0.0f;
        
        CGPoint center = CGPointMake( self.view.center.x + (isOdd(circleIndex)?200:150) * cos(radians(circleIndex * 10)),
                                      self.view.center.y + (isOdd(circleIndex)?200:150) * sin(radians(circleIndex * 10)));
        
        circleIndex++;
        
        JSAnimationNode *circleNode = [JSAnimationNode
                                       animationNodeWithAnimations:^{
                                        
                                           circleView.center = center;
                                           circleView.alpha = 1.0f;
                                           circleView.transform = CGAffineTransformScale( circleView.transform, 5.0f, 5.0f);
                                       }
                                       options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                                       duration:1.5f
                                       delay:circleIndex * 0.05];
        
        [circleNodes addObject:circleNode];
        
    }
    
    JSAnimationNode *node = [JSAnimationNode animationGroupWithNodes:circleNodes];
    
    [UIView animateNode:node withCompletionBlock:^(BOOL finished) {
       
        [circles makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];

}




@end
