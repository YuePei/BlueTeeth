//
//  BlueTeethTool.h
//  TankLock
//
//  Created by Peyton on 2019/8/27.
//  Copyright © 2019 shzygk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


NS_ASSUME_NONNULL_BEGIN

typedef void (^FindNewPeripheralBlock) (void);
typedef void (^ConnectSucceedBlock) (CBPeripheral *currentPeripheral);
typedef void (^ConnectFailedBlock) (NSError *error);
typedef void (^WriteDataSucceedBlock) (void);
typedef void (^WriteDataFailedBlock) (NSError *error);

@interface BlueTeethTool : NSObject


//当前连接的蓝牙设备
@property (nonatomic, strong)CBPeripheral *currentPeripheral;
//所有已发现的蓝牙设备
@property (nonatomic, strong)NSMutableArray *peripherals;
//serviceUUID
@property (nonatomic, strong)NSString *serviceUUID;
//characteristicUUID
@property (nonatomic, strong)NSString *characteristicUUID;



#pragma mark Methods

- (instancetype)initWithFindNewPeripheralBlock:(FindNewPeripheralBlock )findNewPeripheralBlock;

//搜索蓝牙设备
- (void)searchBlueTeethDevices;

//连接蓝夜设备
- (void)connectToPeripheral:(CBPeripheral *)peripheral succeed:(ConnectSucceedBlock)succeedBlock failed:(ConnectFailedBlock)failedBlock;

//向设备写入数据
- (void)writeData:(NSData *)data forCurrentCharacteristicWithType:(CBCharacteristicWriteType )type succeed:(WriteDataSucceedBlock)succeedBlock failed:(WriteDataFailedBlock)failedBlock;;

@end

NS_ASSUME_NONNULL_END
