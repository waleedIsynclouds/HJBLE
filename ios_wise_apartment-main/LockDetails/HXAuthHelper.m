//
//  HXAuthHelper.m
//  HXJBLESDKDemo
//
//  Created by JQ on 2021/7/26.
//  Copyright © 2021 JQ. All rights reserved.
//

#import "HXAuthHelper.h"
#import "HXCoreDataStackHelper.h"

@implementation HXAuthHelper

#pragma mark -HXBLESecureAuthProtocol


/// SessionId命令编码（App实现该方法向服务器获取sessionIdCmd，将结果返回给SDK）
/// @param keyGroupId 用户Id，作为向服务器请求sessionIdCmd的参数
/// @param snr 包序号，作为向服务器请求sessionIdCmd的参数
/// @param lockMac 门锁Mac
/// @param block 返回请求到的命令给SDK，如果失败返回nil
- (void)getSessionIdCmdWithKeyGroupId:(int)keyGroupId
                                  snr:(int)snr
                              lockMac:(NSString *)lockMac
                     complectionBlock:(void(^)(NSString * _Nullable sessionIdCmd))block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        HXBLEDevice *bleDevice = [HXCoreDataStackHelper deviceWithLockMac:lockMac];
        if (bleDevice) {
            NSString *urlString = [NSString stringWithFormat:@"http://xpit3i.natappfree.cc/sessionEncode?keyGroupId=%d&snr=%d&aesKey=%@",keyGroupId,snr,bleDevice.aesKey];
            [self startRequestWithUrlString:urlString complectionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                NSString *sessionIdCmd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (sessionIdCmd) {
                    if (block) {
                        block(sessionIdCmd);
                    }
                }else {
                    if (block) {
                        block(nil);
                    }
                }
            }];
        }else {
            if (block) {
                block(nil);
            }
        }
    });
}

/// SessionId命令解码（App实现该方法向服务器请求解析sessionIdPlayload，将解析到的sessionId返回给SDK）
/// @param lockMac 门锁Mac
/// @param sessionIdPlayload 待解码的数据
/// @param block 返回请求到的sessionId给SDK，如果失败返回nil
- (void)parseSessionIdWithLockMac:(NSString *)lockMac
                sessionIdPlayload:(NSString *)sessionIdPlayload
                 complectionBlock:(void(^)(NSString * _Nullable sessionId))block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        HXBLEDevice *bleDevice = [HXCoreDataStackHelper deviceWithLockMac:lockMac];
        if (bleDevice) {
            NSString *urlString = [NSString stringWithFormat:@"http://xpit3i.natappfree.cc/sessionDecode?payload=%@&aesKey=%@",sessionIdPlayload,bleDevice.aesKey];
            [self startRequestWithUrlString:urlString complectionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                NSString *sessionId = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (sessionId) {
                    if (block) {
                        block(sessionId);
                    }
                }else {
                    if (block) {
                        block(nil);
                    }
                }
            }];
        }else {
            if (block) {
                block(nil);
            }
        }
    });
}

/// AES128密钥命令编码（App实现该方法向服务器获取aesKeyCmd，将结果返回给SDK）
/// @param keyGroupId 用户Id，作为向服务器请求aesKeyCmd的参数
/// @param snr 包序号，作为向服务器请求aesKeyCmd的参数
/// @param sessionId 会话ID，作为向服务器请求aesKeyCmd的参数
/// @param lockMac 门锁Mac
/// @param block 返回请求到的命令给SDK，如果失败返回nil
- (void)getAESKeyCmdWithKeyGroupId:(int)keyGroupId
                               snr:(int)snr
                         sessionId:(NSString *)sessionId
                           lockMac:(NSString *)lockMac
                  complectionBlock:(void(^)(NSString * _Nullable aesKeyCmd))block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        HXBLEDevice *bleDevice = [HXCoreDataStackHelper deviceWithLockMac:lockMac];
        if (bleDevice) {
            NSString *urlString = [NSString stringWithFormat:@"http://xpit3i.natappfree.cc/secretKeyEncode?keyGroupId=%d&snr=%d&aesKey=%@&sessionId=%@",keyGroupId,snr,bleDevice.aesKey,sessionId];
            [self startRequestWithUrlString:urlString complectionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                NSString *aesKeyCmd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (aesKeyCmd) {
                    if (block) {
                        block(aesKeyCmd);
                    }
                }else {
                    if (block) {
                        block(nil);
                    }
                }
            }];
        }else {
            if (block) {
                block(nil);
            }
        }
    });
}

/// AES128密钥命令解码（App实现该方法向服务器请求解析aesKeyPlayload，将解析到的aesKey返回给SDK）
/// @param lockMac 门锁Mac
/// @param aesKeyPlayload 待解码的数据
/// @param block 返回请求到的sessionId给SDK，如果失败返回nil
- (void)parseAESKeyWithLockMac:(NSString *)lockMac
                aesKeyPlayload:(NSString *)aesKeyPlayload
              complectionBlock:(void(^)(NSString * _Nullable aesKey))block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        HXBLEDevice *bleDevice = [HXCoreDataStackHelper deviceWithLockMac:lockMac];
        if (bleDevice) {
            NSString *urlString = [NSString stringWithFormat:@"http://xpit3i.natappfree.cc/secretKeyDecode?payload=%@&aesKey=%@",aesKeyPlayload,bleDevice.aesKey];
            [self startRequestWithUrlString:urlString complectionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                NSString *aes128Key = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (aes128Key) {
                    if (block) {
                        block(aes128Key);
                    }
                }else {
                    if (block) {
                        block(nil);
                    }
                }
            }];
        }else {
            if (block) {
                block(nil);
            }
        }
    });
}

/// 鉴权命令编码（App实现该方法向服务器获取authCmd，将结果返回给SDK）
/// @param keyGroupId 用户Id，作为向服务器请求authCmd的参数
/// @param snr 包序号，作为向服务器请求authCmd的参数
/// @param sessionId 会话ID，作为向服务器请求authCmd的参数
/// @param aesKey aes密钥，作为向服务器请求authCmd的参数
/// @param lockMac 门锁Mac
/// @param block 返回请求到的命令给SDK，如果失败返回nil
- (void)getAuthCmdWithKeyGroupId:(int)keyGroupId
                             snr:(int)snr
                       sessionId:(NSString *)sessionId
                          aesKey:(NSString *)aesKey
                         lockMac:(NSString *)lockMac
                complectionBlock:(void(^)(NSString * _Nullable authCmd))block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        HXBLEDevice *bleDevice = [HXCoreDataStackHelper deviceWithLockMac:lockMac];
        if (bleDevice) {
            NSString *urlString = [NSString stringWithFormat:@"http://xpit3i.natappfree.cc/authenticationEncode?keyGroupId=%d&snr=%d&aes128Key=%@&sessionId=%@&authCode=%@",keyGroupId,snr,aesKey,sessionId,bleDevice.adminAuthCode];
            [self startRequestWithUrlString:urlString complectionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                NSString *authCmd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (authCmd) {
                    if (block) {
                        block(authCmd);
                    }
                }else {
                    if (block) {
                        block(nil);
                    }
                }
            }];
        }else {
            if (block) {
                block(nil);
            }
        }
    });
}

- (void)startRequestWithUrlString:(NSString *)urlString
                 complectionBlock:(void(^)(NSData * _Nullable data, NSError * _Nullable error))block
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"GET";
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (block) {
            block(data, error);
        }
    }];
    [dataTask resume];
}


@end
