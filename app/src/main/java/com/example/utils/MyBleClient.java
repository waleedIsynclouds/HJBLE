package com.example.utils;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.example.hxjblinklibrary.blinkble.entity.EventResponse;
import com.example.hxjblinklibrary.blinkble.entity.reslut.KeyEventAddKey;
import com.example.hxjblinklibrary.blinkble.entity.reslut.KeyEventRegWifi;
import com.example.hxjblinklibrary.blinkble.parser.open.EventPostDataParser;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.profile.client.HxjBleClient;
import com.example.hxjblinklibrary.blinkble.profile.client.LinkCallBack;
import com.example.hxjblinklibrary.blinkble.profile.data.HXData;
import com.example.hxjblinklibrary.blinkble.utils.ByteUtil;

public class MyBleClient extends HxjBleClient {
    private static final String TAG = "MyBleClient";
    private static MyBleClient sInstance;

    public static MyBleClient getInstance(Context context) {
        if (sInstance == null) {
            synchronized (MyBleClient.class) {
                if (sInstance == null) {
                    sInstance = new MyBleClient(context);
                }
            }
        }
        return sInstance;
    }

    public MyBleClient(Context context) {
        super(context);
        setLinkCallBack(new LinkCallBack() {
            @Override
            public void onDeviceConnected(@NonNull BluetoothDevice device) {

            }

            @Override
            public void onDeviceDisconnected(@NonNull BluetoothDevice device) {

            }

            @Override
            public void onLinkLossOccurred(@NonNull BluetoothDevice device) {

            }

            @Override
            public void onDeviceReady(@NonNull BluetoothDevice device) {

            }

            @Override
            public void onDeviceNotSupported(@NonNull BluetoothDevice device) {

            }

            @Override
            public void onError(@NonNull BluetoothDevice device, @NonNull String message, int errorCode) {

            }

            @Override
            public void onEventReport(String substring, int cmdVersion, String lockMac) {

                EventResponse<String> stringEventResponse = EventPostDataParser.paraseCommon(substring);
                Log.d(TAG, "onEventReport: 日志上报 " + stringEventResponse);
                HXData data = new HXData(ByteUtil.hexStr2Byte(substring));
                Integer eventPower = data.getIntValue(HXData.FORMAT_UINT8, 8);
                switch (stringEventResponse.EventType()) {
                    case EventResponse.KeyEventConstants.LOCK_EVT_OPEN_LOCK:
                        //...
                        break;
                    case EventResponse.KeyEventConstants.LOCK_EVT_ADD_LOCK_KEY:
                        KeyEventAddKey result = EventPostDataParser.parseAddKey(substring);
                        // ...
                        break;
                    case 0x2D:
                        KeyEventRegWifi wifiReport = EventPostDataParser.parseWifiReg(substring);
                        if (wifiReport.getWifiStatues() == 0x04) {
                            Log.d(TAG, "WiFi模组连接路由器成功");
                        }else if (wifiReport.getWifiStatues() == 0x05) {
                            Log.d(TAG, "WiFi模组连接云端成功");
                        }else if (wifiReport.getWifiStatues() == 0x06) {
                            Log.d(TAG, "密码错误");
                        }else if (wifiReport.getWifiStatues() == 0x07) {
                            Log.d(TAG, "WiFi配置超时");
                        }
                        // 将配网结果通过EventBus等方式发送到配网相关页面
                        break;
                }

            }
        });
    }

    @Override
    public void disConnectBle(FunCallback funCallback) {
        super.disConnectBle(funCallback);
    }
}
