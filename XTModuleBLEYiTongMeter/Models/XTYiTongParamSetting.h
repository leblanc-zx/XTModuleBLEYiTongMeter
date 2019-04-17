//
//  XTYiTongParamSetting.h
//  SuntrontBlueTooth
//
//  Created by apple on 2017/8/11.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTPriceGroupInfo.h"

@interface XTYiTongParamSetting : NSObject

@property (nonatomic, assign) long leak;            //泄露功能
@property (nonatomic, assign) long serialHours;     //连续用气小时数
@property (nonatomic, assign) long warnLockFun;     //报警联动自锁功能
@property (nonatomic, assign) long longNotUserLockFun;//长期不用气自锁功能
@property (nonatomic, assign) long notUseDay1;      //不用气自锁天数1
@property (nonatomic, assign) long notUseDay2;      //不用气自锁天数2
@property (nonatomic, assign) long overFun;         //过流功能
@property (nonatomic, assign) long overCount;       //过流量
@property (nonatomic, assign) long overTimeFun;     //过流时间启用
@property (nonatomic, assign) long overTime;        //过流时间
@property (nonatomic, assign) long limitBuyFun;     //限购功能
@property (nonatomic, assign) long limitUp;         //限购充值上限
@property (nonatomic, assign) long lowWarnMoney;    //蜂鸣器低额提醒金额
@property (nonatomic, assign) long warn1Fun;        //启动报警1功能
@property (nonatomic, assign) long warn1Value;      //报警值1
@property (nonatomic, assign) long warn2Fun;        //启动报警2功能
@property (nonatomic, assign) long warn2Value;      //报警值2
@property (nonatomic, assign) long zeroClose;       //0元关阀功能
@property (nonatomic, assign) long securityFun;     //启动安检功能
@property (nonatomic, assign) long securityMonth;   //安检月份
@property (nonatomic, assign) long scrapFun;        //启动报废表功能
@property (nonatomic, assign) long scrapYear;       //报废表年期
@property (nonatomic, strong) NSString *recordDay;  //累计消耗量记录日
@property (nonatomic, strong) XTPriceGroupInfo *curPriceG1; //当前使用价格组1
@property (nonatomic, strong) XTPriceGroupInfo *curPriceG2; //当前使用价格组2
@property (nonatomic, strong) XTPriceGroupInfo *nwPriceG1;  //新价格组1
@property (nonatomic, strong) XTPriceGroupInfo *nwPriceG2;  //新价格组2
@property (nonatomic, strong) NSString *nwPriceStartTime;  //新单价生效日期
@property (nonatomic, strong) NSMutableArray *priceStartRepeat;   //价格启用循环
@property (nonatomic, strong) NSMutableArray *nwPriceStartRepeat; //新价格启用循环
@property (nonatomic, strong) NSString *valuationWay;      //计费方式
@property (nonatomic, strong) NSString *periodTime;        //有效期

@end
