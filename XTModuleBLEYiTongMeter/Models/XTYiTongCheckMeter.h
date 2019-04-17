//
//  XTYiTongCheckMeter.h
//  SuntrontBlueTooth
//
//  Created by apple on 2017/8/11.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTPriceGroupInfo.h"

/** 检查表信息-----第一帧数据*/
@interface XTYiTongCheckMeterFirst : NSObject

@property (nonatomic, strong) NSString *version;    //密钥版本号
@property (nonatomic, strong) NSString *buyDate;    //用户购气日期
@property (nonatomic, strong) NSString *rechargePeriodTime; //充值有效期
@property (nonatomic, strong) NSString *userNumberStr;      //用户号
@property (nonatomic, assign) long userType;         //用户类型
@property (nonatomic, assign) long buyGasCount;      //购气次数
@property (nonatomic, assign) long leak;             //泄露功能
@property (nonatomic, assign) long serialHours;      //连续用气小时数
@property (nonatomic, assign) long warnLockFun;      //报警联动自锁功能
@property (nonatomic, assign) long longNotUserLockFun;      //长期不用气自锁功能
@property (nonatomic, assign) long notUseDay1;       //不用气自锁天数1
@property (nonatomic, assign) long notUseDay2;       //不用气自锁天数2
@property (nonatomic, assign) long overFun;          //过流功能
@property (nonatomic, assign) long overCount;        //过流量
@property (nonatomic, assign) long overTimeFun;      //过流时间启用
@property (nonatomic, assign) long overTime;         //过流时间
@property (nonatomic, assign) long limitBuyFun;      //限购功能
@property (nonatomic, assign) long limitUp;          //限购充值上限
@property (nonatomic, assign) long lowWarnMoney;     //蜂鸣器低额提醒金额
@property (nonatomic, assign) long warn1Fun;         //启动报警1功能
@property (nonatomic, assign) long warn1Value;       //报警值1
@property (nonatomic, assign) long warn2Fun;         //启动报警2功能
@property (nonatomic, assign) long warn2Value;       //报警值2
@property (nonatomic, assign) long zeroClose;        //0元关阀功能
@property (nonatomic, assign) long securityFun;      //启动安检功能
@property (nonatomic, assign) long securityMonth;    //安检月份
@property (nonatomic, assign) long scrapFun;         //启动报废表功能
@property (nonatomic, assign) long scrapYear;        //报废表年期
@property (nonatomic, assign) long versonFlag;       //版本标志
@property (nonatomic, strong) NSString *cardFlag;    //用户卡类型
@property (nonatomic, strong) NSString *recordDay;   //累计消耗量记录日
@property (nonatomic, strong) XTPriceGroupInfo *curPriceG1;  //当前使用价格组1
@property (nonatomic, strong) XTPriceGroupInfo *curPriceG2;  //当前使用价格组2
@property (nonatomic, strong) XTPriceGroupInfo *nwPriceG1;   //新价格组1
@property (nonatomic, strong) XTPriceGroupInfo *nwPriceG2;   //新价格组2
@property (nonatomic, strong) NSString *nwPriceStartTime;   //新单价生效日期
@property (nonatomic, strong) NSArray *priceStartRepeat;    //价格启用循环
@property (nonatomic, strong) NSArray *nwPriceStartRepeat;  //新价格启用循环
@property (nonatomic, strong) NSString *valuationWay;       //计费方式

@end


/** 检查表信息-----第二帧数据*/
@interface XTYiTongCheckMeterSecond : NSObject

@property (nonatomic, strong) NSString *timeStr;     //表当前时间
@property (nonatomic, assign) long basePrice;        //表当前单价（元）0.01
@property (nonatomic, assign) long remainPrice;      //剩余金额（元或m³）0.1
@property (nonatomic, assign) long totalPrice;       //累计购气金额（元或m³）0.1
@property (nonatomic, assign) long totalUseGas;      //累计用气量（m³）0.1
@property (nonatomic, assign) long unUseDay;         //无用气天数
@property (nonatomic, assign) long unUseSecond;      //无用气秒数
@property (nonatomic, strong) NSString *state;      //表状态
@property (nonatomic, strong) NSString *stateWord;  //消费交易状态字
@property (nonatomic, strong) NSMutableArray *historyArray;     //月累计消耗量
@property (nonatomic, assign) long securityCout;                 //安检返写条数
@property (nonatomic, strong) NSMutableArray *checkRecordArray; //安检返写记录
@property (nonatomic, strong) NSString *recentColseRec;         //最近一次关阀记录
@property (nonatomic, assign) long nfcCount;         //NFC购气次数
@property (nonatomic, assign) long nfcBuy;        //NFC购气金额（元或m³）0.1
@property (nonatomic, assign) long nsfTotalBuy;   //NFC累计购气金额（元或m³）0.1
@property (nonatomic, strong) NSArray *historyMonthList;//月累计消耗量日期
@property (nonatomic, strong) NSString *adjustDate;     //TCIS调价日
@property (nonatomic, assign) long adjustBottomNum;     //TCIS调价日表底数
@property (nonatomic, strong) NSString *payDate;        //刷表充值日
@property (nonatomic, assign) long payBottomNum;        //刷表充值日表底数

@end

/** 检查表信息 */
@interface XTYiTongCheckMeter : NSObject

//-----第一帧-----数据
@property (nonatomic, strong) XTYiTongCheckMeterFirst *firstInfo;

//-----第二帧-----数据
@property (nonatomic, strong) XTYiTongCheckMeterSecond *secondInfo;

@end
