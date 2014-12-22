//
//  TodayViewController.m
//  Widget
//
//  Created by matz on 2014/12/01.
//  Copyright (c) 2014年 matz. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *barView;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@property (nonatomic, assign) unsigned long long fileSystemSize;
@property (nonatomic, assign) unsigned long long freeSize;
@property (nonatomic, assign) unsigned long long usedSize;
@property (nonatomic, assign) double usedRate;

// Macro for NSUserDefaults key
#define RATE_KEY @"kUDRateUsed"

#define kWClosedHeight   37.0
#define kWExpandedHeight 106.0


@end

@implementation TodayViewController

- (void)updateInterface
{
    double rate = self.usedRate; // retrieve the cached value
    self.percentLabel.text =
    [NSString stringWithFormat:@"%.1f%%", (rate * 100)];
    self.barView.progress = rate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateInterface];
    
    // new
    [self setPreferredContentSize:CGSizeMake(0.0, kWClosedHeight)];
    [self.detailsLabel setAlpha:0.0];
}

// 詳細ラベル
-(void)updateDetailsLabel
{
    NSByteCountFormatter *formatter =
    [[NSByteCountFormatter alloc] init];
    [formatter setCountStyle:NSByteCountFormatterCountStyleFile];
    
    self.detailsLabel.text =
    [NSString stringWithFormat:
     @"Used:\t%@\nFree:\t%@\nTotal:\t%@",
     [formatter stringFromByteCount:self.usedSize],
     [formatter stringFromByteCount:self.freeSize],
     [formatter stringFromByteCount:self.fileSystemSize]];
}

// タッチイベント
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateDetailsLabel];
    [self setPreferredContentSize:
     CGSizeMake(0.0, kWExpandedHeight)];
}

// アニメーション
-(void)viewWillTransitionToSize:(CGSize)size
      withTransitionCoordinator:
(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:
     ^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self.detailsLabel setAlpha:1.0];
     } completion:nil];
}


- (void)updateSizes
{
    // Retrieve the attributes from NSFileManager
    NSDictionary *dict = [[NSFileManager defaultManager]
                          attributesOfFileSystemForPath:NSHomeDirectory()
                          error:nil];
    
    // Set the values
    self.fileSystemSize = [[dict valueForKey:NSFileSystemSize]
                           unsignedLongLongValue];
    self.freeSize       = [[dict valueForKey:NSFileSystemFreeSize]
                           unsignedLongLongValue];
    self.usedSize       = self.fileSystemSize - self.freeSize;
}


// @implementation
- (double)usedRate
{
    return [[[NSUserDefaults standardUserDefaults]
             valueForKey:RATE_KEY] doubleValue];
}

- (void)setUsedRate:(double)usedRate
{
    NSUserDefaults *defaults =
    [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithDouble:usedRate]
                forKey:RATE_KEY];
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {

    // 更新された際に
    [self updateSizes];
    
    double newRate = (double)self.usedSize / (double)self.fileSystemSize;
    
    if (newRate - self.usedRate < 0.0001) {
        completionHandler(NCUpdateResultNoData);
    } else {
        [self setUsedRate:newRate];
        [self updateInterface];
        completionHandler(NCUpdateResultNewData);
    }
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins
{
    margins.bottom = 10.0;
    return margins;
}


// Widget余白を消したい場合
//- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:
//(UIEdgeInsets)defaultMarginInsets
//{
//    return UIEdgeInsetsZero;
//}

@end
