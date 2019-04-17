//
//  XTYiTongHistoryDay.h
//  SuntrontBlueTooth
//
//  Created by apple on 2017/8/11.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 历史回抄model */
@interface XTYiTongHistoryDay : NSObject

@property (nonatomic, strong) NSString *time;   //时间
@property (nonatomic, assign) long sum;         //用量

@end
