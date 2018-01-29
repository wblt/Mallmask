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
//微信支付用
#import "WXApi.h"
//支付宝用
#import <AlipaySDK/AlipaySDK.h>
@interface RootTestController ()

@end

@implementation RootTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[kNotificationCenter addObserver:self selector:@selector(WXPay_Success:) name:kNOtificationName_WXPaySuccess object:nil];
	[kNotificationCenter addObserver:self selector:@selector(WXPay_Failure:) name:kNOtificationName_WXPayFailure object:nil];
	[kNotificationCenter addObserver:self selector:@selector(AliPay_Success:) name:kNOtificationName_AliPaySuccess object:nil];
	[kNotificationCenter addObserver:self selector:@selector(AliPay_Failure:) name:kNOtificationName_AliPaySuccess object:nil];
	
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

- (IBAction)weixinPay:(id)sender {
	if (![WXApi isWXAppInstalled] && ![WXApi isWXAppSupportApi]) {
		[SVProgressHUD showErrorWithStatus:@"未安装微信客户端或不支持微信支付"];
		return;
	}
/*
	//本实例只是演示签名过程， 请将该过程在商户服务器上实现
	//创建支付签名对象
	payRequsestHandler *req = [payRequsestHandler alloc];
	//初始化支付签名对象
	[req init:APP_ID mch_id:MCH_ID order_name:@"预订车辆" order_price:money orderno:order_no];
	//设置密钥
	[req setKey:PARTNER_ID];
	//获取到实际调起微信支付的参数后，在app端调起支付
*/
	
#warning 此处向服务端 发送支付订单 服务单返回 调起微信支付的信息，客户端调起支付
	NSMutableDictionary *dict =  nil;
	
	if(dict == nil){
		//错误提示
		[SVProgressHUD showErrorWithStatus:@"还未开通微信支付"];
	}else{
		NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
		//调起微信支付
		PayReq* req             = [[PayReq alloc] init];
		req.openID              = [dict objectForKey:@"appid"];
		req.partnerId           = [dict objectForKey:@"partnerid"];
		req.prepayId            = [dict objectForKey:@"prepayid"];
		req.nonceStr            = [dict objectForKey:@"noncestr"];
		req.timeStamp           = stamp.intValue;
		req.package             = [dict objectForKey:@"package"];
		req.sign                = [dict objectForKey:@"sign"];
		[WXApi sendReq:req];
	}
}

- (IBAction)AliPay:(id)sender {
#warning 支付宝服务号 及服务端配置完成  直接调用即可
	// NOTE: 调用支付结果开始支付
	[[AlipaySDK defaultService] payOrder:@"服务器返回的订单字符串" fromScheme:@"appScheme" callback:^(NSDictionary *resultDic) {
		DLog(@"result = %@",resultDic);
	}];
	
}


#pragma mark--微信支付回调显示
-(void)WXPay_Success:(NSNotification *)notify{
	[SVProgressHUD showSuccessWithStatus:@"支付成功"];
}

-(void)WXPay_Failure:(NSNotification *)notify{
	PayResp *res = [notify object];
	if (res.errCode == -1){
		[SVProgressHUD showSuccessWithStatus:@"支付失败：参数错误，请重新尝试"];
	}else if (res.errCode ==-2){
		[SVProgressHUD showSuccessWithStatus:@"支付已取消"];
	}
}
#pragma mark--支付宝支付回调显示
- (void)AliPay_Success:(NSNotification *)notify {
	[SVProgressHUD showSuccessWithStatus:@"支付成功"];
}

- (void)AliPay_Failure:(NSNotification *)notify {
	[SVProgressHUD showSuccessWithStatus:@"支付失败"];
}


-(void)dealloc{
	[kNotificationCenter removeObserver:self name:kNOtificationName_WXPaySuccess object:nil];
	[kNotificationCenter removeObserver:self name:kNOtificationName_WXPayFailure object:nil];
	[kNotificationCenter removeObserver:self name:kNOtificationName_AliPaySuccess object:nil];
	[kNotificationCenter removeObserver:self name:kNOtificationName_AliPayFailure object:nil];
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
