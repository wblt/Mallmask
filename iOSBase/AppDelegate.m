//
//  AppDelegate.m
//  iOSBase
//
//  Created by mac on 2018/1/9.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTabBarController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//微信SDK头文件
#import "WXApi.h"
#import "BaseNavViewController.h"
#import "RootTestController.h"
//支付宝用
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate ()<UIApplicationDelegate,WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
	self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
	self.window.backgroundColor = [UIColor clearColor];
	[self.window makeKeyAndVisible];
	
	[self initShareSDK];// 微信支付、分享   QQ分享
	
	// 初始化本地话文件目录
	IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager]; // 获取类库的单例变量
	keyboardManager.enable = YES; // 控制整个功能是否启用
	keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
	keyboardManager.keyboardDistanceFromTextField = 10.0f; // 输入框距离键盘的距离
	
    BOOL testSwitch = true;
    if (testSwitch == false) {
        MainTabBarController *mainTabbar = [[MainTabBarController alloc] init];
        mainTabbar.selectIndex = 0;
        self.window.rootViewController = mainTabbar;
    } else {
        [self enterTest];
    }
    return YES;
}

- (void)initShareSDK {
#warning 还需要在 微信 支付宝平台  配置文件
	[ShareSDK registerActivePlatforms:@[
										@(SSDKPlatformTypeCopy),
										@(SSDKPlatformTypeWechat),
										@(SSDKPlatformTypeQQ),
										]
							 onImport:^(SSDKPlatformType platformType)
	 {
		 switch (platformType)
		 {
			 case SSDKPlatformTypeWechat:
				 [ShareSDKConnector connectWeChat:[WXApi class]];
				 break;
			 case SSDKPlatformTypeQQ:
				 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
				 break;
			 default:
				 break;
		 }
	 }
					  onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
	 {
#warning URL Types 中设置的是 ShareSDk 的scheme  正式版需要修改
		 switch (platformType)
		 {
			 case SSDKPlatformTypeWechat:
				 [appInfo SSDKSetupWeChatByAppId:@"wx4868b35061f87885"
									   appSecret:@"64020361b8ec4c99936c0e3999a9f249"];
				 break;
			 case SSDKPlatformTypeQQ:
				 [appInfo SSDKSetupQQByAppId:@"100371282"
									  appKey:@"aed9b0303e3ed1e27bae87c33761161d"
									authType:SSDKAuthTypeBoth];
				 break;
			 default:
				 break;
		 }
	 }];
	
}

-(void) onResp:(BaseResp*)resp
{
	if([resp isKindOfClass:[PayResp class]]){
		//支付返回结果，实际支付结果需要去微信服务器端查询
		switch (resp.errCode) {
			case WXSuccess:
				KPostNotification(kNOtificationName_WXPaySuccess, resp);
				break;
			default:
				KPostNotification(kNOtificationName_WXPayFailure, resp);
				break;
		}
	}
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary*)options{
	if ([url.host isEqualToString:@"safepay"]) {
		//跳转支付宝钱包进行支付，处理支付结果
		[[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
			DLog(@"result = %@",resultDic);
		}];
		
		return YES;
	}
	
	return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
	return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
	if ([url.host isEqualToString:@"safepay"]) {
		//跳转支付宝钱包进行支付，处理支付结果
		[[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
			DLog(@"result = %@",resultDic);
		}];
		
		return YES;
	}
	
	return  [WXApi handleOpenURL:url delegate:self];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)enterTest {
    RootTestController *testVC = [[RootTestController alloc] init];
    BaseNavViewController *nav = [[BaseNavViewController alloc] initWithRootViewController:testVC];
    self.window.rootViewController = nav;
}


@end
