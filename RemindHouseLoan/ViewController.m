//
//  ViewController.m
//  RemindHouseLoan
//
//  Created by 周洋 on 2021/10/31.
//

#import "ViewController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface ViewController (){
    EKEventStore *_eventDB;
    EKCalendar *_ca;
}

@end

@implementation ViewController
- (void)calendarAuthority{
//获取授权状态
    EKAuthorizationStatus eventStatus = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
    //用户还没授权过
    if(eventStatus ==EKAuthorizationStatusNotDetermined){
        //提示用户授权，调出授权弹窗
        [[[EKEventStore alloc]init] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            if(granted){
                NSLog(@"允许");
            }else{
                NSLog(@"拒绝授权");
            }
        }];
    }
    //用户授权不允许
    else if (eventStatus == EKAuthorizationStatusDenied){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"当前日历服务不可用" message:@"您还没有授权本应用使用日历,请到 设置 > 隐私 > 日历 中授权" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        NSLog(@"已授权");
    }
}
- (void)addReminderNotify:(NSDate *)date title:(NSString *)title notes:(NSString *)notes {
//申请提醒权限
    if (!_ca){
        NSLog(@"没找到");
        return;
    }
    [_eventDB requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {

        if (granted) {
//创建一个提醒功能

            EKReminder *reminder = [EKReminder reminderWithEventStore:_eventDB];
//标题

            reminder.title = title;
//添加日历
            reminder.notes = notes;
            
            [reminder setCalendar:[_eventDB defaultCalendarForNewReminders]];

            NSCalendar *cal = [NSCalendar currentCalendar];

            [cal setTimeZone:[NSTimeZone systemTimeZone]];

            NSInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth |

            NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute |

            NSCalendarUnitSecond;

            NSDateComponents* dateComp = [cal components:flags fromDate:date];

            dateComp.timeZone = [NSTimeZone systemTimeZone];

            reminder.startDateComponents = dateComp; //开始时间

            reminder.dueDateComponents = dateComp; //到期时间

            reminder.priority = 1; //优先级
            
            reminder.calendar = _ca;

            EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:date]; //添加一个车闹钟

            [reminder addAlarm:alarm];

            NSError *err;

            [_eventDB saveReminder:reminder commit:YES error:&err];

            if (err) {

                NSLog(@"报错了");
            }else{
                NSLog(@"成功！");
            }

        }

    }];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self calendarAuthority];
//    [self createEventWithTitle:@"标题" notes:@"正文" noticeTime:1635739200];
    
    int y = 2015;
    int m = 10;
    int d = 15;
    
    int currentY = 2021;
    int currentM = 11;
    BOOL shouldPrint = NO;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    
    NSArray *calendars = [_eventDB
        calendarsForEntityType:EKEntityTypeReminder];
    EKCalendar *ca = nil;
    for (EKCalendar *calendar in calendars)
    {
        NSLog(@"Calendar = %@", calendar.title);
        if ([calendar.title isEqualToString:@"钱"]){
            _ca = calendar;
        }
    }
    
    
    for (int i = 0;i < 120;i++){
        int qi = i+1;
        int shengyu = 120 - qi;

        if (y == currentY && m == currentM){
            shouldPrint = YES;
        }
        
        if (shouldPrint){
            NSString *timeDesc = [NSString stringWithFormat:@"%04d-%02d-%02d 10:00:00",y,m,d];
            
            NSTimeInterval t = [[formatter dateFromString:timeDesc] timeIntervalSince1970];

            NSString *title = [NSString stringWithFormat:@"第%03d期房贷",qi];
            NSString *subtitle = [NSString stringWithFormat:@"剩余%d期",shengyu];
            NSLog(@"%@,%03d-%03d-%0.0f-%@-%@",timeDesc,qi,shengyu,t,title,subtitle);
            
            [self addReminderNotify:[NSDate dateWithTimeIntervalSince1970:t] title:title notes:subtitle];
            
            
            
            
        }
        
        if (m < 12){
            m += 1;
        }else{
            m = 1;
            y += 1;
        }
        
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _eventDB = [[EKEventStore alloc] init];
    // Do any additional setup after loading the view.
}


@end
