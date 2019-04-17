//
//  XTBLEYiTongMeterRequest.m
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "XTBLEYiTongMeterRequest.h"
#import "XTBLEYiTongMeterParse.h"
#import "XTBLEManager+Log.h"

@implementation XTBLEYiTongMeterRequest

static id _instace;

- (id)init
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((obj = [super init])) {
            
        }
    });
    self = obj;
    return self;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

+ (id)sharedRequest
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    
    return _instace;
}

/**
 读表基本信息命令
 
 @param userNumber 用户号
 @param success model: XTYiTongMeterInfo
 @param failure error
 */
- (void)readMeterWithUserNumber:(NSString *)userNumber success:(void(^)(XTYiTongMeterInfo *model))success failure:(void(^)(NSError *error))failure {
    
    XTBLEYiTongMeterParse *parseManager = [XTBLEYiTongMeterParse sharedParse];
    //请求data
    NSData *requestData = [parseManager readMeterWithUserNumber:userNumber];
    
    //发送请求
    XTBLEManager *requestManager = [XTBLEManager sharedManager];
    
    //log
    [requestManager log_method:@"读表基本信息命令" startFilter:@"6830A9A2" endFilter:@"长度：168    校验和：是"];
    
    [requestManager sendData:requestData startFilter:^BOOL(NSData *receiveData) {
        //开头过滤
        NSError *error = [parseManager findErrorWithData:receiveData];
        if (error) {
            [requestManager cancelReceiveData:error];
            return NO;
        } else {
            return [[[XTUtils hexStringWithData:receiveData] uppercaseString] hasPrefix:@"6830A9A2"];
        }

    } endFilter:^BOOL(NSData *JointData) {
        //结尾过滤
        if (JointData.length == 168) {
            //校验和校验
            NSData *checkSum = [XTUtils checksumDataWithOriginData:[JointData subdataWithRange:NSMakeRange(0, JointData.length-2)]];
            if (![checkSum isEqualToData:[JointData subdataWithRange:NSMakeRange(JointData.length-2, 1)]]) {
                [requestManager cancelReceiveData:[NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"校验和校验失败"}]];
                return NO;
            }
            return YES;
        }
        return NO;
    } success:^(NSData *data) {
        //解析数据
        XTYiTongMeterInfo *model = [parseManager parseReadMeterByte:data];
        if (success) {
            success(model);
        }
        
    } failure:^(NSError *error) {
        //中途取消或出错
        if (![[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"请求被取消"]) {
            if (failure) {
                failure(error);
            }
        }
    }];
    
}


/**
 充值命令

 @param encodeString 24位短充值命令
 @param paramSettingInfo 设置参数信息(不传:代表不需要设置信息)
 @param desCmd 加密字符串
 @param random 随机数
 @param success XTYiTongRechargeResult
 @param failure error
 */
- (void)rechargeWithEncodeString:(NSString *)encodeString paramSettingInfo:(XTYiTongParamSetting *)paramSettingInfo desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(XTYiTongRechargeResult *model))success failure:(void(^)(NSError *error))failure {
    
    XTBLEYiTongMeterParse *parseManager = [XTBLEYiTongMeterParse sharedParse];
    //请求data
    NSData *requestData = [parseManager getRechargeByteWithEncodeString:encodeString paramSettingInfo:paramSettingInfo desCmd:desCmd random:random];
    
    //发送请求
    XTBLEManager *requestManager = [XTBLEManager sharedManager];
    
    //log
    [requestManager log_method:@"充值命令" startFilter:@"683089B9" endFilter:@"长度：191    校验和：是"];
    
    [requestManager sendData:requestData startFilter:^BOOL(NSData *receiveData) {
        //开头过滤
        NSError *error = [parseManager findErrorWithData:receiveData];
        if (error) {
            [requestManager cancelReceiveData:error];
            return NO;
        } else {
            return [[[XTUtils hexStringWithData:receiveData] uppercaseString] hasPrefix:@"683089B9"];
        }
        
    } endFilter:^BOOL(NSData *JointData) {
        //结尾过滤
        if (JointData.length == 191) {
            //校验和校验
            NSData *checkSum = [XTUtils checksumDataWithOriginData:[JointData subdataWithRange:NSMakeRange(0, JointData.length-2)]];
            if (![checkSum isEqualToData:[JointData subdataWithRange:NSMakeRange(JointData.length-2, 1)]]) {
                [requestManager cancelReceiveData:[NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"校验和校验失败"}]];
                return NO;
            }
            return YES;
        }
        return NO;
    } success:^(NSData *data) {
        //解析数据
        XTYiTongRechargeResult *model = [parseManager parseRechargeByte:data isSet:paramSettingInfo ? YES : NO];
        if (success) {
            success(model);
        }
    } failure:^(NSError *error) {
        //中途取消或出错
        if (![[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"请求被取消"]) {
            if (failure) {
                failure(error);
            }
        }
    }];

}


/**
 校时命令

 @param userNumber 用户号
 @param time 校时时间
 @param success newTime时间
 @param failure error
 */
- (void)checkTimeByteWithUserNumber:(NSString *)userNumber time:(NSString *)time success:(void(^)(NSString *newTime))success failure:(void(^)(NSError *error))failure {
    
    XTBLEYiTongMeterParse *parseManager = [XTBLEYiTongMeterParse sharedParse];
    //请求data
    NSString *newTimeStr = time;
    NSString *year;
    if (time.length >= 14) {
        year = [time substringWithRange:NSMakeRange(0, 2)];
        newTimeStr = [time substringWithRange:NSMakeRange(2, 12)];
    }
    NSData *requestData = [parseManager getCheckTimeByteWithUserNumber:userNumber time:newTimeStr];
    //NSLog(@"===requestData===%@",requestData);
  
    //发送请求
    XTBLEManager *requestManager = [XTBLEManager sharedManager];
    
    //log
    [requestManager log_method:@"校时命令" startFilter:@"6830E910" endFilter:@"长度：22    校验和：是"];
    
    [requestManager sendData:requestData startFilter:^BOOL(NSData *receiveData) {
        //开头过滤
        NSError *error = [parseManager findErrorWithData:receiveData];
        if (error) {
            [requestManager cancelReceiveData:error];
            return NO;
        } else {
            return [[[XTUtils hexStringWithData:receiveData] uppercaseString] hasPrefix:@"6830E910"];
        }
        
    } endFilter:^BOOL(NSData *JointData) {
        //结尾过滤
        if (JointData.length == 22) {
            //校验和校验
            NSData *checkSum = [XTUtils checksumDataWithOriginData:[JointData subdataWithRange:NSMakeRange(0, JointData.length-2)]];
            if (![checkSum isEqualToData:[JointData subdataWithRange:NSMakeRange(JointData.length-2, 1)]]) {
                [requestManager cancelReceiveData:[NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"校验和校验失败"}]];
                return NO;
            }
            return YES;
        }
        return NO;
    } success:^(NSData *data) {
        //开始解析
        NSString *dateStr = [parseManager parseCheckTimeByte:data withYear:year];
        if (success) {
            success(dateStr);
        }
    } failure:^(NSError *error) {
        //中途取消或出错
        if (![[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"请求被取消"]) {
            if (failure) {
                failure(error);
            }
        }
    }];
    
}


/**
 读历史回抄数据命令

 @param userNumber 用户号
 @param index 抄表序号
 @param success array
 @param failure error
 */
- (void)readFreezeDayWithUserNumber:(NSString *)userNumber index:(int)index success:(void(^)(NSArray <XTYiTongHistoryDay *>*array))success failure:(void(^)(NSError *error))failure {
    
    XTBLEYiTongMeterParse *parseManager = [XTBLEYiTongMeterParse sharedParse];
    //请求data
    NSData *requestData = [parseManager getHistoryDayWithUserNumber:userNumber index:index];
    //NSLog(@"====request===%@",requestData);
    
    //发送请求
    XTBLEManager *requestManager = [XTBLEManager sharedManager];
    
    //log
    [requestManager log_method:@"读历史回抄数据命令" startFilter:@"6830C0E4" endFilter:@"长度：234    校验和：是"];
    
    [requestManager sendData:requestData startFilter:^BOOL(NSData *receiveData) {
        //开头过滤
        NSError *error = [parseManager findErrorWithData:receiveData];
        if (error) {
            [requestManager cancelReceiveData:error];
            return NO;
        } else {
            return [[[XTUtils hexStringWithData:receiveData] uppercaseString] hasPrefix:@"6830C0E4"];
        }
        
    } endFilter:^BOOL(NSData *JointData) {
        //结尾过滤
        if (JointData.length == 234) {
            //校验和校验
            NSData *checkSum = [XTUtils checksumDataWithOriginData:[JointData subdataWithRange:NSMakeRange(0, JointData.length-2)]];
            if (![checkSum isEqualToData:[JointData subdataWithRange:NSMakeRange(JointData.length-2, 1)]]) {
                [requestManager cancelReceiveData:[NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"校验和校验失败"}]];
                return NO;
            }
            return YES;
        }
        return NO;
    } success:^(NSData *data) {
        //开始解析
        NSArray *array = [parseManager parseHistoryData:data];
        if (success) {
            success(array);
        }
    } failure:^(NSError *error) {
        //中途取消或出错
        if (![[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"请求被取消"]) {
            if (failure) {
                failure(error);
            }
        }
    }];
    
}


/**
 安检命令

 @param userNumber 用户号
 @param checkMan 安检员编号
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @param success result bool
 @param failure error
 */
- (void)securityCheckWithUserNumber:(NSString *)userNumber checkMan:(NSString *)checkMan periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(BOOL result))success failure:(void(^)(NSError *error))failure {
    
    XTBLEYiTongMeterParse *parseManager = [XTBLEYiTongMeterParse sharedParse];
    //请求data
    NSData *requestData = [parseManager getSecurityCheckWithUserNumber:userNumber checkMan:checkMan periodTime:periodTime desCmd:desCmd random:random];
    //NSLog(@"====request===%@",requestData);
    
    //发送请求
    XTBLEManager *requestManager = [XTBLEManager sharedManager];
    
    //log
    [requestManager log_method:@"安检命令" startFilter:@"6830C60B" endFilter:@"长度：17    校验和：是"];
    
    [requestManager sendData:requestData startFilter:^BOOL(NSData *receiveData) {
        //开头过滤
        NSError *error = [parseManager findErrorWithData:receiveData];
        if (error) {
            [requestManager cancelReceiveData:error];
            return NO;
        } else {
            return [[[XTUtils hexStringWithData:receiveData] uppercaseString] hasPrefix:@"6830C60B"];
        }
        
    } endFilter:^BOOL(NSData *JointData) {
        //结尾过滤
        if (JointData.length == 17) {
            //校验和校验
            NSData *checkSum = [XTUtils checksumDataWithOriginData:[JointData subdataWithRange:NSMakeRange(0, JointData.length-2)]];
            if (![checkSum isEqualToData:[JointData subdataWithRange:NSMakeRange(JointData.length-2, 1)]]) {
                [requestManager cancelReceiveData:[NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"校验和校验失败"}]];
                return NO;
            }
            return YES;
        }
        return NO;
    } success:^(NSData *data) {
        //开始解析
        NSString *result = [parseManager parseSecurityCheckData:data];
        if ([result isEqualToString:@"55"]) {
            if (success) {
                success(YES);
            }
        } else {
            if (success) {
                success(NO);
            }
        }
    } failure:^(NSError *error) {
        //中途取消或出错
        if (![[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"请求被取消"]) {
            if (failure) {
                failure(error);
            }
        }
    }];
    
}


/**
 设置表底数命令

 @param userNumber 用户号
 @param number 表底数
 @param success result 返回表底数
 @param failure error
 */
- (void)baseSettingWithUserNumber:(NSString *)userNumber number:(long)number success:(void(^)(long number))success failure:(void(^)(NSError *error))failure {
    
    XTBLEYiTongMeterParse *parseManager = [XTBLEYiTongMeterParse sharedParse];
    //请求data
    NSData *requestData = [parseManager getBaseSettingWithUserNumber:userNumber number:number];
    //NSLog(@"====request===%@",requestData);
    
    //发送请求
    XTBLEManager *requestManager = [XTBLEManager sharedManager];
    
    //log
    [requestManager log_method:@"设置表底数命令" startFilter:@"6830B90E" endFilter:@"长度：20    校验和：是"];
    
    [requestManager sendData:requestData startFilter:^BOOL(NSData *receiveData) {
        //开头过滤
        NSError *error = [parseManager findErrorWithData:receiveData];
        if (error) {
            [requestManager cancelReceiveData:error];
            return NO;
        } else {
            return [[[XTUtils hexStringWithData:receiveData] uppercaseString] hasPrefix:@"6830B90E"];
        }
        
    } endFilter:^BOOL(NSData *JointData) {
        //结尾过滤
        if (JointData.length == 20) {
            //校验和校验
            NSData *checkSum = [XTUtils checksumDataWithOriginData:[JointData subdataWithRange:NSMakeRange(0, JointData.length-2)]];
            if (![checkSum isEqualToData:[JointData subdataWithRange:NSMakeRange(JointData.length-2, 1)]]) {
                [requestManager cancelReceiveData:[NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"校验和校验失败"}]];
                return NO;
            }
            return YES;
        }
        return NO;
    } success:^(NSData *data) {
        //开始解析
        NSString *numberStr = [parseManager parseBaseSettingData:data];
        if (success) {
            success([numberStr longLongValue]);
        }
    } failure:^(NSError *error) {
        //中途取消或出错
        if (![[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"请求被取消"]) {
            if (failure) {
                failure(error);
            }
        }
    }];
}


/**
 应急卡命令

 @param userNumber 用户号
 @param warning 报警值2
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @param success result bool
 @param failure error
 */
- (void)emergencyWithUserNumber:(NSString *)userNumber warning:(NSString *)warning periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(BOOL result))success failure:(void(^)(NSError *error))failure {
    
    XTBLEYiTongMeterParse *parseManager = [XTBLEYiTongMeterParse sharedParse];
    //请求data
    NSData *requestData = [parseManager getEmergencyWithUserNumber:userNumber warning:warning periodTime:periodTime desCmd:desCmd random:random];
    //NSLog(@"====request===%@",requestData);
    
    //发送请求
    XTBLEManager *requestManager = [XTBLEManager sharedManager];
    
    //log
    [requestManager log_method:@"应急卡命令" startFilter:@"6830C50B" endFilter:@"长度：17    校验和：是"];
    
    [requestManager sendData:requestData startFilter:^BOOL(NSData *receiveData) {
        //开头过滤
        NSError *error = [parseManager findErrorWithData:receiveData];
        if (error) {
            [requestManager cancelReceiveData:error];
            return NO;
        } else {
            return [[[XTUtils hexStringWithData:receiveData] uppercaseString] hasPrefix:@"6830C50B"];
        }
        
    } endFilter:^BOOL(NSData *JointData) {
        //结尾过滤
        if (JointData.length == 17) {
            //校验和校验
            NSData *checkSum = [XTUtils checksumDataWithOriginData:[JointData subdataWithRange:NSMakeRange(0, JointData.length-2)]];
            if (![checkSum isEqualToData:[JointData subdataWithRange:NSMakeRange(JointData.length-2, 1)]]) {
                [requestManager cancelReceiveData:[NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"校验和校验失败"}]];
                return NO;
            }
            return YES;
        }
        return NO;
    } success:^(NSData *data) {
        //开始解析
        NSString *result = [parseManager parseEmergencyData:data];
        if ([result intValue] >= 0) {
            if (success) {
                success(YES);
            }
        } else {
            if (success) {
                success(NO);
            }
        }
    } failure:^(NSError *error) {
        //中途取消或出错
        if (![[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"请求被取消"]) {
            if (failure) {
                failure(error);
            }
        }
    }];
    
}

/**
 检查命令第一帧

 @param userNumber 用户号
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @param success XTYiTongCheckMeterFirst
 @param failure error
 */
- (void)checkFirstWithUserNumber:(NSString *)userNumber periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(XTYiTongCheckMeterFirst *firstInfo))success failure:(void(^)(NSError *error))failure {
    
    XTBLEYiTongMeterParse *parseManager = [XTBLEYiTongMeterParse sharedParse];
    //请求data
    NSData *requestData = [parseManager checkWithUserNumber:userNumber periodTime:periodTime num:1 desCmd:desCmd random:random];
   
    //发送请求
    XTBLEManager *requestManager = [XTBLEManager sharedManager];
    
    //log
    [requestManager log_method:@"检查命令第一帧" startFilter:@"6830C1C8" endFilter:@"长度：206    校验和：是"];
    
    [requestManager sendData:requestData startFilter:^BOOL(NSData *receiveData) {
        //开头过滤
        NSError *error = [parseManager findErrorWithData:receiveData];
        if (error) {
            [requestManager cancelReceiveData:error];
            return NO;
        } else {
            return [[[XTUtils hexStringWithData:receiveData] uppercaseString] hasPrefix:@"6830C1C8"];
        }
        
    } endFilter:^BOOL(NSData *JointData) {
        //结尾过滤
        if (JointData.length == 206) {
            //校验和校验
            NSData *checkSum = [XTUtils checksumDataWithOriginData:[JointData subdataWithRange:NSMakeRange(0, JointData.length-2)]];
            if (![checkSum isEqualToData:[JointData subdataWithRange:NSMakeRange(JointData.length-2, 1)]]) {
                [requestManager cancelReceiveData:[NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"校验和校验失败"}]];
                return NO;
            }
            return YES;
        }
        return NO;
    } success:^(NSData *data) {
        //解析数据
        XTYiTongCheckMeterFirst *model = [parseManager parseCheckFirstByte:data];
        if (success) {
            success(model);
        }
    } failure:^(NSError *error) {
        //中途取消或出错
        if (![[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"请求被取消"]) {
            if (failure) {
                failure(error);
            }
        }
    }];

}

/**
 检查命令第二帧
 
 @param userNumber 用户号
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @param success XTYiTongCheckMeterSecond
 @param failure error
 */
- (void)checkSecondWithUserNumber:(NSString *)userNumber periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(XTYiTongCheckMeterSecond *secondInfo))success failure:(void(^)(NSError *error))failure {
    
    XTBLEYiTongMeterParse *parseManager = [XTBLEYiTongMeterParse sharedParse];
    //请求data
    NSData *requestData = [parseManager checkWithUserNumber:userNumber periodTime:periodTime num:2 desCmd:desCmd random:random];
    
    //发送请求
    XTBLEManager *requestManager = [XTBLEManager sharedManager];
    
    //log
    [requestManager log_method:@"检查命令第二帧" startFilter:@"6830C2E0" endFilter:@"长度：230    校验和：是"];
    
    [requestManager sendData:requestData startFilter:^BOOL(NSData *receiveData) {
        //开头过滤
        NSError *error = [parseManager findErrorWithData:receiveData];
        if (error) {
            [requestManager cancelReceiveData:error];
            return NO;
        } else {
            return [[[XTUtils hexStringWithData:receiveData] uppercaseString] hasPrefix:@"6830C2E0"];
        }
        
    } endFilter:^BOOL(NSData *JointData) {
        //结尾过滤
        if (JointData.length == 230) {
            //校验和校验
            NSData *checkSum = [XTUtils checksumDataWithOriginData:[JointData subdataWithRange:NSMakeRange(0, JointData.length-2)]];
            if (![checkSum isEqualToData:[JointData subdataWithRange:NSMakeRange(JointData.length-2, 1)]]) {
                [requestManager cancelReceiveData:[NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"校验和校验失败"}]];
                return NO;
            }
            return YES;
        }
        return NO;
    } success:^(NSData *data) {
        //解析数据
        XTYiTongCheckMeterSecond *model = [parseManager parseCheckSecondByte:data];
        if (success) {
            success(model);
        }
    } failure:^(NSError *error) {
        //中途取消或出错
        if (![[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"请求被取消"]) {
            if (failure) {
                failure(error);
            }
        }
    }];

}

/**
 参数设置卡命令

 @param userNumber 用户号
 @param model 参数设置model
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @param success result bool
 @param failure error
 */
- (void)paramSettingWithUserNumber:(NSString *)userNumber XTYiTongParamSetting:(XTYiTongParamSetting *)model periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(BOOL result))success failure:(void(^)(NSError *error))failure {
    
    XTBLEYiTongMeterParse *parseManager = [XTBLEYiTongMeterParse sharedParse];
    //请求data
    NSData *requestData = [parseManager paramSettingWithUserNumber:userNumber paramData:[self getParamDataWithXTYiTongParamSetting:model] periodTime:periodTime desCmd:desCmd random:random];
    //NSLog(@"===requestData===%@",requestData);
    
    //发送请求
    XTBLEManager *requestManager = [XTBLEManager sharedManager];
    
    //log
    [requestManager log_method:@"参数设置卡命令" startFilter:@"6830C40B" endFilter:@"长度：17    校验和：是"];
    
    [requestManager sendData:requestData startFilter:^BOOL(NSData *receiveData) {
        //开头过滤
        NSError *error = [parseManager findErrorWithData:receiveData];
        if (error) {
            [requestManager cancelReceiveData:error];
            return NO;
        } else {
            return [[[XTUtils hexStringWithData:receiveData] uppercaseString] hasPrefix:@"6830C40B"];
        }
        
    } endFilter:^BOOL(NSData *JointData) {
        //结尾过滤
        if (JointData.length == 17) {
            //校验和校验
            NSData *checkSum = [XTUtils checksumDataWithOriginData:[JointData subdataWithRange:NSMakeRange(0, JointData.length-2)]];
            if (![checkSum isEqualToData:[JointData subdataWithRange:NSMakeRange(JointData.length-2, 1)]]) {
                [requestManager cancelReceiveData:[NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"校验和校验失败"}]];
                return NO;
            }
            return YES;
        }
        return NO;
    } success:^(NSData *data) {
        //解析数据
        NSString *resultStr = [parseManager parseParamSettingData:data];
        if ([resultStr isEqualToString:@"55"]) {
            if (success) {
                success(YES);
            }
        } else {
            if (success) {
                success(NO);
            }
        }
    } failure:^(NSError *error) {
        //中途取消或出错
        if (![[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"请求被取消"]) {
            if (failure) {
                failure(error);
            }
        }
    }];
    
}


/**
 清零卡命令

 @param userNumber 用户号
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @param success result bool
 @param failure error
 */
- (void)clearZeroWithUserNumber:(NSString *)userNumber periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(BOOL result))success failure:(void(^)(NSError *error))failure {
    
    XTBLEYiTongMeterParse *parseManager = [XTBLEYiTongMeterParse sharedParse];
    //请求data
    NSData *requestData = [parseManager clearZeroWithUserNumber:userNumber periodTime:periodTime desCmd:desCmd random:random];
    //NSLog(@"===requestData===%@",requestData);
    
    //发送请求
    XTBLEManager *requestManager = [XTBLEManager sharedManager];
    
    //log
    [requestManager log_method:@"清零卡命令" startFilter:@"6830C30B" endFilter:@"长度：17    校验和：是"];
    
    [requestManager sendData:requestData startFilter:^BOOL(NSData *receiveData) {
        //开头过滤
        NSError *error = [parseManager findErrorWithData:receiveData];
        if (error) {
            [requestManager cancelReceiveData:error];
            return NO;
        } else {
            return [[[XTUtils hexStringWithData:receiveData] uppercaseString] hasPrefix:@"6830C30B"];
        }

    } endFilter:^BOOL(NSData *JointData) {
        //结尾过滤
        if (JointData.length == 17) {
            //校验和校验
            NSData *checkSum = [XTUtils checksumDataWithOriginData:[JointData subdataWithRange:NSMakeRange(0, JointData.length-2)]];
            if (![checkSum isEqualToData:[JointData subdataWithRange:NSMakeRange(JointData.length-2, 1)]]) {
                [requestManager cancelReceiveData:[NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"校验和校验失败"}]];
                return NO;
            }
            return YES;
        }
        return NO;
    } success:^(NSData *data) {
        //解析数据
        NSString *relustStr = [parseManager parseClearZeroData:data];
        if ([relustStr isEqualToString:@"55"]) {
            if (success) {
                success(YES);
            }
        } else {
            if (success) {
                success(NO);
            }
        }
    } failure:^(NSError *error) {
        //中途取消或出错
        if (![[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"请求被取消"]) {
            if (failure) {
                failure(error);
            }
        }
    }];
    
}

/**
 修改设备名称
 
 @param deviceName 新设备名
 @param success success
 @param failure error
 */
- (void)changeDeviceName:(NSString *)deviceName success:(void(^)())success failure:(void(^)(NSError *error))failure {
    
    //发送请求
    XTBLEManager *manger = [XTBLEManager sharedManager];
    [manger changeDeviceName:deviceName success:^{
        if (success) {
            success();
        };
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];

}


//TODO
/**
 *  根据参数设置获取data
 */
- (NSData *)getParamDataWithXTYiTongParamSetting:(XTYiTongParamSetting *)model {
    //包装数据
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[XTUtils dataWithLong:model.leak length:1]];
    [data appendData:[XTUtils dataWithLong:model.serialHours length:1]];
    [data appendData:[XTUtils dataWithLong:model.warnLockFun length:1]];
    [data appendData:[XTUtils dataWithLong:model.longNotUserLockFun length:1]];
    [data appendData:[XTUtils dataWithLong:model.notUseDay1 length:1]];
    [data appendData:[XTUtils dataWithLong:model.notUseDay2 length:1]];
    [data appendData:[XTUtils dataWithLong:model.overFun length:1]];
    [data appendData:[XTUtils dataWithLong:model.overCount length:2]];
    [data appendData:[XTUtils dataWithLong:model.overTimeFun length:1]];
    [data appendData:[XTUtils dataWithLong:model.overTime length:1]];
    [data appendData:[XTUtils dataWithLong:model.limitBuyFun length:1]];
    [data appendData:[XTUtils dataWithLong:model.limitUp length:4]];
    [data appendData:[XTUtils dataWithLong:model.lowWarnMoney length:2]];
    [data appendData:[XTUtils dataWithLong:model.warn1Fun length:1]];
    [data appendData:[XTUtils dataWithLong:model.warn1Value length:1]];
    [data appendData:[XTUtils dataWithLong:model.warn2Fun length:1]];
    [data appendData:[XTUtils dataWithLong:model.warn2Value length:1]];
    [data appendData:[XTUtils dataWithLong:model.zeroClose length:1]];
    [data appendData:[XTUtils dataWithLong:model.securityFun length:1]];
    [data appendData:[XTUtils dataWithLong:model.securityMonth length:1]];
    [data appendData:[XTUtils dataWithLong:model.scrapFun length:1]];
    [data appendData:[XTUtils dataWithLong:model.scrapYear length:1]];
    [data appendData:[XTUtils dataWithLong:0 length:1]];
    [data appendData:[XTUtils dataWithLong:0 length:1]];
    [data appendData:[XTUtils dataWithHexString:model.recordDay]];
    
    [data appendData:[XTUtils dataWithLong:model.curPriceG1.price1 length:2]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG1.devideCount1 length:3]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG1.price2 length:2]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG1.devideCount2 length:3]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG1.price3 length:2]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG1.devideCount3 length:3]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG1.price4 length:2]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG1.devideCount4 length:3]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG1.price5 length:2]];
    
    [data appendData:[XTUtils dataWithLong:model.curPriceG2.price1 length:2]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG2.devideCount1 length:3]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG2.price2 length:2]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG2.devideCount2 length:3]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG2.price3 length:2]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG2.devideCount3 length:3]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG2.price4 length:2]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG2.devideCount4 length:3]];
    [data appendData:[XTUtils dataWithLong:model.curPriceG2.price5 length:2]];
    
    [data appendData:[XTUtils dataWithLong:model.nwPriceG1.price1 length:2]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG1.devideCount1 length:3]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG1.price2 length:2]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG1.devideCount2 length:3]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG1.price3 length:2]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG1.devideCount3 length:3]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG1.price4 length:2]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG1.devideCount4 length:3]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG1.price5 length:2]];
    
    [data appendData:[XTUtils dataWithLong:model.nwPriceG2.price1 length:2]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG2.devideCount1 length:3]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG2.price2 length:2]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG2.devideCount2 length:3]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG2.price3 length:2]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG2.devideCount3 length:3]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG2.price4 length:2]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG2.devideCount4 length:3]];
    [data appendData:[XTUtils dataWithLong:model.nwPriceG2.price5 length:2]];
    
    [data appendData:[XTUtils dataWithHexString:model.nwPriceStartTime]];
    
    for (int i = 0; i < model.priceStartRepeat.count; i++) {
        NSString *priceStartRepeat = [model.priceStartRepeat objectAtIndex:i];
        NSString *monthStr = [priceStartRepeat substringWithRange:NSMakeRange(0, 2)];
        NSString *dayStr = [priceStartRepeat substringWithRange:NSMakeRange(2, 2)];
        NSString *priceStr = [priceStartRepeat substringWithRange:NSMakeRange(4, 2)];
        NSString *monthHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[monthStr intValue]]];
        NSString *dayHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[dayStr intValue]]];
        NSString *priceHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[priceStr intValue]]];
        if (dayHexStr.length == 1) {
            dayHexStr = [NSString stringWithFormat:@"0%@",dayHexStr];
        }
        NSString *hexStr = [NSString stringWithFormat:@"%@%@%@",monthHexStr,priceHexStr,dayHexStr];
        [data appendData:[XTUtils dataWithHexString:hexStr]];
        
    }
    
    for (int i = 0; i < model.nwPriceStartRepeat.count; i++) {
        NSString *priceStartRepeat = [model.nwPriceStartRepeat objectAtIndex:i];
        NSString *monthStr = [priceStartRepeat substringWithRange:NSMakeRange(0, 2)];
        NSString *dayStr = [priceStartRepeat substringWithRange:NSMakeRange(2, 2)];
        NSString *priceStr = [priceStartRepeat substringWithRange:NSMakeRange(4, 2)];
        NSString *monthHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[monthStr intValue]]];
        NSString *dayHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[dayStr intValue]]];
        NSString *priceHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[priceStr intValue]]];
        if (dayHexStr.length == 1) {
            dayHexStr = [NSString stringWithFormat:@"0%@",dayHexStr];
        }
        NSString *hexStr = [NSString stringWithFormat:@"%@%@%@",monthHexStr,priceHexStr,dayHexStr];
        [data appendData:[XTUtils dataWithHexString:hexStr]];
        
    }
    
    NSString *valuationWay = model.valuationWay;
    if ([valuationWay isEqualToString:@"1"]) {//计金额
        valuationWay = @"11";
    } else if ([valuationWay isEqualToString:@"0"]) {//计量
        valuationWay = @"55";
    } else {
        if (valuationWay.length > 2) {
            valuationWay = [valuationWay substringWithRange:NSMakeRange(0, 2)];
        }
    }
    
    [data appendData:[XTUtils dataWithHexString:valuationWay]];
    
    return data;
    
}


@end
