//
//  XTYiTongMeterInfo.h
//  SuntrontBlueTooth
//
//  Created by apple on 2017/8/11.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 读表model */
@interface XTYiTongMeterInfo : NSObject

@property (nonatomic, strong) NSString *timeStr;    //表当前时间
@property (nonatomic, assign) long basePrice;       //表当前单价（元）0.01
@property (nonatomic, assign) long remainPrice;     //剩余金额（元或m³）0.1
@property (nonatomic, assign) long totalPrice;      //累计购气金额（元或m³）0.1
@property (nonatomic, assign) long totalUseGas;     //累计用气量（m³）0.1
@property (nonatomic, assign) long unUseDay;        //无用气天数
@property (nonatomic, assign) long unUseSecond;     //无用气秒数
@property (nonatomic, strong) NSString *state;      //表状态
@property (nonatomic, strong) NSString *stateWord;  //消费交易状态字
@property (nonatomic, strong) NSMutableArray *historyArray;     //月累计消耗量
@property (nonatomic, assign) long securityCout;                //安检返写条数
@property (nonatomic, strong) NSMutableArray *checkRecordArray; //安检返写记录
@property (nonatomic, strong) NSString *recentColseRec;         //最近一次关阀记录
@property (nonatomic, assign) long nfcCount;        //NFC购气次数
@property (nonatomic, assign) long nfcBuy;          //NFC购气金额（元或m³）0.1
@property (nonatomic, assign) long nsfTotalBuy;     //NFC累计购气金额（元或m³）0.1

@end
