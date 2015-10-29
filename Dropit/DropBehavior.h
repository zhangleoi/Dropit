//
//  DropBehavior.h
//  Dropit
//
//  Created by 张磊 on 15/10/28.
//  Copyright © 2015年 张磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropBehavior : UIDynamicBehavior

-(void)addItem:(id <UIDynamicItem>)item;


-(void)removeItem:(id <UIDynamicItem>)item;
@end
