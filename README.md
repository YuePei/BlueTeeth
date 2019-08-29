# BlueTeeth的使用
### 属性
1、当前连接的蓝牙设备
```
@property (nonatomic, strong)CBPeripheral *currentPeripheral;
```
2、所有已发现的蓝牙设备
```
@property (nonatomic, strong)NSMutableArray *peripherals;
```
3、serviceUUID
```
@property (nonatomic, strong)NSString *serviceUUID;
```
4、characteristicUUID
```
@property (nonatomic, strong)NSString *characteristicUUID;
```

### 方法
1、初始化

（1）当查找到新的设备时，会调用FindNewPeripheralBlock里的代码

（2）如果有serviceUUID或者characteristicUUID，一定要在初始化的时候进行赋值
```
- (instancetype)initWithFindNewPeripheralBlock:(FindNewPeripheralBlock )findNewPeripheralBlock;
```
比如懒加载
```
#pragma mark lazy
- (BlueTeethTool *)blueTeethTool {
    if (!_blueTeethTool) {
        _blueTeethTool = [[BlueTeethTool alloc]initWithFindNewPeripheralBlock:^{
            [self.tableView reloadData];
        }];
        _blueTeethTool.characteristicUUID = @"FFE1";
    }
    return _blueTeethTool;
}
```

2、搜索蓝牙设备
```
- (void)searchBlueTeethDevices;
```

3、连接蓝夜设备
```
- (void)connectToPeripheral:(CBPeripheral *)peripheral succeed:(ConnectSucceedBlock)succeedBlock failed:(ConnectFailedBlock)failedBlock;
```

4、向设备写入数据
```
- (void)writeData:(NSData *)data forCurrentCharacteristicWithType:(CBCharacteristicWriteType )type;
```
