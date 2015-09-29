//
//  ViewController.m
//  长按手势移动Cell
//
//  Created by GR on 15/9/28.
//  Copyright © 2015年 GR. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datas = [@[@"Get Milk!", @"Go to gym", @"Breakfast with Rita!", @"Call Bob", @"Pick up newspaper", @"Send an email to Joe", @"Read this tutorial!", @"Pick up flowers"] mutableCopy];
    
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    self.tableView.rowHeight = 60;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.tableView addGestureRecognizer:longPress];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    CGPoint pressLocation = [longPress locationInView:self.tableView];
    
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:pressLocation];
    
    static NSIndexPath *sourceIndexPath = nil;
    static UIView *snapShot = nil;
    
    if (!currentIndexPath) return;
    
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        if (currentIndexPath) {
            // 0. 记录选中的indexPath
            sourceIndexPath = currentIndexPath;
            
            // 1. 截取cell上的图片
            UITableViewCell *sourceCell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            snapShot = [self snapShotInView:sourceCell];
            snapShot.frame = sourceCell.frame;
            snapShot.alpha = 0;
            [self.tableView addSubview:snapShot];
            
            // 2. 对截图做动画,并隐藏cell
            [UIView animateWithDuration:0.5 animations:^{
                snapShot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                snapShot.alpha = 0.9;
                sourceCell.alpha = 0.0f;
                
                CGPoint o = snapShot.center;
                o.y = pressLocation.y;
                snapShot.center = o;
            } completion:^(BOOL finished) {
                sourceCell.hidden = YES;
            }];
        }
    }
    else if (longPress.state == UIGestureRecognizerStateChanged)
    {
        // 移动截图
        CGPoint o = snapShot.center;
        o.y = pressLocation.y;
        snapShot.center = o;
        
        if (![currentIndexPath isEqual:sourceIndexPath]) {
            // 数据交换
            [self.datas exchangeObjectAtIndex:currentIndexPath.row withObjectAtIndex:sourceIndexPath.row];
            
            // cell移动
            [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:currentIndexPath];
            
            // 更新indexPath
            sourceIndexPath = currentIndexPath;
        }
    }
    else if (longPress.state == UIGestureRecognizerStateEnded)
    {
        // 截图动画消失,并且显示cell
        UITableViewCell *sourceCell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
        sourceCell.hidden = NO;
        sourceCell.alpha = 0.0f;
        
        [UIView animateWithDuration:0.25 animations:^{
            snapShot.center = sourceCell.center;
            snapShot.transform = CGAffineTransformIdentity;
            sourceCell.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [snapShot removeFromSuperview];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseID = @"ID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}

- (UIView *)snapShotInView:(UIView *)inputView
{
    UIView *snapShot = [inputView snapshotViewAfterScreenUpdates:NO];
    snapShot.bounds = inputView.bounds;
    snapShot.layer.shadowOffset = CGSizeMake(-5, 0);
    snapShot.layer.shadowOpacity = 1;
    snapShot.layer.shadowRadius = 5.0;
    return snapShot;
}
@end
