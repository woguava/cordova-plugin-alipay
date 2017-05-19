/********* AliPay.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <AlipaySDK/AlipaySDK.h>

@interface AliPay : CDVPlugin {
  // Member variables go here.
  NSString * g_appId;
  NSString * g_currentCallbackId;
}

- (void)starPay:(CDVInvokedUrlCommand*)command;
@end

@implementation AliPay

//插件初始化
- (void)pluginInitialize 
{
    g_appId = [[self.commandDelegate settings] objectForKey:@"alipay_appid"];
}

//开始支付
- (void)starPay:(CDVInvokedUrlCommand*)command
{
    g_currentCallbackId = command.callbackId;

    if ([g_appId length] == 0)
    {
        [self failWithCallbackID:g_currentCallbackId withMessage:@"Alipay APP_ID config error!"];
        return;
    }

    NSString* orderInfo = [command.arguments objectAtIndex:0];
    NSLog(@"Alipay Start payment with orderInfo \"%@\"", orderInfo);

    //验证参数有效性
    if(![self checkParamValid:orderInfo]){
        [self failWithCallbackID:g_currentCallbackId withMessage:@"Alipay payment parameter error!"];
        return;
    }
    
    //应用注册scheme,*-Info.plist定义URL types
    NSMutableString * schema = [NSMutableString string];
    [schema appendFormat:@"ALI%@", g_appId];
    NSLog(@"Alipay schema = %@",schema);
    
    // NOTE: 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:orderInfo fromScheme:schema callback:^(NSDictionary *resultDic) {
        NSLog(@"reslut = %@",resultDic);
        NSString * resultString = [self jsonStringWitchDictionary:resultDic];
        [self successWithCallbackID:g_currentCallbackId withMessage:resultString];
    }];

}

//回调通知
- (void)handleOpenURL:(NSNotification *)notification
{
    NSURL* url = [notification object];
    
    if ([url.scheme rangeOfString:g_appId].length > 0)
    {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            NSString * resultString = [self jsonStringWitchDictionary:resultDic];
            [self successWithCallbackID:g_currentCallbackId withMessage:resultString];
        }];
    }
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

//NSDictionary to JsonString 
-(NSString *)jsonStringWitchDictionary:(NSDictionary *)infoDict
{
    NSError *error =nil;
    NSData *jsonData =nil;
    
    jsonData = [NSJSONSerialization dataWithJSONObject:infoDict options:NSJSONWritingPrettyPrinted error:&error];
    if([jsonData length] == 0 || error != nil){
        return nil;
    }
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}

//检测支付宝参数串有效性
-(BOOL) checkParamValid:(NSString *)paramers
{
    if(paramers == nil || [paramers length] == 0){
        return false;
    }
    NSArray * paramArray = [paramers componentsSeparatedByString:@"&"];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
        
    for(id obj in paramArray){
        NSLog(@"paramobj = %@",obj);
        NSString * oneParam = (NSString *)obj;
        NSArray * oneParamArray = [oneParam componentsSeparatedByString:@"="];
        
        [paramDict setObject:[oneParamArray objectAtIndex:1] forKey:[oneParamArray objectAtIndex:0]];
    }
    
    NSLog(@"paramDict = %@",paramDict);
    
    if(![[paramDict allKeys] containsObject:@"app_id"]
        || ![[paramDict allKeys] containsObject:@"biz_content"]
        || ![[paramDict allKeys] containsObject:@"charset"]
        || ![[paramDict allKeys] containsObject:@"method"]
        || ![[paramDict allKeys] containsObject:@"sign_type"]
        || ![[paramDict allKeys] containsObject:@"sign"]
        || ![[paramDict allKeys] containsObject:@"timestamp"]
        || ![[paramDict allKeys] containsObject:@"version"]
        || ![[paramDict allKeys] containsObject:@"notify_url"]){
        return false;
    }
    
    return true;
}

@end
