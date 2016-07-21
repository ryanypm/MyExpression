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


@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.scrollEnabled = NO;
    tableView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView = tableView;
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.frame = CGRectMake(0, 0, viewWidth, self.view.height);
    webView.delegate = self;
    webView.scrollView.delegate = self;
    self.webView = webView;
    [self loadHtml];
    [self.view addSubview:webView];
    
    [webView.scrollView addSubview:tableView];
    
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
    _tableView.y = scrollHeight;
    _webView.scrollView.contentSize = CGSizeMake(0, scrollHeight + self.view.height);
    
}

#pragma mark click
- (void)click:(UIButton *)button{
    NSLog(@"button");
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
        if (top >= _webView.scrollView.contentSize.height - self.view.height) {
            state = 2;
        }
        if (top > 30) {
            _webView.scrollView.bounces = NO;
        }else{
            _webView.scrollView.bounces = YES;
        }
        _tableView.scrollEnabled = (state == 2);
        _webView.scrollView.scrollEnabled = (state == 1);
        
    }else if([scrollView isKindOfClass:[UITableView class]]){
        if (top > (_tableView.contentSize.height - viewHeight - 10)) {
            _tableView.bounces = YES;
        }else{
            _tableView.bounces = NO;
        }
        NSLog(@"top = %f",top);
        if (top <= 0) {
            state = 1;
        }
        
        _tableView.scrollEnabled = (state == 2);
        _webView.scrollView.scrollEnabled = (state == 1);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
