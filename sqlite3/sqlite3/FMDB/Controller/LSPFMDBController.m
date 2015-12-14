//
//  LSPFMDBController.m
//  sqlite3
//
//  Created by mac on 15-12-1.
//  Copyright (c) 2015年 Lispeng. All rights reserved.
/****************FMDB第三方框架测试******************/

#import "LSPFMDBController.h"
#import "FMDB.h"
@interface LSPFMDBController ()

@property (strong,nonatomic) FMDatabase *fmdb;

@end

@implementation LSPFMDBController

- (void)viewDidLoad {
    [super viewDidLoad];
  
     self.view.backgroundColor = [UIColor blueColor];
    [self addBtn];
    //创建数据库
    [self createDatabaseByFMDB];
    
    //插入数据
    [self insertFMDB];
    
    //查询数据
    [self query];
    
}
- (void)addBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 44);
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)backController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 *  利用FMDB框架创建数据库
 */
- (void)createDatabaseByFMDB
{
    //1.存储数据到沙盒目录
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"product.sqlite"];
    //创建数据库
    self.fmdb = [FMDatabase databaseWithPath:path];
    //打开数据库
    [self.fmdb open];
    
    //创建数据库表
    [self.fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS t_product(id integer PRIMARY KEY,name text NOT NULL,price real);"];
}
/**
 *  查询表中的数据
 */
- (void)query
{
    FMResultSet *set = [self.fmdb executeQuery:@"SELECT * FROM t_product"];
    while (set.next) {//不断往下取数据
        
        NSString *name = [set stringForColumn:@"name"];
        double price = [set doubleForColumn:@"price"];
        NSLog(@"name = %@,price = %f",name,price);
    }
}

/**
 *  插入数据
 */
- (void)insertFMDB
{
    for (int i = 0; i<100; i++) {
    NSString *name = [NSString stringWithFormat:@"iPhone-%d", i];
        [self.fmdb executeUpdateWithFormat:@"INSERT INTO t_product(name,price) VALUES(%@,%d)",name,arc4random() % 100];
    }
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
