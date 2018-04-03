//
//  SaViewController.m
//  重力感应器
//
//  Created by apple on 2018/4/3.
//  Copyright © 2018年 范文哲. All rights reserved.
//

#import "SaViewController.h"
#import <CoreMotion/CoreMotion.h>
@interface SaViewController ()<UIScrollViewDelegate>{
    
    NSTimeInterval updateInterval;
    CGFloat  setx;//scroll的动态偏移量
    
}
@property (nonatomic,strong) CMMotionManager *mManager;

@property (nonatomic , strong)UIScrollView *myScrollView;

@property (nonatomic , assign)CGFloat offsetX;//初始偏移量

@property (nonatomic , assign)NSInteger offset;
@end

@implementation SaViewController

- (void)viewDidAppear:(BOOL)animated_{
    
    [super viewDidAppear:animated_];
    //在界面已经显示后在调用方法(优化)
    [self startUpdateAccelerometerResult:0];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self createView];
}
- (void)createView{
    
    //collectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    UICollectionView *myCollection = [[UICollectionView alloc]initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:flowLayout];
    myCollection.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:myCollection];
    
    
    
    _myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 22, self.view.frame.size.width, 100)];
    _myScrollView.backgroundColor = [UIColor lightGrayColor];
    _myScrollView.delegate = self;
    [self.view addSubview:_myScrollView];
    
    
    for (int i = 0; i < 8; i ++) {
        
        NSString *name = [NSString stringWithFormat:@"%d.png",i + 1];
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(5 + 885 * i, 10, 80, 80)];
        image.image = [UIImage imageNamed:name];
        image.backgroundColor = [UIColor orangeColor];
        image.layer.masksToBounds = YES;
        image.layer.cornerRadius = 40;
        [_myScrollView addSubview:image];
        //偏移量为最后 image 的 frame + origin
        _myScrollView.contentSize = CGSizeMake (image.frame.size.width + image.frame.origin.x, 10);
    }
    
}

//手指触碰时
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    _offsetX = scrollView.contentOffset.x;
    [self stopUpdate];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //优化处理
    setx = scrollView.contentOffset.x;
    
    _offset = scrollView.contentOffset.x - _offsetX;
    
    if (_offset > 0) {
        
        //left
        
    }else{
        
        //right
        
    }
    
    
}
//手指离开时
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [self startUpdateAccelerometerResult:0];
    
}

#pragma mark - 重力感应
- (CMMotionManager *)mManager
{
    if (!_mManager) {
        updateInterval = 1.0/15.0;
        _mManager = [[CMMotionManager alloc] init];
    }
    return _mManager;
}
//开始
- (void)startUpdateAccelerometerResult:(void (^)(NSInteger))result
{
    
    if ([self.mManager isAccelerometerAvailable] == YES) {
        //回调会一直调用,建议获取到就调用下面的停止方法，需要再重新开始，当然如果需求是实时不间断的话可以等离开页面之后再stop
        [self.mManager setAccelerometerUpdateInterval:updateInterval];
        [self.mManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
         {
             double x = accelerometerData.acceleration.x;
             double y = accelerometerData.acceleration.y;
             if (fabs(y) >= fabs(x))
             {//前后
                 if (y >= 0){
                     //Down
                 }
                 else{
                     //Portrait
                 }
             } else { //左右
                 
                 if (x >= 0){
                     
                     setx += 10;
                     
                     if (setx <= 360) {
                         //由于以10为单位改变 contentOffset, 会出现顿的现象,加上动画就可解决这个问题
                         [UIView animateWithDuration:0.1 animations:^{
                             
                             _myScrollView.contentOffset = CGPointMake(setx, 0);
                         }];
                         //模仿 scroll 的回弹效果
                         if (setx == 360) {
                             
                             [UIView animateWithDuration:0.5 animations:^{
                                 
                                 _myScrollView.contentOffset = CGPointMake(setx + 50, 0);
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [UIView animateWithDuration:0.5 animations:^{
                                     
                                     _myScrollView.contentOffset = CGPointMake(setx , 0);
                                     
                                 }];
                                 
                             }];
                             
                         }
                         
                     }else{
                         
                         setx = 360;
                     }
                 }else{
                     
                     setx -= 10;
                     
                     if (setx >= 0) {
                         
                         [UIView animateWithDuration:0.1 animations:^{
                             
                             _myScrollView.contentOffset = CGPointMake(setx, 0);
                             
                         }];
                         
                         //模仿 scroll 的回弹效果
                         if (setx == 0) {
                             [UIView animateWithDuration:0.5 animations:^{
                                 
                                 _myScrollView.contentOffset = CGPointMake(setx - 50, 0);
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [UIView animateWithDuration:0.5 animations:^{
                                     
                                     _myScrollView.contentOffset = CGPointMake(setx, 0);
                                     
                                 }];
                                 
                             }];
                             
                         }
                         
                     }else{
                         
                         setx = 0;
                         
                     }
                 }
             }
         }];
    }
}
//停止感应方法
- (void)stopUpdate
{
    if ([self.mManager isAccelerometerActive] == YES)
    {
        [self.mManager stopAccelerometerUpdates];
    }
}
//离开页面后停止(移除 mManager)
- (void)dealloc
{
    //制空,防止野指针
    _mManager = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)button:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
