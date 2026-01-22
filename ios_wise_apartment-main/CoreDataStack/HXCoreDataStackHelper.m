//
//  HXCoreDataStackHelper.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2019/5/28.
//  Copyright © 2019 JQ. All rights reserved.
//

#import "HXCoreDataStackHelper.h"
#import "AppDelegate.h"

@implementation HXCoreDataStackHelper

+ (void)saveDevice:(HXBLEDevice *)deviceObj
{
    if (deviceObj) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lockMac = %@", deviceObj.lockMac];
        Device *dbDevice = [[self executeFetchRequestWithName:@"Device" predicate:predicate] firstObject];
        if (!dbDevice) {
            dbDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:self.managedObjectContext];
        }
        [self dbDevice:dbDevice fromBLEDevice:deviceObj];
        [self save];
    }
}

+ (void)saveDeviceStatus:(HXBLEDeviceStatus *)deviceStatusObj
{
    if (deviceStatusObj) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lockMac = %@", deviceStatusObj.lockMac];
        DeviceStatus *dbDeviceStatus = [[self executeFetchRequestWithName:@"DeviceStatus" predicate:predicate] firstObject];
        if (!dbDeviceStatus) {
            dbDeviceStatus = [NSEntityDescription insertNewObjectForEntityForName:@"DeviceStatus" inManagedObjectContext:self.managedObjectContext];
        }
        [self dbDeviceStatus:dbDeviceStatus fromBLEDeviceStatus:deviceStatusObj];
        [self save];
    }
}

+ (void)saveKey:(HXKeyModel *)keyObj
{
    if (keyObj) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lockMac = %@ and lockKeyId = %d", keyObj.lockMac, keyObj.lockKeyId];
        Key *dbKey = [[self executeFetchRequestWithName:@"Key" predicate:predicate] firstObject];
        if (!dbKey) {
            dbKey = [NSEntityDescription insertNewObjectForEntityForName:@"Key" inManagedObjectContext:self.managedObjectContext];
        }
        [self dbKey:dbKey fromBLEKey:keyObj];
        [self save];
    }
}

+ (void)deleteDeviceWithLockMac:(NSString *)lockMac
{
    if (lockMac) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lockMac = %@", lockMac];
        NSArray<Device *> *arr1 = [self executeFetchRequestWithName:@"Device" predicate:predicate];
        if (arr1.count > 0) {
            [self.managedObjectContext deleteObject:arr1.firstObject];
        }
        
        NSArray<DeviceStatus *> *arr2 = [self executeFetchRequestWithName:@"DeviceStatus" predicate:predicate];
        if (arr2.count > 0) {
            [self.managedObjectContext deleteObject:arr2.firstObject];
        }
        
        [self deleteKeyWithLockMac:lockMac];
        
        [self save];
    }
}

+ (void)deleteKeyWithLockMac:(NSString *)lockMac
{
    if (lockMac) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lockMac = %@", lockMac];
        NSArray<Key *> *arr = [self executeFetchRequestWithName:@"Key" predicate:predicate];
        if (arr.count > 0) {
            for (Key *key in arr) {
                [self.managedObjectContext deleteObject:key];
            }
            [self save];
        }
    }
}

+ (void)deleteKeyWithLockMac:(NSString *)lockMac lockKeyId:(int)lockKeyId
{
    if (lockMac) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lockMac = %@ and lockKeyId = %d", lockMac, lockKeyId];
        NSArray<Key *> *arr = [self executeFetchRequestWithName:@"Key" predicate:predicate];
        if (arr.count > 0) {
            [self.managedObjectContext deleteObject:[arr firstObject]];
            [self save];
        }
    }
}

+ (void)save
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate saveContext];
}

+ (NSArray<HXBLEDevice *> *)deviceList
{
    NSArray<Device *> *arr = [self executeFetchRequestWithName:@"Device" predicate:nil];
    NSMutableArray *deivceArr = arr.count>0?[[NSMutableArray alloc] initWithCapacity:arr.count]:nil;
    for (Device *device in arr) {
        HXBLEDevice *obj = [[HXBLEDevice alloc] init];
        [self bleDevice:obj fromBLEDevice:device];
        [deivceArr addObject:obj];
    }
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"lockCreateTime" ascending:NO];
    [deivceArr sortUsingDescriptors:@[descriptor]];
    return deivceArr;
}

+ (HXBLEDevice *)deviceWithLockMac:(NSString *)lockMac
{
    HXBLEDevice *bleDevice = nil;
    if (lockMac) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lockMac = %@", lockMac];
        Device *dbDevice = [[self executeFetchRequestWithName:@"Device" predicate:predicate] firstObject];
        if (dbDevice) {
            bleDevice = [[HXBLEDevice alloc] init];
            [self bleDevice:bleDevice fromBLEDevice:dbDevice];
        }
    }
    NSLog(@"\n%@\n",bleDevice);
    return bleDevice;
}

+ (HXBLEDeviceStatus *)deviceStatusWithLockMac:(NSString *)lockMac
{
    HXBLEDeviceStatus *bleDeviceStatus = nil;
    if (lockMac) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lockMac = %@", lockMac];
        DeviceStatus *dbDeviceStatus = [[self executeFetchRequestWithName:@"DeviceStatus" predicate:predicate] firstObject];;
        if (dbDeviceStatus) {
            bleDeviceStatus = [[HXBLEDeviceStatus alloc] init];
            [self bleDeviceStatus:bleDeviceStatus fromDBDeviceStatus:dbDeviceStatus];
        }
    }
    NSLog(@"\n%@\n",bleDeviceStatus);
    return bleDeviceStatus;
}

+ (NSArray<HXKeyModel *> *)keyListWithLockMac:(NSString *)lockMac
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lockMac = %@",lockMac];
    NSArray<Key *> *arr = [self executeFetchRequestWithName:@"Key" predicate:predicate];
    NSMutableArray *keyArr = arr.count>0?[[NSMutableArray alloc] initWithCapacity:arr.count]:nil;
    for (Key *dbKey in arr) {
        HXKeyModel *obj = [[HXKeyModel alloc] init];
        [self bleKey:obj fromDBKey:dbKey];
        [keyArr addObject:obj];
        NSLog(@"\n%@\n",obj);
    }
    return keyArr;
}

+ (NSArray *)executeFetchRequestWithName:(NSString *)name predicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:name];
    if (predicate) {
        fetchRequest.predicate = predicate;
    }
    NSArray *filteredArr = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return filteredArr;
}

+ (NSManagedObjectContext *)managedObjectContext
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    return context;
}

+ (void)dbDevice:(Device *)dbDevice fromBLEDevice:(HXBLEDevice *)bleDevice
{
    dbDevice.hardwareVersion = bleDevice.hardwareVersion;
    dbDevice.firmwareVersion = bleDevice.firmwareVersion;
    dbDevice.bleProtocolVersion = bleDevice.bleProtocolVersion;
    dbDevice.rfModuleType = bleDevice.rfModuleType;
    dbDevice.lockFunctionType = bleDevice.lockFunctionType;
    dbDevice.maxVolume = bleDevice.maxVolume;
    dbDevice.maxUser = bleDevice.maxUser;
    dbDevice.rfModuleMac = bleDevice.rfModuleMac;
    dbDevice.adminAuthCode = bleDevice.adminAuthCode;
    dbDevice.generalAuthCode = bleDevice.generalAuthCode;
    dbDevice.tempAuthCode = bleDevice.tempAuthCode;
    dbDevice.aesKey = bleDevice.aesKey;
    dbDevice.lockMac = bleDevice.lockMac;
    dbDevice.lockType = bleDevice.lockType;
    dbDevice.initFlag = bleDevice.initFlag;
    dbDevice.rfModuleFunction = bleDevice.rfModuleFunction;
    dbDevice.bleActiveTimes = bleDevice.bleActiveTimes;
    dbDevice.rfMoudleSoftwareVer = bleDevice.rfMoudleSoftwareVer;
    dbDevice.rfMoudleHarewareVer = bleDevice.rfMoudleHarewareVer;
    dbDevice.passwordNumRange = bleDevice.passwordNumRange;
    dbDevice.offlinePasswordVer = bleDevice.offlinePasswordVer;
    dbDevice.menuFeature = bleDevice.menuFeature;
    dbDevice.supportedSystemLanguage = bleDevice.supportedSystemLanguage;
    dbDevice.lockSystemFunction = bleDevice.lockSystemFunction;
    dbDevice.lockNetSystemFunction = bleDevice.lockNetSystemFunction;
    dbDevice.lockCreateTime = bleDevice.lockCreateTime;
}

+ (void)bleDevice:(HXBLEDevice *)bleDevice fromBLEDevice:(Device *)dbDevice
{
    bleDevice.hardwareVersion = dbDevice.hardwareVersion;
    bleDevice.firmwareVersion = dbDevice.firmwareVersion;
    bleDevice.bleProtocolVersion = dbDevice.bleProtocolVersion;
    bleDevice.rfModuleType = dbDevice.rfModuleType;
    bleDevice.lockFunctionType = dbDevice.lockFunctionType;
    bleDevice.maxVolume = dbDevice.maxVolume;
    bleDevice.maxUser = dbDevice.maxUser;
    bleDevice.rfModuleMac = dbDevice.rfModuleMac;
    bleDevice.adminAuthCode = dbDevice.adminAuthCode;
    bleDevice.generalAuthCode = dbDevice.generalAuthCode;
    bleDevice.tempAuthCode = dbDevice.tempAuthCode;
    bleDevice.aesKey = dbDevice.aesKey;
    bleDevice.lockMac = dbDevice.lockMac;
    bleDevice.lockType = dbDevice.lockType;
    bleDevice.initFlag = dbDevice.initFlag;
    bleDevice.rfModuleFunction = dbDevice.rfModuleFunction;
    bleDevice.bleActiveTimes = dbDevice.bleActiveTimes;
    bleDevice.rfMoudleSoftwareVer = dbDevice.rfMoudleSoftwareVer;
    bleDevice.rfMoudleHarewareVer = dbDevice.rfMoudleHarewareVer;
    bleDevice.passwordNumRange = dbDevice.passwordNumRange;
    bleDevice.offlinePasswordVer = dbDevice.offlinePasswordVer;
    bleDevice.menuFeature = dbDevice.menuFeature;
    bleDevice.supportedSystemLanguage = dbDevice.supportedSystemLanguage;
    bleDevice.lockSystemFunction = dbDevice.lockSystemFunction;
    bleDevice.lockNetSystemFunction = dbDevice.lockNetSystemFunction;
    bleDevice.lockCreateTime = dbDevice.lockCreateTime;
}

+ (void)dbDeviceStatus:(DeviceStatus *)dbDeviceStatus fromBLEDeviceStatus:(HXBLEDeviceStatus *)deviceStatusObj
{
    dbDeviceStatus.lockMac = deviceStatusObj.lockMac;
    dbDeviceStatus.openMode = deviceStatusObj.openMode;
    dbDeviceStatus.normallyOpenMode = deviceStatusObj.normallyOpenMode;
    dbDeviceStatus.normallyopenFlag = deviceStatusObj.normallyopenFlag;
    dbDeviceStatus.volumeEnable = deviceStatusObj.volumeEnable;
    dbDeviceStatus.shackleAlarmEnable = deviceStatusObj.shackleAlarmEnable;
    dbDeviceStatus.tamperSwitchStatus = deviceStatusObj.tamperSwitchStatus;
    dbDeviceStatus.lockCylinderAlarmEnable = deviceStatusObj.lockCylinderAlarmEnable;
    dbDeviceStatus.cylinderSwitchStatus = deviceStatusObj.cylinderSwitchStatus;
    dbDeviceStatus.antiLockEnable = deviceStatusObj.antiLockEnable;
    dbDeviceStatus.antiLockStatues = deviceStatusObj.antiLockStatues;
    dbDeviceStatus.lockCoverAlarmEnable = deviceStatusObj.lockCoverAlarmEnable;
    dbDeviceStatus.lockCoverSwitchStatus = deviceStatusObj.lockCoverSwitchStatus;
    dbDeviceStatus.systemTimeTimestamp = deviceStatusObj.systemTimeTimestamp;
    dbDeviceStatus.timezoneOffset = deviceStatusObj.timezoneOffset;
    dbDeviceStatus.systemVolume = deviceStatusObj.systemVolume;
    dbDeviceStatus.lowPowerUnlockTimes = deviceStatusObj.lowPowerUnlockTimes;
    dbDeviceStatus.enableKeyType = deviceStatusObj.enableKeyType;
    dbDeviceStatus.squareTongueStatues = deviceStatusObj.squareTongueStatues;
    dbDeviceStatus.obliqueTongueStatues = deviceStatusObj.obliqueTongueStatues;
    dbDeviceStatus.systemLanguage = deviceStatusObj.systemLanguage;
}

+ (void)bleDeviceStatus:(HXBLEDeviceStatus *)deviceStatusObj fromDBDeviceStatus:(DeviceStatus *)dbDeviceStatus
{
    deviceStatusObj.lockMac = dbDeviceStatus.lockMac;
    deviceStatusObj.openMode = dbDeviceStatus.openMode;
    deviceStatusObj.normallyOpenMode = dbDeviceStatus.normallyOpenMode;
    deviceStatusObj.normallyopenFlag = dbDeviceStatus.normallyopenFlag ;
    deviceStatusObj.volumeEnable = dbDeviceStatus.volumeEnable;
    deviceStatusObj.shackleAlarmEnable = dbDeviceStatus.shackleAlarmEnable;
    deviceStatusObj.tamperSwitchStatus = dbDeviceStatus.tamperSwitchStatus;
    deviceStatusObj.lockCylinderAlarmEnable = dbDeviceStatus.lockCylinderAlarmEnable;
    deviceStatusObj.cylinderSwitchStatus = dbDeviceStatus.cylinderSwitchStatus;
    deviceStatusObj.antiLockEnable = dbDeviceStatus.antiLockEnable;
    deviceStatusObj.antiLockStatues = dbDeviceStatus.antiLockStatues;
    deviceStatusObj.lockCoverAlarmEnable = dbDeviceStatus.lockCoverAlarmEnable;
    deviceStatusObj.lockCoverSwitchStatus = dbDeviceStatus.lockCoverSwitchStatus;
    deviceStatusObj.systemTimeTimestamp = dbDeviceStatus.systemTimeTimestamp;
    deviceStatusObj.timezoneOffset = dbDeviceStatus.timezoneOffset;
    deviceStatusObj.systemVolume = dbDeviceStatus.systemVolume;
    deviceStatusObj.lowPowerUnlockTimes = dbDeviceStatus.lowPowerUnlockTimes;
    deviceStatusObj.enableKeyType = dbDeviceStatus.enableKeyType;
    deviceStatusObj.squareTongueStatues = dbDeviceStatus.squareTongueStatues;
    deviceStatusObj.obliqueTongueStatues = dbDeviceStatus.obliqueTongueStatues;
    deviceStatusObj.systemLanguage = dbDeviceStatus.systemLanguage;
}

+ (void)dbKey:(Key *)dbKey fromBLEKey:(HXKeyModel *)bleKey
{
    dbKey.lockMac = bleKey.lockMac;
    dbKey.keyGroupId = bleKey.keyGroupId;
    dbKey.lockKeyId = bleKey.lockKeyId;
    dbKey.keyType = bleKey.keyType;
    dbKey.updateTime = bleKey.updateTime;
    dbKey.validStartTime = bleKey.validStartTime;
    dbKey.validEndTime = bleKey.validEndTime;
    dbKey.validNumber = bleKey.validNumber;
    dbKey.authMode = bleKey.authMode;
    dbKey.weeks = bleKey.weeks;
    dbKey.dayStartTimes = bleKey.dayStartTimes;
    dbKey.dayEndTimes = bleKey.dayEndTimes;
    dbKey.deleteFalg = bleKey.deleteFalg;
    dbKey.key = bleKey.key;
}

+ (void)bleKey:(HXKeyModel *)bleKey fromDBKey:(Key *)dbKey
{
    bleKey.lockMac = dbKey.lockMac;
    bleKey.keyGroupId = dbKey.keyGroupId;
    bleKey.lockKeyId = dbKey.lockKeyId;
    bleKey.keyType = dbKey.keyType;
    bleKey.updateTime = dbKey.updateTime;
    bleKey.validStartTime = dbKey.validStartTime;
    bleKey.validEndTime = dbKey.validEndTime;
    bleKey.validNumber = dbKey.validNumber;
    bleKey.authMode = dbKey.authMode;
    bleKey.weeks = dbKey.weeks;
    bleKey.dayStartTimes = dbKey.dayStartTimes;
    bleKey.dayEndTimes = dbKey.dayEndTimes;
    bleKey.deleteFalg = dbKey.deleteFalg;
    bleKey.key = dbKey.key;
}

@end


