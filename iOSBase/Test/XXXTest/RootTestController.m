//
//  RootTestController.m
//  iOSBase
//
//  Created by mac on 2018/1/29.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "RootTestController.h"
//登录用
#import <ShareSDK/ShareSDK.h>
//分享用
#import <ShareSDK/NSMutableDictionary+SSDKShare.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
@interface RootTestController ()

@end

@implementation RootTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testAction:(id)sender {
    
}

- (IBAction)WXLogin:(id)sender {
	// 微信登录  需要QQ 登录 可替换：SSDKPlatformTypeQQ
#warning 微信开发账号下来后需要替换 微信的配置信息
	[ShareSDK getUserInfo:SSDKPlatformTypeWechat
		   onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
	 {
		 if (state == SSDKResponseStateSuccess)
		 {
			 NSLog(@"uid=%@",user.uid);
			 NSLog(@"%@",user.credential.rawData[@"unionid"]);
			 NSLog(@"%@",user.credential);
			 NSLog(@"token=%@",user.credential.token);
			 NSLog(@"nickname=%@",user.nickname);
			 NSLog(@"icon=%@",user.icon);
	
			 //取消当前微信授权
#warning 退出登录后取消授权 此代码要放在退出登录的地方 下次登录会跳转一次微信
			 [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
		 }else {
			 [SVProgressHUD showErrorWithStatus:@"微信登录失败"];
		 }
		 /*
		  {
		  "access_token" = "6_Jbez5gWjRpuKe32ujY4OOig6G2AWECYt_PaBE2A7M4QXKoKPuV6_ebHirUx1aTGxB7bBG7NsdaeupaNhts4F6TWflNMdPZR3tTmEGIPyEDs";
		  "expires_in" = 7200;
		  openid = "o3LILj9yKB9-F4MNBkiZQWevOyE4";
		  "refresh_token" = "6_zsxHAKwWxKtP3rDiSEmOIc_W0oqyC27GQaXYza3niBBZqmOwWSYuPcxN5Jdz71G7yVk8hhvXD6S7-it1fH92BbR21hvYGyCv01qdnbu_EbU";
		  scope = "snsapi_userinfo";
		  unionid = "oHRAHuI_ZDR8lus0AQAGkmghGKcE";
		  }
		  */
	 }];
}

- (IBAction)Share:(id)sender {
#warning 图片可设置本地图片 或网络图片地址
	//1、创建分享参数（必要）
	NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
	[shareParams SSDKSetupShareParamsByText:@"测试内容"
									 images:@[@"http://pic1.16pic.com/00/04/84/16pic_484482_b.jpg"]
										url:[NSURL URLWithString:@"http://baidu.com"]
									  title:@"测试标题"
									   type:SSDKContentTypeAuto];
	
	// 定制微信好友的分享内容
	[shareParams SSDKSetupWeChatParamsByText:@"测试内容"
									   title:@"测试标题"
										 url:[NSURL URLWithString:@"http://baidu.com"]
								  thumbImage:nil
									   image:@[@"http://pic1.16pic.com/00/04/84/16pic_484482_b.jpg"]
								musicFileURL:nil
									 extInfo:nil
									fileData:nil
								emoticonData:nil
										type:SSDKContentTypeAuto  forPlatformSubType:SSDKPlatformSubTypeWechatSession];// 微信好友子平台
	
	[ShareSDK showShareActionSheet:self.view items:nil shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
		switch (state) {
			case SSDKResponseStateSuccess:
			{
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
																	message:nil
																   delegate:nil
														  cancelButtonTitle:@"确定"
														  otherButtonTitles:nil];
				[alertView show];
				break;
			}
			case SSDKResponseStateCancel:
			{
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
																	message:nil
																   delegate:nil
														  cancelButtonTitle:@"确定"
														  otherButtonTitles:nil];
				[alertView show];
				break;
			}
				
				
			case SSDKResponseStateFail:
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
																message:[NSString stringWithFormat:@"%@",error]
															   delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil, nil];
				[alert show];
				break;
			}
			default:
				break;
		}
	}];
	
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
