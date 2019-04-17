//
//  XTBLEYiTongMeterRequest.h
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTUtils.h"
#import "XTBLEManager.h"
#import "XTYiTongMeterInfo.h"
#import "XTYiTongRechargeResult.h"
#import "XTYiTongParamSetting.h"
#import "XTYiTongCheckMeter.h"
#import "XTYiTongHistoryDay.h"


@interface XTBLEYiTongMeterRequest : NSObject

@property (nonatomic, assign) long rechargeCount;    //当前充值次数 defualt is 0;

+ (id)sharedRequest;

/**
 读表基本信息命令
 
 @param userNumber 用户号
 @param success model: XTYiTongMeterInfo
 @param failure error
 */
- (void)readMeterWithUserNumber:(NSString *)userNumber success:(void(^)(XTYiTongMeterInfo *model))success failure:(void(^)(NSError *error))failure;


/**
 充值命令
 
 @param encodeString 24位短充值命令
 @param paramSettingInfo 设置参数信息(不传:代表不需要设置信息)
 @param desCmd 加密字符串
 @param random 随机数
 @param success XTYiTongRechargeResult
 @param failure error
 */
- (void)rechargeWithEncodeString:(NSString *)encodeString paramSettingInfo:(XTYiTongParamSetting *)paramSettingInfo desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(XTYiTongRechargeResult *model))success failure:(void(^)(NSError *error))failure;

/**
 校时命令
 
 @param userNumber 用户号
 @param time 校时时间
 @param success newTime时间
 @param failure error
 */
- (void)checkTimeByteWithUserNumber:(NSString *)userNumber time:(NSString *)time success:(void(^)(NSString *newTime))success failure:(void(^)(NSError *error))failure;

/**
 读历史回抄数据命令
 
 @param userNumber 用户号
 @param index 抄表序号
 @param success array
 @param failure error
 */
- (void)readFreezeDayWithUserNumber:(NSString *)userNumber index:(int)index success:(void(^)(NSArray <XTYiTongHistoryDay *>*array))success failure:(void(^)(NSError *error))failure;

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
- (void)securityCheckWithUserNumber:(NSString *)userNumber checkMan:(NSString *)checkMan periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(BOOL result))success failure:(void(^)(NSError *error))failure;

/**
 设置表底数命令
 
 @param userNumber 用户号
 @param number 表底数
 @param success result 返回表底数
 @param failure error
 */
- (void)baseSettingWithUserNumber:(NSString *)userNumber number:(long)number success:(void(^)(long number))success failure:(void(^)(NSError *error))failure;

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
- (void)emergencyWithUserNumber:(NSString *)userNumber warning:(NSString *)warning periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(BOOL result))success failure:(void(^)(NSError *error))failure;

/**
 检查命令第一帧
 
 @param userNumber 用户号
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @param success XTYiTongCheckMeterFirst
 @param failure error
 */
- (void)checkFirstWithUserNumber:(NSString *)userNumber periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(XTYiTongCheckMeterFirst *firstInfo))success failure:(void(^)(NSError *error))failure;

/**
 检查命令第二帧
 
 @param userNumber 用户号
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @param success XTYiTongCheckMeterSecond
 @param failure error
 */
- (void)checkSecondWithUserNumber:(NSString *)userNumber periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(XTYiTongCheckMeterSecond *secondInfo))success failure:(void(^)(NSError *error))failure;

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
- (void)paramSettingWithUserNumber:(NSString *)userNumber XTYiTongParamSetting:(XTYiTongParamSetting *)model periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(BOOL result))success failure:(void(^)(NSError *error))failure;

/**
 清零卡命令
 
 @param userNumber 用户号
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @param success result bool
 @param failure error
 */
- (void)clearZeroWithUserNumber:(NSString *)userNumber periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random success:(void(^)(BOOL result))success failure:(void(^)(NSError *error))failure;


/**
 修改设备名称

 @param deviceName 新设备名
 @param success success
 @param failure error
 */
- (void)changeDeviceName:(NSString *)deviceName success:(void(^)())success failure:(void(^)(NSError *error))failure;


@end
