//
//  ViewController.m
//  test
//
//  Created by matz on 2014/12/11.
//  Copyright (c) 2014年 matz. All rights reserved.
//

#import "ViewController.h"
#import "GMCPagingScrollView.h"

static NSString * const kPageIdentifier = @"Page";

@interface ViewController ()<GMCPagingScrollViewDataSource>

@property (nonatomic, strong) GMCPagingScrollView *pagingScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pagingScrollView = [[GMCPagingScrollView alloc] initWithFrame:self.view.bounds];
    self.pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.pagingScrollView.dataSource = self;
    self.pagingScrollView.infiniteScroll = YES;
    self.pagingScrollView.interpageSpacing = 0;
    [self.view addSubview:self.pagingScrollView];
    
    [self.pagingScrollView registerClass:[UIView class] forReuseIdentifier:kPageIdentifier];
    
    [self.pagingScrollView reloadData];

}

#pragma mark - GMCPagingScrollViewDataSource

- (NSUInteger)numberOfPagesInPagingScrollView:(GMCPagingScrollView *)pagingScrollView {
    return 3;
}

- (UIView *)pagingScrollView:(GMCPagingScrollView *)pagingScrollView pageForIndex:(NSUInteger)index {
    UIView *page = [pagingScrollView dequeueReusablePageWithIdentifier:kPageIdentifier];
    
    switch (index) {
        case 0:
            page.backgroundColor = [UIColor redColor];
            break;
        case 1:
            page.backgroundColor = [UIColor greenColor];
            break;
        case 2:
            page.backgroundColor = [UIColor blueColor];
            break;
    }
    
    return page;
}

@end
