//
//  XTBLEYiTongMeterParse.m
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "XTBLEYiTongMeterParse.h"
#import "DesEntry.h"
#import "XTUtils.h"

@implementation XTBLEYiTongMeterParse

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

+ (id)sharedParse
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    
    return _instace;
}

/** 发现错误 */
- (NSError *)findErrorWithData:(NSData *)data {
    if (data.length >= 4) {
        Byte bytes[] = {0x68,0x30,0xFF,0x0B};
        
        NSData *headerData = [NSData dataWithBytes:bytes length:4];
        
        NSData *newData = [data subdataWithRange:NSMakeRange(0, 4)];
        
        if ([newData isEqualToData:headerData]) {
            //找到错误
            
            if (data.length >= 15) {
                NSData *errorData = [data subdataWithRange:NSMakeRange(4+10, 1)];
                Byte *errorByte = malloc(errorData.length);
                memcpy(errorByte, errorData.bytes, errorData.length);
                int errorCode = errorByte[0]&0xff;
                
                NSError *error;
                switch (errorCode) {
                    case 1:
                        error = [NSError errorWithDomain:@"错误" code:errorCode userInfo:@{@"NSLocalizedDescription": @"帧头不合法"}];
                        break;
                    case 2:
                        error = [NSError errorWithDomain:@"错误" code:errorCode userInfo:@{@"NSLocalizedDescription": @"帧尾不合法"}];
                        break;
                    case 3:
                        error = [NSError errorWithDomain:@"错误" code:errorCode userInfo:@{@"NSLocalizedDescription": @"帧校验错误"}];
                        break;
                    case 4:
                        error = [NSError errorWithDomain:@"错误" code:errorCode userInfo:@{@"NSLocalizedDescription": @"充值命令解密错误"}];
                        break;
                    case 5:
                        error = [NSError errorWithDomain:@"错误" code:errorCode userInfo:@{@"NSLocalizedDescription": @"电子工具卡用户号和表不一致"}];
                        break;
                    case 6:
                        error = [NSError errorWithDomain:@"错误" code:errorCode userInfo:@{@"NSLocalizedDescription": @"电子充值卡用户号和表不一致"}];
                        break;
                    case 7:
                        error = [NSError errorWithDomain:@"错误" code:errorCode userInfo:@{@"NSLocalizedDescription": @"未知错误7"}];
                        break;
                    case 8:
                        error = [NSError errorWithDomain:@"错误" code:errorCode userInfo:@{@"NSLocalizedDescription": @"电子工具卡密码错误"}];
                        break;
                    case 9:
                        error = [NSError errorWithDomain:@"错误" code:errorCode userInfo:@{@"NSLocalizedDescription": @"电子工具卡过有效期"}];
                        break;
                    case 10:
                        error = [NSError errorWithDomain:@"错误" code:errorCode userInfo:@{@"NSLocalizedDescription": @"数据域长度不合法"}];
                        break;
                    case 11:
                        error = [NSError errorWithDomain:@"错误" code:errorCode userInfo:@{@"NSLocalizedDescription": @"非法控制字"}];
                        break;
                        
                    default:
                        error = [NSError errorWithDomain:@"错误" code:errorCode userInfo:@{@"NSLocalizedDescription": @"未知错误"}];
                        break;
                }
                
                return error;
            }
            
        }
    }
    
    return nil;
}

#pragma -mark 读表基本信息命令
/**
 读表基本信息命令 send
 
 @param userNumber 用户号
 @return data
 */
- (NSData *)readMeterWithUserNumber:(NSString *)userNumber {
    
    NSMutableData *data = [[NSMutableData alloc] init];

    //头 + 表类型 + 控制字 + 长度
    Byte bytes[] = {0x68,0x30,0x3A,0x0A};
    [data appendData:[NSData dataWithBytes:bytes length:4]];
    
    //Data number
    [data appendData:[XTUtils dataWithHexString:userNumber]];
    
    //校验和算法
    [data appendData:[XTUtils checksumDataWithOriginData:data]];
    
    //尾
    Byte endBytes[] = {0x16};
    [data appendData:[NSData dataWithBytes:endBytes length:1]];
    
    return data;

}

/**
 读表基本信息命令 parse
 
 @param data 蓝牙表返回的data
 @return XTYiTongMeterInfo
 */
- (XTYiTongMeterInfo *)parseReadMeterByte:(NSData *)data {
    
    //开始解析
    NSData *subData = [data subdataWithRange:NSMakeRange(4, 162)];
    
    XTYiTongMeterInfo *model = [[XTYiTongMeterInfo alloc] init];
    
    //表当前时间
    NSData *timeData = [subData subdataWithRange:NSMakeRange(10, 7)];
    model.timeStr = [XTUtils hexStringWithData:timeData];
    //表当前单价(元)
    NSData *basePriceData = [subData subdataWithRange:NSMakeRange(17, 2)];
    long basePrice = [XTUtils longWithData:basePriceData];
    model.basePrice = basePrice;
    //剩余金额（元或m³）
    NSData *priceData = [subData subdataWithRange:NSMakeRange(19, 4)];
    long price = [XTUtils longWithData:priceData];
    model.remainPrice = price;
    //累计购气金额（元或m³）
    NSData *buyPriceData = [subData subdataWithRange:NSMakeRange(23, 4)];
    long buyPrice = [XTUtils longWithData:buyPriceData];
    model.totalPrice = buyPrice;
    //累计用气量（m³）
    NSData *useGasNumberData = [subData subdataWithRange:NSMakeRange(27, 4)];
    long useGasNumber = [XTUtils longWithData:useGasNumberData];
    model.totalUseGas = useGasNumber;
    //无用气天数
    NSData *unUseDayData = [subData subdataWithRange:NSMakeRange(31, 1)];
    long unUseDay = [XTUtils longWithData:unUseDayData];
    model.unUseDay = (int)unUseDay;
    //无用气秒数
    NSData *unUseSecondData = [subData subdataWithRange:NSMakeRange(32, 2)];
    long unUseSecond = [XTUtils longWithData:unUseSecondData];
    model.unUseSecond = (int)unUseSecond;
    //表状态
    NSData *stateData = [subData subdataWithRange:NSMakeRange(34, 2)];//189-190
    NSString *state = [XTUtils hexStringWithData:stateData];
    model.state = state;
    //消费交易状态字
    NSData *changeStateData = [subData subdataWithRange:NSMakeRange(36, 1)];// //(37, 4) (41, 4) (45, 84) (129, 4) (133, 1)
    NSString *changeState = [XTUtils hexStringWithData:changeStateData];
    model.stateWord = changeState;
    //月累计消耗量
    NSData *historyData = [subData subdataWithRange:NSMakeRange(37, 96)];
    model.historyArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < historyData.length; i += 4) {
        NSData *subHistoryData = [historyData subdataWithRange:NSMakeRange(i, 4)];
        long history = [XTUtils longWithData:subHistoryData];
        [model.historyArray addObject:[NSNumber numberWithDouble:(history)]];
    }
    //安检返写条数
    NSData *checkNumData = [subData subdataWithRange:NSMakeRange(133, 1)];
    long checkNum = [XTUtils longWithData:checkNumData];
    model.securityCout = (int)checkNum;
    //安检返写记录
    NSData *checkRecordData = [subData subdataWithRange:NSMakeRange(134, 6*3)];
    model.checkRecordArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; i ++) {
        NSData *subCheckRecord = [checkRecordData subdataWithRange:NSMakeRange(i*6, 6)];
        //前三个字节是安检编号
        NSString *subNumber = [XTUtils hexStringWithData:[subCheckRecord subdataWithRange:NSMakeRange(0, 3)]];
        //后三个字节是时间
        NSString *subYear = [NSString stringWithFormat:@"%ld",[XTUtils longWithData:[subCheckRecord subdataWithRange:NSMakeRange(3, 1)]]];
        NSString *subMonth = [NSString stringWithFormat:@"%ld",[XTUtils longWithData:[subCheckRecord subdataWithRange:NSMakeRange(4, 1)]]];
        NSString *subDay = [NSString stringWithFormat:@"%ld",[XTUtils longWithData:[subCheckRecord subdataWithRange:NSMakeRange(5, 1)]]];
        NSString *checkRecord = [NSString stringWithFormat:@"%@%@%@%@",subNumber,subYear,subMonth,subDay];
        [model.checkRecordArray addObject:checkRecord];
    }
    //最近一次关阀记录
    NSData *lastClose = [subData subdataWithRange:NSMakeRange(152, 1)];
    model.recentColseRec = [XTUtils hexStringWithData:lastClose];
    //NFC购气次数
    NSData *nfcCountData = [subData subdataWithRange:NSMakeRange(153, 1)];
    model.nfcCount = (int)[XTUtils longWithData:nfcCountData];
    //NFC购气金额
    NSData *nfcBuyData = [subData subdataWithRange:NSMakeRange(154, 4)];
    long nfcBuy = [XTUtils longWithData:nfcBuyData];
    model.nfcBuy = nfcBuy;
    //NFC累计购气金额
    NSData *nsfTotalBuyData = [subData subdataWithRange:NSMakeRange(158, 4)];
    long nsfTotalBuy = [XTUtils longWithData:nsfTotalBuyData];
    model.nsfTotalBuy = nsfTotalBuy;
    
    return model;
    
}

#pragma -mark 充值命令
/**
 充值命令 send
 
 @param encodeString 24位短充值命令
 @param paramSettingInfo 设置参数信息(不传:代表不需要设置参数)
 @param desCmd 加密字符串
 @param random 随机数
 @return data
 */
- (NSData *)getRechargeByteWithEncodeString:(NSString *)encodeString paramSettingInfo:(XTYiTongParamSetting *)paramSettingInfo desCmd:(NSString *)desCmd random:(NSString *)random {
    
    NSMutableData *data = [[NSMutableData alloc] init];

    if (paramSettingInfo) {
        
        //头 + 表类型 + 控制字 + 长度
        Byte bytes[] = {0x68,0x30,0x19,0xd5};
        [data appendData:[NSData dataWithBytes:bytes length:4]];
        
        //Data 24位
        [data appendData:[XTUtils dataWithHexString:encodeString]];
        
        //Data 189位
        NSMutableData *data89 = [[NSMutableData alloc] init];
        [data89 appendData:[XTUtils dataWithHexString:@"AA"]];
        
        NSData *paramData = [self getParamDataWithXTYiTongParamSetting:paramSettingInfo];
        NSData *sumData = [XTUtils checksumDataWithOriginData:paramData];
        [data89 appendData:paramData];
        [data89 appendData:sumData];
        
        NSData *desCmdData = [XTUtils dataWithHexString:[desCmd substringWithRange:NSMakeRange(0, 16)]];
        [data89 appendData:desCmdData];
        [data89 appendData:[XTUtils dataWithHexString:random]];
        [data appendData:data89];
        
        
    } else {
        
        //头 + 表类型 + 控制字 + 长度
        Byte bytes[] = {0x68,0x30,0x19,0x18};
        [data appendData:[NSData dataWithBytes:bytes length:4]];
        
        //Data 24位
        [data appendData:[XTUtils dataWithHexString:encodeString]];
        
        
    }
    
    
    //校验和算法
    [data appendData:[XTUtils checksumDataWithOriginData:data]];
    
    //尾
    Byte endBytes[] = {0x16};
    [data appendData:[NSData dataWithBytes:endBytes length:1]];
    
    return data;
}


/**
 根据设置信息获取NSData

 @param model XTYiTongParamSetting
 @return NSData
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

/**
 充值命令 parse
 
 @param data 蓝牙表返回的data
 @param isSet 设置参数bool
 @return XTYiTongRechargeResult
 */
- (XTYiTongRechargeResult *)parseRechargeByte:(NSData *)data isSet:(BOOL)isSet {
    
    //开始解析
    
    NSData *subData = [data subdataWithRange:NSMakeRange(4, 185)];
    
    XTYiTongRechargeResult *model = [[XTYiTongRechargeResult alloc] init];
    model.isSet = isSet;
    
    //充值次数
    NSData *NFCCountData = [subData subdataWithRange:NSMakeRange(10, 1)];
    model.NFCCount = [XTUtils longWithData:NFCCountData];
    
    //剩余金额（元或m³）
    NSData *remainPriceData = [subData subdataWithRange:NSMakeRange(11, 4)];
    NSData *remainPriceDataBuf = [XTUtils reverseDataWithOriginData:remainPriceData];
    model.remainPrice = [XTUtils longWithData:remainPriceDataBuf];
    
    //累计购气金额（元或m³）
    NSData *totalPriceData = [subData subdataWithRange:NSMakeRange(15, 4)];
    NSData *totalPriceDataBuf = [XTUtils reverseDataWithOriginData:totalPriceData];
    model.totalPrice = [XTUtils longWithData:totalPriceDataBuf];
    
    //累计用气量
    NSData *totalUseGasData = [subData subdataWithRange:NSMakeRange(19, 4)];
    NSData *totalUseGasDataBuf = [XTUtils reverseDataWithOriginData:totalUseGasData];
    model.totalUseGas = [XTUtils longWithData:totalUseGasDataBuf];
    
    //表状态
    NSData *stateData = [subData subdataWithRange:NSMakeRange(23, 2)];
    model.state = [XTUtils hexStringWithData:stateData];

    //充值状态
    NSData *rechargeStateData = [subData subdataWithRange:NSMakeRange(25, 1)];
    model.rechargeState = [XTUtils hexStringWithData:rechargeStateData];
    
    if (isSet) {
        //月累计消耗量
        NSData *historyData = [subData subdataWithRange:NSMakeRange(26, 96)];
        model.historyArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < historyData.length; i += 4) {
            NSData *subHistoryData = [historyData subdataWithRange:NSMakeRange(i, 4)];
            long history = [XTUtils longWithData:subHistoryData];
            [model.historyArray addObject:[NSNumber numberWithDouble:(history)]];
        }
        //月累计消耗量日期
        NSData *historyMonthListData = [subData subdataWithRange:NSMakeRange(122, 48)];
        model.historyMonthList = [XTUtils fourStringArrayWithOriginString:[XTUtils hexStringWithData:historyMonthListData]];
        //TCIS调价日
        NSData *adjustDateData = [subData subdataWithRange:NSMakeRange(170, 3)];
        model.adjustDate = [XTUtils hexStringWithData:adjustDateData];
        //TCIS调价日表底数
        NSData *adjustBottomNumData = [subData subdataWithRange:NSMakeRange(173, 4)];
        model.adjustBottomNum = [XTUtils longWithData:adjustBottomNumData];
        //刷表充值日
        NSData *payDateData = [subData subdataWithRange:NSMakeRange(177, 3)];
        model.payDate = [XTUtils hexStringWithData:payDateData];
        //刷表充值日表底数
        NSData *payBottomNumData = [subData subdataWithRange:NSMakeRange(180, 4)];
        model.payBottomNum = [XTUtils longWithData:payBottomNumData];
        //计费方式
        NSData *valuationWayData = [subData subdataWithRange:NSMakeRange(184, 1)];
        model.valuationWay = [XTUtils hexStringWithData:valuationWayData];
    }
    
    return model;
}

#pragma -mark 校时命令

/**
 校时命令 send

 @param userNumber 用户号
 @param time 校时时间
 @return data
 */
- (NSData *)getCheckTimeByteWithUserNumber:(NSString *)userNumber time:(NSString *)time {
    NSMutableData *data = [[NSMutableData alloc] init];
    
    //头 + 表类型 + 控制字 + 长度
    Byte bytes[] = {0x68,0x30,0x79,0x10};
    [data appendData:[NSData dataWithBytes:bytes length:4]];
    
    //Data number
    [data appendData:[XTUtils dataWithHexString:userNumber]];
    
    //Data 时间
    [data appendData:[XTUtils dataWithHexString:time]];
    
    //校验和算法
    [data appendData:[XTUtils checksumDataWithOriginData:data]];
    
    //尾
    Byte endBytes[] = {0x16};
    [data appendData:[NSData dataWithBytes:endBytes length:1]];
    
    //NSLog(@"===data===%@",data);
    
    return data;
}


/**
 校时命令 parse

 @param data 蓝牙表返回的data
 @param year 年开头（例如2010：20 1910：19）
 @return result 日期，nil代表解析失败
 */
- (NSString *)parseCheckTimeByte:(NSData *)data withYear:(NSString *)year {
    
    NSData *subData = [data subdataWithRange:NSMakeRange(4, 16)];
    NSData *timeData = [subData subdataWithRange:NSMakeRange(10, 6)];
    
    NSString *yearT = year;
    if (year.length != 2) {
        yearT = @"20";
    }
    NSMutableString *timeStr = [[NSMutableString alloc] initWithString:yearT];
    
    //data 转 16进制字符串
    [timeStr appendString:[XTUtils hexStringWithData:timeData]];
    
    NSDate *date = [XTUtils dateFromTimeString:timeStr formatter:@"YYYYMMddHHmmss"];
    
    return [XTUtils timeStringFromDate:date formatter:@"YYYY-MM-dd HH:mm:ss"];
    
}

#pragma -mark 读历史回抄数据命令

/**
 读历史回抄数据命令 send

 @param userNumber 用户号
 @param index 抄表序号
 @return data
 */
- (NSData *)getHistoryDayWithUserNumber:(NSString *)userNumber index:(int)index {
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    //头 + 表类型 + 控制字 + 长度
    Byte bytes[] = {0x68,0x30,0x50,0x0B};
    [data appendData:[NSData dataWithBytes:bytes length:4]];
    
    //Data number
    [data appendData:[XTUtils dataWithHexString:userNumber]];
    
    //Data index
    Byte indexBytes[] = {(Byte)(index & 0xff)};
    [data appendData:[NSData dataWithBytes:indexBytes length:1]];
    
    //校验和算法
    [data appendData:[XTUtils checksumDataWithOriginData:data]];
    
    //尾
    Byte endBytes[] = {0x16};
    [data appendData:[NSData dataWithBytes:endBytes length:1]];
    
    //NSLog(@"===data===%@",data);
    
    return data;
    
}


/**
 读历史回抄数据命令 parse

 @param data 蓝牙表返回的data
 @return 数组 nil代表解析失败
 */
- (NSArray *)parseHistoryData:(NSData *)data {
    
    NSData *subData = [data subdataWithRange:NSMakeRange(4, 228)];
    NSData *listData = [subData subdataWithRange:NSMakeRange(10+1, 217)];
    NSMutableArray *listArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 31; i ++) {
        NSData *itemData = [listData subdataWithRange:NSMakeRange(i*7, 7)];
        
        //用量
        long result = [XTUtils longWithData:[itemData subdataWithRange:NSMakeRange(0, 4)]];
//        Byte ttt[] = {0x12,0x34,0x56,0x78};
//        long result = [self longWithData:[NSData dataWithBytes:ttt length:4]];
        
        //日期
        NSData *timeData = [itemData subdataWithRange:NSMakeRange(4, 3)];
        
        NSString *hexStr = [XTUtils hexStringWithData:timeData];
        
        if (![hexStr isEqualToString:@"000000"]) {
            
            NSMutableString *timeStr = [[NSMutableString alloc] initWithString:@"20"];
            
            for (int i = 0; i < hexStr.length / 2; i ++) {
                [timeStr appendString:[hexStr substringWithRange:NSMakeRange(i*2, 2)]];
                if (i == 2) {
                } else {
                    [timeStr appendString:@"-"];
                }
            }
            
            XTYiTongHistoryDay *model = [[XTYiTongHistoryDay alloc] init];
            model.time = timeStr;
            model.sum = result;
            [listArray addObject:model];
        }
        
    }
    
    return listArray;
}

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
- (NSData *)getSecurityCheckWithUserNumber:(NSString *)userNumber checkMan:(NSString *)checkMan periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random {
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    //头 + 表类型 + 控制字 + 长度
    Byte bytes[] = {0x68,0x30,0x56,0x20};
    [data appendData:[NSData dataWithBytes:bytes length:4]];
    
    //Data number
    [data appendData:[XTUtils dataWithHexString:userNumber]];
    
    //Data 安检员编号
    NSData *checkManBytes = [XTUtils dataWithLong:[checkMan intValue] length:3];
    [data appendData:checkManBytes];
    
    //Data 有效期
    [data appendData:[XTUtils dataWithHexString:periodTime]];
    
    //Data 密文口令
    NSString *randomStr = random;
    NSString *securityStr = desCmd;
    if (securityStr.length > 16) {
        securityStr = [securityStr substringWithRange:NSMakeRange(0, 16)];
    }
    [data appendData:[XTUtils dataWithHexString:securityStr]];
    
    //Data 随机数
    [data appendData:[XTUtils dataWithHexString:randomStr]];
    
    //校验和算法
    [data appendData:[XTUtils checksumDataWithOriginData:data]];
    
    //尾
    Byte endBytes[] = {0x16};
    [data appendData:[NSData dataWithBytes:endBytes length:1]];
    
    //NSLog(@"===data===%@",data);
    
    return data;
}

/**
 安检命令 parse

 @param data 蓝牙表返回的data
 @return result 55安检成功，其它安检失败，nil解析失败
 */
- (NSString *)parseSecurityCheckData:(NSData *)data {
    
    NSData *subData = [data subdataWithRange:NSMakeRange(4, 11)];
    NSData *resultData = [subData subdataWithRange:NSMakeRange(10, 1)];
    
    NSString *result = [XTUtils hexStringWithData:resultData];
    return result;
}

#pragma -mark 设置表底数命令

/**
 设置表底数命令 send

 @param userNumber 用户号
 @param number 表底数
 @return data
 */
- (NSData *)getBaseSettingWithUserNumber:(NSString *)userNumber number:(long)number {
    NSMutableData *data = [[NSMutableData alloc] init];
    
    //头 + 表类型 + 控制字 + 长度
    Byte bytes[] = {0x68,0x30,0x49,0x0e};
    [data appendData:[NSData dataWithBytes:bytes length:4]];
    
    //Data number
    [data appendData:[XTUtils dataWithHexString:userNumber]];
    
    //Data 表底数
    NSData *checkManBytes = [XTUtils dataWithLong:number length:4];
    NSData *checkManData = [XTUtils reverseDataWithOriginData:checkManBytes];
    [data appendData:checkManData];
    
    //校验和算法
    [data appendData:[XTUtils checksumDataWithOriginData:data]];
    
    //尾
    Byte endBytes[] = {0x16};
    [data appendData:[NSData dataWithBytes:endBytes length:1]];
    
    //NSLog(@"===data===%@",data);
    
    return data;
}

/**
 设置表底数命令 parse

 @param data 蓝牙表返回的data
 @return resultStr 用气量 nil代表解析失败
 */
- (NSString *)parseBaseSettingData:(NSData *)data {

    NSData *subData = [data subdataWithRange:NSMakeRange(4, 14)];
    NSData *resultData = [subData subdataWithRange:NSMakeRange(10, 4)];
    
    long result = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:resultData]];
    
    NSString *resultStr = [NSString stringWithFormat:@"%ld",result];
    
    return resultStr;
}

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
- (NSData *)getEmergencyWithUserNumber:(NSString *)userNumber warning:(NSString *)warning periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random {
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    //头 + 表类型 + 控制字 + 长度
    Byte bytes[] = {0x68,0x30,0x55,0x1E};
    [data appendData:[NSData dataWithBytes:bytes length:4]];
    
    //Data number
    [data appendData:[XTUtils dataWithHexString:userNumber]];
    
    //Data 报警2
    Byte warningBytes[] = {([warning intValue] & 0xff)};
    [data appendBytes:warningBytes length:1];
    
    //Data 有效期
    [data appendData:[XTUtils dataWithHexString:periodTime]];
    
    //Data 密文口令
    NSString *randomStr = random;
    NSString *securityStr = desCmd;
    if (securityStr.length > 16) {
        securityStr = [securityStr substringWithRange:NSMakeRange(0, 16)];
    }
    [data appendData:[XTUtils dataWithHexString:securityStr]];
    
    //Data 随机数
    [data appendData:[XTUtils dataWithHexString:randomStr]];
    
    //校验和算法
    [data appendData:[XTUtils checksumDataWithOriginData:data]];
    
    //尾
    Byte endBytes[] = {0x16};
    [data appendData:[NSData dataWithBytes:endBytes length:1]];
    
    //NSLog(@"===data===%@",data);
    
    return data;
}

/**
 应急卡命令 parse

 @param data 蓝牙表返回的data
 @return result 大于0应急成功，其它应急失败，nil解析失败
 */
- (NSString *)parseEmergencyData:(NSData *)data {
    
    NSData *subData = [data subdataWithRange:NSMakeRange(4, 11)];
    NSData *resultData = [subData subdataWithRange:NSMakeRange(10, 1)];
    
    NSString *result = [XTUtils hexStringWithData:resultData];
    return result;
}

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
- (NSData *)checkWithUserNumber:(NSString *)userNumber periodTime:(NSString *)periodTime num:(int)num desCmd:(NSString *)desCmd random:(NSString *)random {
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    //头 + 表类型 + 控制字 + 长度
    if (num == 1) {
        Byte bytes[] = {0x68,0x30,0x51,0x1d};
        [data appendData:[NSData dataWithBytes:bytes length:4]];
    } else if (num == 2) {
        Byte bytes[] = {0x68,0x30,0x52,0x1d};
        [data appendData:[NSData dataWithBytes:bytes length:4]];
    }
    
    //Data number
    [data appendData:[XTUtils dataWithHexString:userNumber]];
    
    //Data 有效期
    if (periodTime.length == 0) {
        periodTime = @"000000";
    }
    [data appendData:[XTUtils dataWithHexString:periodTime]];
    
    //Data 密文口令
    NSString *randomStr = random;
    NSString *securityStr = desCmd;
    if (securityStr.length > 16) {
        securityStr = [securityStr substringWithRange:NSMakeRange(0, 16)];
    }
    [data appendData:[XTUtils dataWithHexString:securityStr]];
    
    //Data 随机数
    [data appendData:[XTUtils dataWithHexString:randomStr]];
    
    //校验和算法
    [data appendData:[XTUtils checksumDataWithOriginData:data]];
    
    //尾
    Byte endBytes[] = {0x16};
    [data appendData:[NSData dataWithBytes:endBytes length:1]];
    
    //NSLog(@"===data===%@",data);
    
    return data;
    
}

/**
 检查第一帧命令 parse
 
 @param data 第一帧
 @return XTYiTongCheckMeterFirst nil解析失败
 */
- (XTYiTongCheckMeterFirst *)parseCheckFirstByte:(NSData *)data {
   
    NSData *subdata = [data subdataWithRange:NSMakeRange(4+10, 190)];
    
    XTYiTongCheckMeterFirst *model = [[XTYiTongCheckMeterFirst alloc] init];
    
    //密钥版本号
    NSData *versionData = [subdata subdataWithRange:NSMakeRange(0, 1)];
    model.version = [XTUtils hexStringWithData:versionData];
    //用户购气日期
    NSData *buyDateData = [subdata subdataWithRange:NSMakeRange(1, 3)];
    model.buyDate = [XTUtils hexStringWithData:buyDateData];
    //充值有效期
    NSData *rechargePeriodTimeData = [subdata subdataWithRange:NSMakeRange(4, 3)];
    model.rechargePeriodTime = [XTUtils hexStringWithData:rechargePeriodTimeData];
    //用户号
    NSData *userNumberStrData = [subdata subdataWithRange:NSMakeRange(7, 10)];
    model.userNumberStr = [XTUtils hexStringWithData:userNumberStrData];
    //用户类型
    NSData *userTypeData = [subdata subdataWithRange:NSMakeRange(17, 1)];
    model.userType = [XTUtils longWithData:userTypeData];
    //购气次数
    NSData *buyGasCountData = [subdata subdataWithRange:NSMakeRange(18, 1)];
    model.buyGasCount = [XTUtils longWithData:buyGasCountData];
    //泄露功能
    NSData *leakData = [subdata subdataWithRange:NSMakeRange(19, 1)];
    model.leak = [XTUtils longWithData:leakData];
    //连续用气小时数
    NSData *serialHoursData = [subdata subdataWithRange:NSMakeRange(20, 1)];
    model.serialHours = [XTUtils longWithData:serialHoursData];
    //报警联动自锁功能
    NSData *warnLockFunData = [subdata subdataWithRange:NSMakeRange(21, 1)];
    model.warnLockFun = [XTUtils longWithData:warnLockFunData];
    //长期不用气自锁功能
    NSData *longNotUserLockFunData = [subdata subdataWithRange:NSMakeRange(22, 1)];
    model.longNotUserLockFun = [XTUtils longWithData:longNotUserLockFunData];
    //不用气自锁天数1
    NSData *notUseDay1Data = [subdata subdataWithRange:NSMakeRange(23, 1)];
    model.notUseDay1 = [XTUtils longWithData:notUseDay1Data];
    //不用气自锁天数2
    NSData *notUseDay2Data = [subdata subdataWithRange:NSMakeRange(24, 1)];
    model.notUseDay2 = [XTUtils longWithData:notUseDay2Data];
    //过流功能
    NSData *overFunData = [subdata subdataWithRange:NSMakeRange(25, 1)];
    model.overFun = [XTUtils longWithData:overFunData];
    //过流量
    NSData *overCountData = [subdata subdataWithRange:NSMakeRange(26, 2)];
    model.overCount = [XTUtils longWithData:overCountData];
    //过流时间启用
    NSData *overTimeFunData = [subdata subdataWithRange:NSMakeRange(28, 1)];
    model.overTimeFun = [XTUtils longWithData:overTimeFunData];
    //过流时间
    NSData *overTimeData = [subdata subdataWithRange:NSMakeRange(29, 1)];
    model.overTime = [XTUtils longWithData:overTimeData];
    //限购功能
    NSData *limitBuyFunData = [subdata subdataWithRange:NSMakeRange(30, 1)];
    model.limitBuyFun = [XTUtils longWithData:limitBuyFunData];
    //限购充值上限
    NSData *limitUpData = [subdata subdataWithRange:NSMakeRange(31, 4)];
    model.limitUp = [XTUtils longWithData:limitUpData];
    //蜂鸣器低额提醒金额
    NSData *lowWarnMoneyData = [subdata subdataWithRange:NSMakeRange(35, 2)];
    model.lowWarnMoney = [XTUtils longWithData:lowWarnMoneyData];
    //启动报警1功能
    NSData *warn1FunData = [subdata subdataWithRange:NSMakeRange(37, 1)];
    model.warn1Fun = [XTUtils longWithData:warn1FunData];
    //报警值1
    NSData *warn1ValueData = [subdata subdataWithRange:NSMakeRange(38, 1)];
    model.warn1Value = [XTUtils longWithData:warn1ValueData];
    //启动报警2功能
    NSData *warn2FunData = [subdata subdataWithRange:NSMakeRange(39, 1)];
    model.warn2Fun = [XTUtils longWithData:warn2FunData];
    //报警值2
    NSData *warn2ValueData = [subdata subdataWithRange:NSMakeRange(40, 1)];
    model.warn2Value = [XTUtils longWithData:warn2ValueData];
    //0元关阀功能
    NSData *zeroCloseData = [subdata subdataWithRange:NSMakeRange(41, 1)];
    model.zeroClose = [XTUtils longWithData:zeroCloseData];
    //启动安检功能
    NSData *securityFunData = [subdata subdataWithRange:NSMakeRange(42, 1)];
    model.securityFun = [XTUtils longWithData:securityFunData];
    //安检月份
    NSData *securityMonthData = [subdata subdataWithRange:NSMakeRange(43, 1)];
    model.securityMonth = [XTUtils longWithData:securityMonthData];
    //启动报废表功能
    NSData *scrapFunData = [subdata subdataWithRange:NSMakeRange(44, 1)];
    model.scrapFun = [XTUtils longWithData:scrapFunData];
    //报废表年期
    NSData *scrapYearData = [subdata subdataWithRange:NSMakeRange(45, 1)];
    model.scrapYear = [XTUtils longWithData:scrapYearData];
    //版本标志
    NSData *versonFlagData = [subdata subdataWithRange:NSMakeRange(46, 1)];
    model.versonFlag = [XTUtils longWithData:versonFlagData];
    //用户卡类型
    NSData *cardFlagData = [subdata subdataWithRange:NSMakeRange(47, 1)];
    model.cardFlag = [XTUtils hexStringWithData:cardFlagData];
    //累计消耗量记录日
    NSData *recordDayData = [subdata subdataWithRange:NSMakeRange(48, 1)];
    model.recordDay = [XTUtils hexStringWithData:recordDayData];
    //当前使用价格组1
    NSData *curPriceG1Data = [subdata subdataWithRange:NSMakeRange(49, 22)];
    model.curPriceG1 = [XTUtils xtPriceGroupInfoWithPriceGroupData:curPriceG1Data];
    //当前使用价格组2
    NSData *curPriceG2Data = [subdata subdataWithRange:NSMakeRange(71, 22)];
    model.curPriceG2 = [XTUtils xtPriceGroupInfoWithPriceGroupData:curPriceG2Data];
    //新价格组1
    NSData *newPriceG1Data = [subdata subdataWithRange:NSMakeRange(93, 22)];
    model.nwPriceG1 = [XTUtils xtPriceGroupInfoWithPriceGroupData:newPriceG1Data];
    //新价格组2
    NSData *newPriceG2Data = [subdata subdataWithRange:NSMakeRange(115, 22)];
    model.nwPriceG2 = [XTUtils xtPriceGroupInfoWithPriceGroupData:newPriceG2Data];
    //新单价生效日期
    NSData *newPriceStartTimeData = [subdata subdataWithRange:NSMakeRange(137, 4)];
    model.nwPriceStartTime = [XTUtils hexStringWithData:newPriceStartTimeData];
    //价格启用循环
    NSData *priceStartRepeatData = [subdata subdataWithRange:NSMakeRange(141, 24)];
    model.priceStartRepeat = [XTUtils fourStringArrayWithOriginString:[XTUtils hexStringWithData:priceStartRepeatData]];
    //新价格启用循环
    NSData *newPriceStartRepeatData = [subdata subdataWithRange:NSMakeRange(165, 24)];
    model.nwPriceStartRepeat = [XTUtils fourStringArrayWithOriginString:[XTUtils hexStringWithData:newPriceStartRepeatData]];
    //计费方式
    NSData *valuationWayData = [subdata subdataWithRange:NSMakeRange(189, 1)];
    model.valuationWay = [XTUtils hexStringWithData:valuationWayData];
    
    return model;
    
}

/**
 检查第二帧命令 parse

 @param data 第二帧
 @return XTYiTongCheckMeterSecond nil解析失败
 */
- (XTYiTongCheckMeterSecond *)parseCheckSecondByte:(NSData *)data {
    
    XTYiTongCheckMeterSecond *model = [[XTYiTongCheckMeterSecond alloc] init];
    
    NSData *subdata = [data subdataWithRange:NSMakeRange(4+10, 214)];
    //表当前时间
    NSData *timeData = [subdata subdataWithRange:NSMakeRange(0, 7)];
    model.timeStr = [XTUtils hexStringWithData:timeData];
    //表当前单价(元)
    NSData *basePriceData = [subdata subdataWithRange:NSMakeRange(7, 2)];
    long basePrice = [XTUtils longWithData:basePriceData];
    model.basePrice = basePrice;
    //剩余金额（元或m³）
    NSData *priceData = [subdata subdataWithRange:NSMakeRange(9, 4)];
    long price = [XTUtils longWithData:priceData];//[XTUtils longWithData:priceData];
    model.remainPrice = price;
    //累计购气金额（元或m³）
    NSData *buyPriceData = [subdata subdataWithRange:NSMakeRange(13, 4)];
    long buyPrice = [XTUtils longWithData:buyPriceData];
    model.totalPrice = buyPrice;
    //累计用气量（m³）
    NSData *useGasNumberData = [subdata subdataWithRange:NSMakeRange(17, 4)];
    long useGasNumber = [XTUtils longWithData:useGasNumberData];
    model.totalUseGas = useGasNumber;
    //无用气天数
    NSData *unUseDayData = [subdata subdataWithRange:NSMakeRange(21, 1)];
    long unUseDay = [XTUtils longWithData:unUseDayData];
    model.unUseDay = unUseDay;
    //无用气秒数
    NSData *unUseSecondData = [subdata subdataWithRange:NSMakeRange(22, 2)];
    long unUseSecond = [XTUtils longWithData:unUseSecondData];
    model.unUseSecond = unUseSecond;
    //表状态
    NSData *stateData = [subdata subdataWithRange:NSMakeRange(24, 2)];//189-190
    NSString *state = [XTUtils hexStringWithData:stateData];
    model.state = state;
    //消费交易状态字
    NSData *changeStateData = [subdata subdataWithRange:NSMakeRange(26, 1)];// //(37, 4) (41, 4) (45, 84) (129, 4) (133, 1)
    NSString *changeState = [XTUtils hexStringWithData:changeStateData];
    model.stateWord = changeState;
    //月累计消耗量
    NSData *historyData = [subdata subdataWithRange:NSMakeRange(27, 96)];
    model.historyArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < historyData.length; i += 4) {
        NSData *subHistoryData = [historyData subdataWithRange:NSMakeRange(i, 4)];
        long history = [XTUtils longWithData:subHistoryData];
        [model.historyArray addObject:[NSNumber numberWithDouble:(history)]];
    }
    //安检返写条数
    NSData *checkNumData = [subdata subdataWithRange:NSMakeRange(123, 1)];
    long checkNum = [XTUtils longWithData:checkNumData];
    model.securityCout = (int)checkNum;
    //安检返写记录
    NSData *checkRecordData = [subdata subdataWithRange:NSMakeRange(124, 6*3)];
    model.checkRecordArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; i ++) {
        NSData *subCheckRecord = [checkRecordData subdataWithRange:NSMakeRange(i*6, 6)];
        //前三个字节是安检编号
        NSString *subNumber = [XTUtils hexStringWithData:[subCheckRecord subdataWithRange:NSMakeRange(0, 3)]];
        //后三个字节是时间
        NSString *subYear = [NSString stringWithFormat:@"%ld",[XTUtils longWithData:[subCheckRecord subdataWithRange:NSMakeRange(3, 1)]]];
        NSString *subMonth = [NSString stringWithFormat:@"%ld",[XTUtils longWithData:[subCheckRecord subdataWithRange:NSMakeRange(4, 1)]]];
        NSString *subDay = [NSString stringWithFormat:@"%ld",[XTUtils longWithData:[subCheckRecord subdataWithRange:NSMakeRange(5, 1)]]];
        NSString *checkRecord = [NSString stringWithFormat:@"%@%@%@%@",subNumber,subYear,subMonth,subDay];
        [model.checkRecordArray addObject:checkRecord];
    }
    //最近一次关阀记录
    NSData *lastClose = [subdata subdataWithRange:NSMakeRange(142, 1)];
    model.recentColseRec = [NSString stringWithFormat:@"%ld",[XTUtils longWithData:lastClose]];
    //NFC购气次数
    NSData *nfcCountData = [subdata subdataWithRange:NSMakeRange(143, 1)];
    model.nfcCount = [XTUtils longWithData:nfcCountData];
    //NFC购气金额
    NSData *nfcBuyData = [subdata subdataWithRange:NSMakeRange(144, 4)];
    long nfcBuy = [XTUtils longWithData:nfcBuyData];
    model.nfcBuy = nfcBuy;
    //NFC累计购气金额
    NSData *nsfTotalBuyData = [subdata subdataWithRange:NSMakeRange(148, 4)];
    long nsfTotalBuy = [XTUtils longWithData:nsfTotalBuyData];
    model.nsfTotalBuy = nsfTotalBuy;
    //月累计消耗量日期
    NSData *historyMonthListData = [subdata subdataWithRange:NSMakeRange(152, 48)];
    model.historyMonthList = [XTUtils fourStringArrayWithOriginString:[XTUtils hexStringWithData:historyMonthListData]];
    //TCIS调价日
    NSData *adjustDateData = [subdata subdataWithRange:NSMakeRange(200, 3)];
    model.adjustDate = [XTUtils hexStringWithData:adjustDateData];
    //TCIS调价日表底数
    NSData *adjustBottomNumData = [subdata subdataWithRange:NSMakeRange(203, 4)];
    model.adjustBottomNum = [XTUtils longWithData:adjustBottomNumData];
    //刷表充值日
    NSData *payDateData = [subdata subdataWithRange:NSMakeRange(207, 3)];
    model.payDate = [XTUtils hexStringWithData:payDateData];
    //刷表充值日表底数
    NSData *payBottomNumData = [subdata subdataWithRange:NSMakeRange(210, 4)];
    model.payBottomNum = [XTUtils longWithData:payBottomNumData];
    
    return model;
    
}

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
- (NSData *)paramSettingWithUserNumber:(NSString *)userNumber paramData:(NSData *)paramData periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random {
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    //头 + 表类型 + 控制字 + 长度
    Byte bytes[] = {0x68,0x30,0x54,0xc9};
    [data appendData:[NSData dataWithBytes:bytes length:4]];
    
    //Data number
    [data appendData:[XTUtils dataWithHexString:userNumber]];
    
    //Data 易通表参数
    [data appendData:paramData];
    
    //Data 易通表参数 校验和算法
    [data appendData:[XTUtils checksumDataWithOriginData:paramData]];
    
    //Data 有效期
    if (periodTime.length == 0) {
        periodTime = @"000000";
    }
    [data appendData:[XTUtils dataWithHexString:[periodTime substringWithRange:NSMakeRange(0, 6)]]];
    
    //Data 密文口令
    NSString *randomStr = random;
    NSString *securityStr = desCmd;
    if (securityStr.length > 16) {
        securityStr = [securityStr substringWithRange:NSMakeRange(0, 16)];
    }
    [data appendData:[XTUtils dataWithHexString:securityStr]];
    
    //Data 随机数
    [data appendData:[XTUtils dataWithHexString:randomStr]];
    
    //校验和算法
    [data appendData:[XTUtils checksumDataWithOriginData:data]];
    
    //尾
    Byte endBytes[] = {0x16};
    [data appendData:[NSData dataWithBytes:endBytes length:1]];
    
    //NSLog(@"===data===%@",data);
    
    return data;
    
}

/**
 参数设置卡命令 parse

 @param data 蓝牙表返回的data
 @return result 55设置成功，其它设置失败，nil解析失败
 */
- (NSString *)parseParamSettingData:(NSData *)data {
    NSString *resultStr = [XTUtils hexStringWithData:[data subdataWithRange:NSMakeRange(14, 1)]];
    return resultStr;
}

#pragma -mark 清零卡命令
/**
 清零卡命令 send
 
 @param userNumber 用户号
 @param periodTime 有效期
 @param desCmd 加密字符串
 @param random 随机数
 @return data
 */
- (NSData *)clearZeroWithUserNumber:(NSString *)userNumber periodTime:(NSString *)periodTime desCmd:(NSString *)desCmd random:(NSString *)random {
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    //头 + 表类型 + 控制字 + 长度
    Byte bytes[] = {0x68,0x30,0x53,0x1d};
    [data appendData:[NSData dataWithBytes:bytes length:4]];
    
    //Data number
    [data appendData:[XTUtils dataWithHexString:userNumber]];
    
    //Data 有效期
    if (periodTime.length == 0) {
        periodTime = @"000000";
    }
    [data appendData:[XTUtils dataWithHexString:periodTime]];
    
    //Data 密文口令
    NSString *randomStr = random;
    NSString *securityStr = desCmd;
    if (securityStr.length > 16) {
        securityStr = [securityStr substringWithRange:NSMakeRange(0, 16)];
    }
    [data appendData:[XTUtils dataWithHexString:securityStr]];
    
    //Data 随机数
    [data appendData:[XTUtils dataWithHexString:randomStr]];
    
    //校验和算法
    [data appendData:[XTUtils checksumDataWithOriginData:data]];
    
    //尾
    Byte endBytes[] = {0x16};
    [data appendData:[NSData dataWithBytes:endBytes length:1]];
    
    //NSLog(@"===data===%@",data);
    
    return data;
    
}

/**
 清零卡命令 parse
 
 @param data 蓝牙表返回的data
 @return NSString 55表示充值成功，其它表示充值失败，nil表示解析失败
 */
- (NSString *)parseClearZeroData:(NSData *)data {
    NSString *resultStr = [XTUtils hexStringWithData:[data subdataWithRange:NSMakeRange(14, 1)]];
    return resultStr;
}


@end
