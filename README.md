#支付宝 cordova 插件
 
##插件安装    android 支持沙箱测试  ios不支持沙箱测试
    ## $ cordova plugin add (plugin directory) --variable ALIPAY_APPID=$(aliAPPID)  --variable ALIPAY_TEST=$(00 生产 01 测试)
    ## $ ionic plugin add (plugin directory) --variable ALIPAY_APPID=$(aliAPPID)  --variable ALIPAY_TEST=$(00 生产 01 测试)

##插件删除
    ## $ cordova plugin rm cordova-plugin-alipay
    ## $ ionic plugin rm cordova-plugin-alipay

#插件调用
    ##在TyptScript中定义对象
    ## declare let cordova: any;

    ##调用方法
    ## orderInfo 根据支付宝规范后台进行加密签名后的字符串
    ## success 插件成功执行的回调函数 ，返回格式为 jsonstring 
    ## resultStatus 结果码含义（来源支付宝官方文档）
            9000	订单支付成功
            8000	正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
            4000	订单支付失败
            5000	重复请求
            6001	用户中途取消
            6002	网络连接出错
            6004	支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
            其它	其它支付错误
    ## 如： 
        {
            "resultStatus" : "9000",
            "memo" : "xxxxx",
            "result" : "{
                            \"alipay_trade_app_pay_response\":{
                                \"code\":\"10000\",
                                \"msg\":\"Success\",
                                \"app_id\":\"2014072300007148\",
                                \"out_trade_no\":\"081622560194853\",
                                \"trade_no\":\"2016081621001004400236957647\",
                                \"total_amount\":\"0.01\",
                                \"seller_id\":\"2088702849871851\",
                                \"charset\":\"utf-8\",
                                \"timestamp\":\"2016-10-11 17:43:36\"
                            },
                            \"sign\":\"NGfStJf3i3ooWBuCDIQSumOpaGBcQz+aoAqyGh3W6EqA/gmyPYwLJ2REFijY9XPTApI9YglZyMw+ZMhd3kb0mh4RAXMrb6mekX4Zu8Nf6geOwIa9kLOnw0IMCjxi4abDIfXhxrXyj********\",
                            \"sign_type\":\"RSA2\"
                        }"    
        }
        
    ## error 插件异常的回调函数,异常返回为 string
    ## cordova.plugins.UnionPay.AliPay(orderInfo,success, error);

