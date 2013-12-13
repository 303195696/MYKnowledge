//
//  ViewController.m
//  makeFire
//
//  Created by JUN ZHANG on 13-12-4.
//  Copyright (c) 2013年 JUN ZHANG. All rights reserved.
//

#import "ViewController.h"

#define KscreenWhight [UIScreen mainScreen].bounds.size.width
#define KscreenHight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
{
    NSMutableArray *enamyMutArr;
    UIImageView *enameyImageView;
    EnemyPlan *enmyplan;
    int imgW;
    int imgH;
    UIImageView *bagImageView1;
    UIImageView *bagImageView2;
    NSTimer *timer;
    int planeX;
    int planeY;
    int direction;
    IBOutlet UIButton *upBtn;
    IBOutlet UIImageView *planeImgView;
    IBOutlet UIButton *rightBtn;
    IBOutlet UIButton *leftBtn;
    IBOutlet UIButton *downBtm;
    NSMutableArray *bulletMutArray;
}
- (IBAction)planeMove:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bagImageView1 = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    bagImageView1.image = [UIImage imageNamed:@"backgroud-01"];
    bagImageView1.tag = 01;
    [self.view addSubview:bagImageView1];
    
    bagImageView2 = [[[UIImageView alloc] initWithFrame:CGRectMake(0,-[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)] autorelease];
    bagImageView2.image = [UIImage imageNamed:@"backgroud-01"];
    bagImageView1.tag = 02;
    [self.view addSubview:bagImageView2];
    [self.view sendSubviewToBack:bagImageView1];
    [self.view sendSubviewToBack:bagImageView2];
    
    enamyMutArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < 20; i ++)
    {
        NSString *name = [NSString stringWithFormat:@"birds000%d",i + 1];
        if (i > 6) {
            name = [NSString stringWithFormat:@"birds000%d",i % 6];
        }
        UIImage *enamyImage = [UIImage imageNamed:name];
        imgW = enamyImage.size.width;
        imgH = enamyImage.size.height;
        enmyplan = [[EnemyPlan alloc] initWithImage:enamyImage];
        enmyplan.frame = CGRectMake(0, -imgH, imgW, imgH);
        [self.view addSubview:enmyplan];
        [enamyMutArr addObject:enmyplan];
    }

    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(onTime) userInfo:nil repeats:YES];
    planeY = planeImgView.frame.origin.y;
    planeX = planeImgView.frame.origin.x;
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appAcitvie:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    bulletMutArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i = 0; i < 20; i ++)
    {
        UIImage *bullet = [UIImage imageNamed:@"planeBullet.png"];
        EnemyPlan *imageView = [[EnemyPlan alloc] initWithImage:bullet];
        imageView.frame = CGRectMake(0, -bullet.size.height , bullet.size.width, bullet.size.height);
        imageView.use = NO;
        [self.view addSubview:imageView];
        [bulletMutArray addObject:imageView];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:nil];
    [planeImgView release];
    [rightBtn release];
    [upBtn release];
    [downBtm release];
    [leftBtn release];
    [super dealloc];
}

#pragma mark Notification
- (void)appEnterBackground:(NSNotification *)notify
{
    [timer invalidate];
}

- (void)appAcitvie:(NSNotification *)notify
{


}

static float hight = 0;
- (void)animate:(UIImageView *)bagImageView
{
    hight = bagImageView.frame.origin.y;
    hight = hight + 0.5;
    if (hight == KscreenHight)
    {
        hight = -KscreenHight;
    }
    bagImageView.frame = CGRectMake(0, hight, KscreenWhight, KscreenHight);
}
static int count = 0;
- (void)onTime
{
    [self animate:bagImageView1];
    [self animate:bagImageView2];
    count ++;
    if (count > 20)
    {
        [self findEnamy];
        count = 0;
    }
    [self enmyDown];
    [self planeMoving];
    [self planeFire];
}

- (void)findEnamy
{
    for (int i = 0; i < [enamyMutArr count]; i ++)
    {
        EnemyPlan *enmyPlan = [[enamyMutArr objectAtIndex:i] retain];
        
        if (enmyPlan.use == NO) {
            enmyPlan.use = YES;
            enmyPlan.x = arc4random() % (320 - imgW);
            enmyPlan.y = -imgH;
            enmyPlan.frame = CGRectMake(enmyPlan.x, enmyPlan.y, imgW, imgH);
            break;
        }
    }
}

- (void)enmyDown
{
    for (EnemyPlan *enmy in enamyMutArr)
    {
        if (enmy.use == YES) {
            enmy.y += 3;
            if (enmy.y > [UIScreen mainScreen].bounds.size.height)
            {
                enmy.use = NO;
            }
            enmy.frame = CGRectMake(enmy.x, enmy.y, imgW, imgH);
            for (EnemyPlan *bullet in bulletMutArray) {
                if (bullet.use == YES)
                {
                    if (CGRectIntersectsRect(enmy.frame, bullet.frame)) {
                        enmy.use = NO;
                        bullet.use = NO;
                        UIImageView *bombImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"b2"]];
                        bombImageView.frame = enmy.frame;
                        bombImageView.backgroundColor = [UIColor clearColor];
                        [self.view addSubview:bombImageView];
                        [UIView beginAnimations:nil context:nil];
                        [UIView setAnimationDuration:1];
                        [UIView setAnimationDelegate:self];
                        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
                        bombImageView.alpha = 0;
                        [UIView commitAnimations];
                        
                        enmy.frame = CGRectMake(0, -enmy.frame.size.height, enmy.frame.size.width, enmy.frame.size.height);
                        bullet.frame = CGRectMake(0, -bullet.frame.size.height, bullet.frame.size.width, bullet.frame.size.height);
                        break;
                    }
                }
            }
        }
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	UIImageView *tempBombView = (UIImageView *)context;
	
	[tempBombView removeFromSuperview];
	
}

- (IBAction)planeMove:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    direction = btn.tag;
}

- (void)planeMoving
{
    switch (direction)
    {
        case 1:
        {
            planeY -= 2;
            if (planeY <= 0)
            {
                planeY = 0;
            }
        }
            break;
        case 2:
        {
            planeX += 2;
			if (planeX >= KscreenWhight - planeImgView.frame.size.width)
			{
				planeX = KscreenWhight - planeImgView.frame.size.width;
			}
        }
            break;
        case 3:
        {
            planeY += 2;
            if (planeY >= KscreenHight - planeImgView.frame.size.height)
            {
                planeY = KscreenHight - planeImgView.frame.size.height;
            }
           
        }
            break;
        case 4:
        {
            planeX -= 2;
			if (planeX <= 0)
			{
				planeX = 0;
			}
        }
            break;
            
        default:
            break;
    }
    planeImgView.frame = CGRectMake(planeX, planeY, planeImgView.frame.size.width, planeImgView.frame.size.height);
}

- (IBAction)planeMoveStope:(id)sender
{
    direction = 0;
}

- (void)planeFire
{
    static int count1;
    count1 ++;
    if (count1 > 20)
    {
        count1 = 0;
        [self findUnusedBullet];
    }
    
    [self bulletMove];
}

- (void)bulletMove
{
    for (EnemyPlan *bullet in bulletMutArray)
    {
        if (bullet.use)
        {
            bullet.y -= 2;
            if (bullet.y <= -bullet.frame.size.height)
            {
                bullet.use = NO;
            }
            bullet.frame = CGRectMake(bullet.x, bullet.y, bullet.frame.size.width, bullet.frame.size.height);
        }
    }
}

- (void)findUnusedBullet
{
    for (EnemyPlan *bullet in bulletMutArray)
    {
        if (!bullet.use)
        {
            bullet.x = planeImgView.frame.origin.x + planeImgView.frame.size.width / 2 - bullet.frame.size.width / 2;
            bullet.y = planeImgView.frame.origin.y - bullet.frame.size.height;
            bullet.use = YES;
            break;
        }
    }
}

- (void)viewDidUnload {
    [planeImgView release];
    planeImgView = nil;
    [rightBtn release];
    rightBtn = nil;
    [upBtn release];
    upBtn = nil;
    [downBtm release];
    downBtm = nil;
    [leftBtn release];
    leftBtn = nil;
    [super viewDidUnload];
}
@end
