//
//  ViewController.m
//  sqlite3
//
//  Created by mac on 15-12-1.
//  Copyright (c) 2015年 Lispeng. All rights reserved.
//

#import "ViewController.h"
#import "LSPFMDBController.h"
#import <sqlite3.h>
#import "LSPShop.h"
@interface ViewController ()<UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *priceLabel;
@property (nonatomic, assign) sqlite3 *sqlite;
@property (strong,nonatomic) NSMutableArray *shops;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)storageShops;

- (IBAction)pushToFMDB;

@end

@implementation ViewController

- (NSMutableArray *)shops
{
    if (_shops == nil) {
        self.shops = [NSMutableArray array];
    }
    return _shops;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //添加搜索框
    [self addSearchBar];
    
    //创建数据库
    [self createSQLite3];
    
    //查询数据
    [self checkoutSqlite];
}

- (void)addSearchBar
{
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.frame = CGRectMake(0, 0, 320, 44);
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
}
/**
 *  创建数据库
 */
- (void)createSQLite3
{
    //存储数据地址的设置
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"shops.sqlite"];
    //打开数据库，没有数据库系统会自动创建一个数据库
    int states = sqlite3_open(path.UTF8String, &_sqlite);
    if (states == SQLITE_OK) {
        
        NSLog(@"打开数据库成功");
        //创建数据库表
        const char *sql = "CREATE TABLE IF NOT EXISTS t_shop(id integer PRIMARY KEY,name text NOT NULL,price real);";
        char *errmsg = NULL;
        sqlite3_exec(self.sqlite, sql, NULL, NULL, &errmsg);
        if (errmsg) {
            NSLog(@"创建表失败");
        }
        
    }else{
        NSLog(@"打开数据库失败");
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  插入数据
 */
- (IBAction)storageShops {
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_shop(name,price) VALUES('%@',%f)",self.nameLabel.text,self.priceLabel.text.doubleValue];
    sqlite3_exec(self.sqlite, sql.UTF8String, NULL, NULL, NULL);
    
    
    //刷新表格
    LSPShop *shop = [[LSPShop alloc] init];
    shop.name = self.nameLabel.text;
    shop.price = self.priceLabel.text;
    [self.shops addObject:shop];
    [self.tableView reloadData];
}

- (IBAction)pushToFMDB {
    
    LSPFMDBController *fmdb = [[LSPFMDBController alloc] init];
    [self presentViewController:fmdb animated:YES completion:nil];
}
/**
 *  查询数据
 */
- (void)checkoutSqlite
{
    const char *sql = "SELECT name,price FROM t_shop";
    
    sqlite3_stmt *stmt = NULL;
    
    int states = sqlite3_prepare_v2(self.sqlite, sql, -1, &stmt, NULL);
    
    if (states == SQLITE_OK) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            const char *name = (const char *)sqlite3_column_text(stmt, 0);
            const char *price = (const char *)sqlite3_column_text(stmt, 1);
            
            LSPShop *shop = [[LSPShop alloc] init];
            shop.name = [NSString stringWithUTF8String:name];
            shop.price = [NSString stringWithUTF8String:price];
            [self.shops addObject:shop];
        }
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark --UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //删除原有的所有数据
    [self.shops removeAllObjects];
    
    NSString *resultSQL = [NSString stringWithFormat:@"SELECT name,price FROM t_shop WHERE name LIKE '%%%@%%' OR price LIKE '%%%@%%';",searchText,searchText];
    //const char *sql = "SELECT name,price FROM t_shop";
    
    sqlite3_stmt *stmt = NULL;
    
    int states = sqlite3_prepare_v2(self.sqlite, resultSQL.UTF8String, -1, &stmt, NULL);
    
    if (states == SQLITE_OK) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            const char *name = (const char *)sqlite3_column_text(stmt, 0);
            const char *price = (const char *)sqlite3_column_text(stmt, 1);
            
            LSPShop *shop = [[LSPShop alloc] init];
            shop.name = [NSString stringWithUTF8String:name];
            shop.price = [NSString stringWithUTF8String:price];
            [self.shops addObject:shop];
        }
    }
    [self.tableView reloadData];
}

#pragma mark---UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shops.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"SQLite3";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    LSPShop *shop = self.shops[indexPath.row];
    cell.textLabel.text = shop.name;
    cell.detailTextLabel.text = shop.price;
    
    return cell;
}
@end
