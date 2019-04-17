//
//  XTYiTongRechargeResult.h
//  SuntrontBlueTooth
//
//  Created by apple on 2017/8/11.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 充值结果model */
@interface XTYiTongRechargeResult : NSObject

@property (nonatomic, assign) BOOL isSet;           //是否设置参数
@property (nonatomic, assign) long NFCCount;        //NFC充值次数
@property (nonatomic, assign) long remainPrice;     //剩余金额（元或m³）0.1
@property (nonatomic, assign) long totalPrice;      //累计购气金额（元或m³）0.1
@property (nonatomic, assign) long totalUseGas;     //累计用气量（m³）0.1
@property (nonatomic, assign) long baseCount;       //表底数
@property (nonatomic, strong) NSString *state;      //表状态
@property (nonatomic, strong) NSString *rechargeState;//充值状态

//以下是设置参数 增加的返回值
@property (nonatomic, strong) NSMutableArray *historyArray; //月累计消耗量
@property (nonatomic, strong) NSArray *historyMonthList;    //月累计消耗量日期
@property (nonatomic, strong) NSString *adjustDate;         //TCIS调价日
@property (nonatomic, assign) long adjustBottomNum;         //TCIS调价日表底数
@property (nonatomic, strong) NSString *payDate;            //刷表充值日
@property (nonatomic, assign) long payBottomNum;            //刷表充值日表底数
@property (nonatomic, strong) NSString *valuationWay;       //计费方式

@end
