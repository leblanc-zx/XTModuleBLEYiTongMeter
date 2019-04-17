//
//  XTBLEYiTongMeterParse.h
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTYiTongMeterInfo.h"
#import "XTYiTongRechargeResult.h"
#import "XTYiTongParamSetting.h"
#import "XTYiTongCheckMeter.h"
#import "XTYiTongHistoryDay.h"

@interface XTBLEYiTongMeterParse : NSObject

+ (id)sharedParse;

/** 发现错误 */
- (NSError *)findErrorWithData:(NSData *)data;

#pragma -mark 读表基本信息命令
/**
 读表基本信息命令 send

 @param userNumber 用户号
 @return data
 */
- (NSData *)readMeterWithUserNumber:(NSString *)userNumber;

/**
 读表基本信息命令 parse

 @param data 蓝牙表返回的data
 @return XTYiTongMeterInfo
 */
- (XTYiTongMeterInfo *)parseReadMeterByte:(NSData *)data;

#pragma -mark 充值命令

/**
 充值命令 send
 
 @param encodeString 24位短充值命令
 @param paramSettingInfo 设置参数信息(不传:代表不需要设置参数)
 @param desCmd 加密字符串
 @param random 随机数
 @return data
 */
- (NSData *)getRechargeByteWithEncodeString:(NSString *)encodeString paramSettingInfo:(XTYiTongParamSetting *)paramSettingInfo desCmd:(NSString *)desCmd random:(NSString *)random;

/**
 充值命令 parse

 @param data 蓝牙表返回的data
 @param isSet 设置参数bool
 @return XTYiTongRechargeResult
 */
- (XTYiTongRechargeResult *)parseRechargeByte:(NSData *)data isSet:(BOOL)isSet;

#pragma -mark 校时命令
/**
 校时命令 send
 
 @param userNumber 用户号
 @param time 校时时间
 @return data
 */
- (NSData *)getCheckTimeByteWithUserNumber:(NSString *)userNumber time:(NSString *)time;

/**
 校时命令 parse
 
 @param data 蓝牙表返回的data
 @param year 年开头（例如2010：20 1910：19）
 @return result 日期，nil代表解析失败
 */
- (NSString *)parseCheckTimeByte:(NSData *)data withYear:(NSString *)year;

#pragma -mark 读历史回抄数据命令
/**
 读历史回抄数据命令 send
 
 @param userNumber 用户号
 @param index 抄表序号
 @return data
 */
- (NSData *)getHistoryDayWithUserNumber:(NSString *)userNumber index:(int)index;

/**
 读历史回抄数据命令 parse
 
 @param data 蓝牙表返回的data
 @return 数组 nil代表解析失败
 */
- (NSArray *)parseHistoryData:(NSData *)data;

#pragma -mark 安检命令
/**
 安检命令 send
 
 @param userNumber 用户号
 @param checkMan 安检员编号
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @return data
 */
- (NSData *)getSecurityCheckWithUserNumber:(NSString *)userNumber checkMan:(NSString *)checkMan periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random;
/**
 安检命令 parse
 
 @param data 蓝牙表返回的data
 @return result 55安检成功，其它安检失败，nil解析失败
 */
- (NSString *)parseSecurityCheckData:(NSData *)data;

#pragma -mark 设置表底数命令
/**
 设置表底数命令 send
 
 @param userNumber 用户号
 @param number 表底数
 @return data
 */
- (NSData *)getBaseSettingWithUserNumber:(NSString *)userNumber number:(long)number;

/**
 设置表底数命令 parse
 
 @param data 蓝牙表返回的data
 @return resultStr 用气量 nil代表解析失败
 */
- (NSString *)parseBaseSettingData:(NSData *)data;

#pragma -mark 应急卡命令
/**
 应急卡命令 send
 
 @param userNumber 用户号
 @param warning 报警值2
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @return data
 */
- (NSData *)getEmergencyWithUserNumber:(NSString *)userNumber warning:(NSString *)warning periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random;

/**
 应急卡命令 parse
 
 @param data 蓝牙表返回的data
 @return result 大于0应急成功，其它应急失败，nil解析失败
 */
- (NSString *)parseEmergencyData:(NSData *)data;

#pragma -mark 检查命令
/**
 检查命令 send
 
 @param userNumber 用户号
 @param periodTime 有效期
 @param num 第num帧（一共两帧）
 @param desCmd 加密字符串
 @param random 随机值
 @return data
 */
- (NSData *)checkWithUserNumber:(NSString *)userNumber periodTime:(NSString *)periodTime num:(int)num desCmd:(NSString *)desCmd random:(NSString *)random;
/**
 检查第一帧命令 parse
 
 @param data 第一帧
 @return XTYiTongCheckMeterFirst nil解析失败
 */
- (XTYiTongCheckMeterFirst *)parseCheckFirstByte:(NSData *)data;

/**
 检查第二帧命令 parse
 
 @param data 第二帧
 @return XTYiTongCheckMeterSecond nil解析失败
 */
- (XTYiTongCheckMeterSecond *)parseCheckSecondByte:(NSData *)data;

#pragma -mark 参数设置卡命令

/**
 参数设置卡命令 send
 
 @param userNumber 用户号
 @param paramData 参数设置data
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @return data
 */
- (NSData *)paramSettingWithUserNumber:(NSString *)userNumber paramData:(NSData *)paramData periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random;
/**
 参数设置卡命令 parse
 
 @param data 蓝牙表返回的data
 @return result 55设置成功，其它设置失败，nil解析失败
 */
- (NSString *)parseParamSettingData:(NSData *)data;

#pragma -mark 清零卡命令

/**
 清零卡命令 send
 
 @param userNumber 用户号
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @return data
 */
- (NSData *)clearZeroWithUserNumber:(NSString *)userNumber periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random;

/**
 清零卡命令 parse

 @param data 蓝牙表返回的data
 @return NSString 55表示充值成功，其它表示充值失败，nil表示解析失败
 */
- (NSString *)parseClearZeroData:(NSData *)data;


@end
