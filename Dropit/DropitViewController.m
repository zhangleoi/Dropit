//
//  DropitViewController.m
//  Dropit
//
//  Created by 张磊 on 15/10/28.
//  Copyright © 2015年 张磊. All rights reserved.
//

#import "DropitViewController.h"
#import "DropBehavior.h"
#import "BezierPathView.h"
@interface DropitViewController ()<UIDynamicAnimatorDelegate>
@property (weak, nonatomic) IBOutlet BezierPathView *gameView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) DropBehavior *dropBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *attachment;
@property (strong, nonatomic) UIView *droppingView;
@end

@implementation DropitViewController

static const CGSize DROP_SIZE = {40,40};


- (IBAction)tap:(UITapGestureRecognizer *)sender {

    [self drop];
    
}
- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    
    
    CGPoint gesturePoint = [sender locationInView:self.gameView];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self attachDroppingViewToPoint:gesturePoint];
        
    }else if (sender.state == UIGestureRecognizerStateChanged)
    {
        self.attachment.anchorPoint = gesturePoint;
        
    }else if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self.animator removeBehavior:self.attachment];
        self.gameView.path = nil;
    
    }
    
    
}
-(void)attachDroppingViewToPoint:(CGPoint )anchorPoint
{
    if (self.droppingView) {
        self.attachment = [[UIAttachmentBehavior alloc]initWithItem:self.droppingView attachedToAnchor:anchorPoint];
        UIView *droppingView = self.droppingView;
        __weak DropitViewController *weakSelf = self;
        weakSelf.attachment.action = ^{
            UIBezierPath *path = [[UIBezierPath alloc]init];
            [path moveToPoint:weakSelf.attachment.anchorPoint];
            [path addLineToPoint:droppingView.center];
            weakSelf.gameView.path = path;
        };
        self.droppingView = nil;
        [self.animator addBehavior:self.attachment];
    }

}
-(UIDynamicAnimator *)animator
{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.gameView];
        _animator.delegate = self;
    }
    return _animator;
}
-(void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    [self removeCompleteRow];

}
-(BOOL)removeCompleteRow
{
    NSMutableArray *dropsToRemove = [[NSMutableArray alloc]init];
    
    for (CGFloat y = self.gameView.bounds.size.height - DROP_SIZE.height/2 ; y > 0; y -= DROP_SIZE.height) {
        BOOL rowIsComplete = YES;
        NSMutableArray *dropsFound = [[NSMutableArray alloc]init];
        for (CGFloat x = DROP_SIZE.width/2 ; x <= self.gameView.bounds.size.width - DROP_SIZE.width/2; x += DROP_SIZE.width) {
            UIView *hitView = [self.gameView hitTest:CGPointMake(x, y) withEvent:NULL];
            if ([hitView superview] == self.gameView) {
                [dropsFound addObject:hitView];
            }else
            {
                rowIsComplete = NO;
                break;
            }
        }
        if (![dropsFound count]) break;
        if (rowIsComplete)  [dropsToRemove addObjectsFromArray:dropsFound];
    }
    
    if ([dropsToRemove count]) {
        for (UIView *drop in dropsToRemove) {
            [self.dropBehavior removeItem:drop];
        }
        [self animateRemovingDrops:dropsToRemove];
    }
    
    
    return NO;
}
-(void)animateRemovingDrops:(NSArray *)dropsToRemove
{
   [UIView animateWithDuration:1.0 animations:^{
       for (UIView *drop in dropsToRemove) {
           int x = (arc4random()%(int)(self.gameView.bounds.size.width*5) - (int)self.gameView.bounds.size.width*2);
           int y = self.gameView.bounds.size.height;
           drop.center = CGPointMake(x, -y);
       }
       
   } completion:^(BOOL finished) {
       [dropsToRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];
       
   }];
}

-(DropBehavior *)dropBehavior
{
    if (!_dropBehavior) {
        _dropBehavior = [[DropBehavior alloc]init];
        [self.animator addBehavior:_dropBehavior];
    }
    return  _dropBehavior;
}
-(void)drop
{
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = DROP_SIZE;
    int x = (arc4random()%(int)self.gameView.bounds.size.width) / DROP_SIZE.width ;
    frame.origin.x = x * DROP_SIZE.width;
    
    UIView *dropView = [[UIView  alloc]initWithFrame:frame];
    dropView.backgroundColor = [self randomColor];
    [self.gameView addSubview:dropView];
    
    self.droppingView = dropView;
    
    [self.dropBehavior addItem:dropView];
  
}
-(UIColor *)randomColor
{
    switch (arc4random()%5) {
            case 0: return [UIColor greenColor];
            case 1: return [UIColor blueColor];
            case 2: return [UIColor orangeColor];
            case 3: return [UIColor redColor];
            case 4: return [UIColor purpleColor];
    }
    return [UIColor blackColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
