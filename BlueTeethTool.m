//
//  BlueTeethTool.m
//  TankLock
//
//  Created by Peyton on 2019/8/27.
//  Copyright © 2019 shzygk. All rights reserved.
//

#import "BlueTeethTool.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface BlueTeethTool()<CBCentralManagerDelegate, CBPeripheralDelegate>

//manager
@property (nonatomic, strong)CBCentralManager *centralManager;
//hud
@property (nonatomic, strong)MBProgressHUD *hud;
//currentService
@property (nonatomic, strong)CBService *currentService;
//currentCharaciteristic
@property (nonatomic, strong)CBCharacteristic *currentCharacteristic;

@end

@implementation BlueTeethTool

- (instancetype)initWithFindNewPeripheralBlock:(FindNewPeripheralBlock)findNewPeripheralBlock {
    if (self = [super init]) {
        self.findNewPeripheralBlock = findNewPeripheralBlock;
    }
    return self;
}

- (void)searchBlueTeethDevices {
    if (self.peripherals.count > 0) {
        [self.peripherals removeAllObjects];
    }
    [self centralManager];
}

- (void)connectToPeripheral:(CBPeripheral *)peripheral {
    [self.centralManager connectPeripheral:peripheral options:nil];
    
    _hud = [MBProgressHUD new];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *keyWindow = appDelegate.window;
    _hud.label.text = @"连接中...";
    [keyWindow addSubview:_hud];
    [_hud showAnimated:YES];
}

//写入数据
- (void)writeData:(NSData *)data forCurrentCharacteristicWithType:(CBCharacteristicWriteType)type {
    
    [self.currentPeripheral writeValue:data forCharacteristic:self.currentCharacteristic type:type];
}


#pragma mark CBCentralManagerDelegate
//蓝牙状态改变
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            // 开始扫描周围的外设。
            /*
             -- 两个参数为Nil表示默认扫描所有可见蓝牙设备。
             -- 注意：第一个参数是用来扫描有指定服务的外设。然后有些外设的服务是相同的，比如都有FFF5服务，那么都会发现；而有些外设的服务是不可见的，就会扫描不到设备。
             -- 成功扫描到外设后调用didDiscoverPeripheral
             */
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        }
            break;
        default:
            break;
    }
}

//找到外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if (![self existPeripheral:peripheral]) {
        NSLog(@"发现设备：%@", peripheral.name);
        [self.peripherals addObject:peripheral];
        //告知控制器，查找到新的外设，控制器应当执行刷新列表等操作
        self.findNewPeripheralBlock();
    }else {
        //已经查找到的设备
    }
}

//连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    self.hud.mode = MBProgressHUDModeText;
    self.hud.label.text = [NSString stringWithFormat:@"已连接到：%@", peripheral.name];
    [self.hud hideAnimated:YES afterDelay:2];
    
    //设置peripheral，并且开始查找services
    self.currentPeripheral = peripheral;
    self.currentPeripheral.delegate = self;
    [self.currentPeripheral discoverServices:nil];
}

//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    self.hud.mode = MBProgressHUDModeText;
    self.hud.label.text = @"连接失败！";
    [self.hud hideAnimated:YES afterDelay:2.0f];
}

//与外设断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    self.hud.label.text = @"蓝牙已断开连接";
    [self.hud showAnimated:YES];
    [self.hud hideAnimated:YES afterDelay:2.0f];
}

#pragma mark CBPeripheralDelegate
//查找到services
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    //开始查找characteristics
    if (error) {
        return;
    }
    for (CBService *service in peripheral.services) {
        //TODO...是否有service的UUID
        if (self.serviceUUID) {
            if ([service.UUID.UUIDString isEqualToString:self.serviceUUID]) {
                self.currentService = service;
                //查找特征
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }else {
            self.currentService = service;
            //查找特征
            [peripheral discoverCharacteristics:nil forService:service];
        }
        
    }
}

//发现特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        if (self.characteristicUUID) {
            if ([characteristic.UUID.UUIDString isEqualToString:self.characteristicUUID]) {
                //如果设置了characteristicUUID
                self.currentCharacteristic = characteristic;
                //订阅，实时接收
                [self.currentPeripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }else {
            //如果没设置characteristicUUID
            self.currentCharacteristic = characteristic;
            //订阅，实时接收
            [self.currentPeripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        
    }
}

//已经成功写入数据
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"write data failed!");
    }else {
        NSLog(@"write data succeed!");
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"订阅失败");
        return;
    }else {
        if (characteristic.isNotifying) {
            NSLog(@"订阅成功");
        }else {
            NSLog(@"订阅取消");
        }
    }
}

#pragma mark toolMethods
/**
 *  检测peripherals中是否已经存在该设备
 *  @param peripheral 查找到的设备
 *  @return YES 表示已存在该设备
*/
- (BOOL)existPeripheral:(CBPeripheral *)peripheral {
    BOOL existed = NO;
    if (peripheral && peripheral.name ) {
        for (CBPeripheral *p in self.peripherals) {
            if (peripheral == p) {
                existed = YES;
            }
        }
    }else {
        existed = YES;
    }
    return existed;
}

#pragma mark lazy
- (CBCentralManager *)centralManager {
    if (!_centralManager) {
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
    return _centralManager;
}

- (NSMutableArray *)peripherals {
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}
@end
