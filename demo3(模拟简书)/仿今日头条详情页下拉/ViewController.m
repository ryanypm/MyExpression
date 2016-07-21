//
//  ViewController.m
//  仿今日头条详情页下拉
//
//  Created by ryan on 16/7/20.
//  Copyright © 2016年 ryan. All rights reserved.
//

#define viewSize self.view.frame.size
#define viewWidth viewSize.width
#define viewHeight viewSize.height

#import "ViewController.h"
#import "mycell.h"
#import "UIView+Extension.h"

@interface ViewController ()<UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    int state;
}

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIView *headerView;



@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, viewWidth, self.view.height+20);
    [self.view addSubview:headerView];
    headerView.clipsToBounds = YES;
    headerView.backgroundColor = [UIColor greenColor];
    self.headerView = headerView;
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.frame = CGRectMake(0, 0, viewWidth, self.view.height + 50);
    webView.delegate = self;
    webView.scrollView.delegate = self;
    self.webView = webView;
    webView.scrollView.backgroundColor = [UIColor greenColor];
    [headerView addSubview:webView];
    [self loadHtml];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableHeaderView = headerView;
    tableView.bounces = NO;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.scrollEnabled = NO;
    tableView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor redColor];
    bottomView.frame = CGRectMake(0, 667, self.view.width, 50);
    [webView.scrollView addSubview:bottomView];
    self.bottomView = bottomView;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 30, 100, 20);
    [button setTitle:@"评论" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blueColor];
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:button];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] init];
    indicatorView.frame = CGRectMake((viewWidth - 50) / 2, (viewHeight - 50) / 2, 50, 50);
    indicatorView.hidesWhenStopped = YES;
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:indicatorView];
    self.indicatorView = indicatorView;
    [indicatorView startAnimating];
    
    state = 1;
    
}

#pragma mark 加载html
- (void)loadHtml{
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"details" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [_webView loadHTMLString:htmlString baseURL:baseURL];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self.indicatorView stopAnimating];
    CGFloat scrollHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    _webView.scrollView.contentSize = CGSizeMake(0, scrollHeight + 80);
    _bottomView.y = scrollHeight;
    
}

#pragma mark click
- (void)click:(UIButton *)button{
    NSLog(@"点你妹");
}

#pragma mark tableView 行高
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"cell";
    mycell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[mycell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d",arc4random() % 100];
    
    return cell;
    
}

#pragma mark scrollview delegate (计算contentOffset的值，根据上下距离来决定bounces)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
     CGFloat top = scrollView.contentOffset.y;
     if (scrollView == _webView.scrollView) {
        if (top >= _webView.scrollView.contentSize.height - self.view.height - 50) {
            state = 2;
        }
        if (top > 30) {
            _webView.scrollView.bounces = NO;
        }else{
            _webView.scrollView.bounces = YES;
        }
        
    }else if([scrollView isKindOfClass:[UITableView class]]){
        if (top > (_tableView.contentSize.height - viewHeight - 10)) {
            _tableView.bounces = YES;
        }else{
            _tableView.bounces = NO;
        }
        if (top <= 0) {
            state = 1;
        }
    }
    
    _tableView.scrollEnabled = (state == 2);
    _webView.scrollView.scrollEnabled = (state == 1);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
