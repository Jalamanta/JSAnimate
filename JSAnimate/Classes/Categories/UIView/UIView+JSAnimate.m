//
//  UIView+JSAnimate.m
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


#import "UIView+JSAnimate.h"

@class JSAnimationSequenceNode;


typedef void(^UIViewCompletionBlock)(BOOL finished);



@interface JSAnimationNode ()

@property (nonatomic, copy) UIViewAnimationBlock animations;

-(id)copyWithZone:(NSZone *)zone;

@end



@interface JSAnimationSequenceNode : JSAnimationNode <NSCopying>

@property (nonatomic, copy) NSArray *nodes;

+(JSAnimationSequenceNode*)animationSequenceWithNodes:(NSArray*)nodes;

-(id)copyWithZone:(NSZone *)zone;

@end


@interface JSAnimationGroupNode : JSAnimationNode <NSCopying>

@property (nonatomic, copy) NSArray *nodes;

+(JSAnimationGroupNode*)animationGroupWithNodes:(NSArray*)nodes;

-(id)copyWithZone:(NSZone *)zone;

@end



@implementation JSAnimationNode

+(JSAnimationNode*)animationNodeWithAnimations:(void(^)(void))animations options:(UIViewAnimationOptions)options duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    JSAnimationNode *node = [JSAnimationNode new];
    [node setAnimations:animations];
    [node setOptions:options];
    [node setDuration:duration];
    [node setDelay:delay];
    
    return node;
}

+(JSAnimationNode*)animationNodeWithAnimations:(void(^)(void))animations options:(UIViewAnimationOptions)options duration:(NSTimeInterval)duration
{
    return [JSAnimationNode animationNodeWithAnimations:animations options:0 duration:duration delay:0];
}

+(JSAnimationNode*)animationNodeWithAnimations:(void(^)(void))animations duration:(NSTimeInterval)duration
{
    return [JSAnimationNode animationNodeWithAnimations:animations options:0 duration:duration delay:0];
}

+(JSAnimationNode*)animationSequenceWithNodes:(NSArray*)nodes
{
    return [JSAnimationSequenceNode animationSequenceWithNodes:nodes];
}

+(JSAnimationNode*)animationGroupWithNodes:(NSArray*)nodes
{
    return [JSAnimationGroupNode animationGroupWithNodes:nodes];
}

-(id)copyWithZone:(NSZone*)zone
{
    JSAnimationNode *node = [JSAnimationNode new];
    [node setAnimations:self.animations];
    [node setOptions:self.options];
    [node setDuration:self.duration];
    [node setDelay:self.delay];
    
    return node;
}

@end



@implementation JSAnimationSequenceNode

+(JSAnimationSequenceNode*)animationSequenceWithNodes:(NSArray*)nodes
{
    JSAnimationSequenceNode *arrayNode = [JSAnimationSequenceNode new];
    [arrayNode setNodes:nodes];
    
    return arrayNode;
}

-(id)copyWithZone:(NSZone*)zone
{
    JSAnimationSequenceNode *node = [JSAnimationSequenceNode new];
    [node setNodes:self.nodes];
    
    return node;
}

@end


@implementation JSAnimationGroupNode

+(JSAnimationGroupNode*)animationGroupWithNodes:(NSArray*)nodes
{
    JSAnimationGroupNode *groupNode = [JSAnimationGroupNode new];
    [groupNode setNodes:nodes];
    
    return groupNode;
}

-(id)copyWithZone:(NSZone*)zone
{
    JSAnimationSequenceNode *node = [JSAnimationSequenceNode new];
    [node setNodes:self.nodes];
    
    return node;
}

@end


@implementation UIView (JSAnimate)

+(void)animateNode:(JSAnimationNode*)animationNode
{
    [self animateNode:animationNode withCompletionBlock:nil];
}

+(void)animateNode:(JSAnimationNode*)animationNode withCompletionBlock:(void (^)(BOOL finished))completionBlock
{
    if ([animationNode isKindOfClass:[JSAnimationSequenceNode class]])
    {
        [self animateArrayNode:(JSAnimationSequenceNode*)animationNode withCompletionBlock:completionBlock];
    }
    else if ([animationNode isKindOfClass:[JSAnimationGroupNode class]])
    {
        [self animateGroupNode:(JSAnimationGroupNode*)animationNode withCompletionBlock:completionBlock];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:animationNode.duration
                              delay:animationNode.delay
                            options:animationNode.options
                         animations:animationNode.animations
                         completion:completionBlock];
        });
    }
}

// BM: Private method
+(void)animateArrayNode:(JSAnimationSequenceNode*)arrayNode withCompletionBlock:(void (^)(BOOL finished))completionBlock
{
    NSArray *nodes = arrayNode.nodes;

    [self animateNodes:nodes withCompletionBlock:completionBlock];
}

// BM: Private method
+(void)animateGroupNode:(JSAnimationGroupNode*)groupNode withCompletionBlock:(void (^)(BOOL finished))completionBlock
{
    NSArray *nodes = groupNode.nodes;
    
    dispatch_group_t animationGroup = dispatch_group_create();
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [nodes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            dispatch_group_enter(animationGroup);
            
            [self animateNode:(JSAnimationNode*)obj withCompletionBlock:^(BOOL finished) {
                
                dispatch_group_leave(animationGroup);
            }];
        }];
        
        dispatch_group_wait(animationGroup, DISPATCH_TIME_FOREVER);
        
        if (completionBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completionBlock(YES);
            });
        }
    });
}

+(void)animateNodes:(NSArray*)animationNodes withCompletionBlock:(void (^)(BOOL finished))completionBlock
{
    if (animationNodes.count > 0)
    {
        JSAnimationNode *node = [animationNodes firstObject];
        
        NSMutableArray *remaingNodes = [NSMutableArray arrayWithArray:animationNodes];
        [remaingNodes removeObjectAtIndex:0];
     
        UIViewCompletionBlock internalCompletionBlock = ^(BOOL finished){
           
            if (finished)
            {
                if (remaingNodes.count > 0)
                    [self animateNodes:remaingNodes withCompletionBlock:completionBlock];
                else
                    if (completionBlock) completionBlock( YES);
            }
            else if (completionBlock) completionBlock( NO);
        };
        
        if ([node isKindOfClass:[JSAnimationSequenceNode class]])
        {
            [self animateArrayNode:(JSAnimationSequenceNode*)node withCompletionBlock:^(BOOL finished) {
                
                internalCompletionBlock( finished);
            }];
        }
        else if ([node isKindOfClass:[JSAnimationGroupNode class]])
        {
            [self animateGroupNode:(JSAnimationGroupNode*)node withCompletionBlock:^(BOOL finished) {
               
                internalCompletionBlock( finished);
            }];
        }
        else
        {
            [self animateNode:node withCompletionBlock:^(BOOL finished) {

                internalCompletionBlock( finished);
            }];
        }
    }
    else if (completionBlock) completionBlock( YES);
}

+(void)animateNodes:(NSArray*)animationNodes
{
    [self animateNodes:animationNodes withCompletionBlock:nil];
}

@end
