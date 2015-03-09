//
//  UIView+JSAnimate.h
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

#import <UIKit/UIKit.h>

typedef UIView*(^SelectedViewCreationBlock)(void);
typedef void(^UIViewAnimationBlock)(void);

// BM: Need to think about pause/resume cancel.
// BM: Probably would require a context or handle being passed back from animateNode(s)
// BM: Wonder if I can do a repeatCount here??



@interface JSAnimationNode : NSObject <NSCopying>

// BM: best to animate using class methods, but can also update these properties after creation/copy.
@property (nonatomic, assign) UIViewAnimationOptions options;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval delay;

+(JSAnimationNode*)animationNodeWithAnimations:(void(^)(void))animations options:(UIViewAnimationOptions)options duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
+(JSAnimationNode*)animationNodeWithAnimations:(void(^)(void))animations options:(UIViewAnimationOptions)options duration:(NSTimeInterval)duration;
+(JSAnimationNode*)animationNodeWithAnimations:(void(^)(void))animations duration:(NSTimeInterval)duration;

+(JSAnimationNode*)animationSequenceWithNodes:(NSArray*)nodes;
+(JSAnimationNode*)animationGroupWithNodes:(NSArray*)nodes;

@end



@interface UIView (JSAnimate)

+(void)animateNode:(JSAnimationNode*)animationNode;
+(void)animateNode:(JSAnimationNode*)animationNode withCompletionBlock:(void (^)(BOOL finished))completionBlock;

+(void)animateNodes:(NSArray*)animationNodes;
+(void)animateNodes:(NSArray*)animationNodes withCompletionBlock:(void (^)(BOOL finished))completionBlock;

@end
