package com.example.hxjblesdk.ui.addLock;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.example.hxjblesdk.R;
import com.example.hxjblesdk.db.lock.Lock;
import com.example.hxjblesdk.viewmodel.LockViewModel;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.DnaInfo;
import com.example.hxjblinklibrary.blinkble.entity.reslut.SysParamResult;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.profile.data.common.StatusCode;
import com.example.hxjblinklibrary.blinkble.profile.other.ATConfigHelper;
import com.example.hxjblinklibrary.blinkble.profile.other.Cat1ATConfigHelper;
import com.example.hxjblinklibrary.blinkble.scanner.HxjBluetoothDevice;
import com.example.hxjblinklibrary.blinkble.scanner.HxjScanCallback;
import com.example.hxjblinklibrary.blinkble.scanner.HxjScanner;
import com.example.utils.MyBleClient;

import java.util.List;
import java.util.logging.Logger;

import static android.app.Activity.RESULT_CANCELED;

public class AddSecondFragment extends Fragment {

    private static final String EXTRA_REPLY = "com.example.hxjblesdk.ui.EXTRA_REPLY";
    private MyBleClient hxjBleClient;
    private TextView secondTextView;

    private Button button;

    private BlinkyAuthAction baseAuthAction;

    private DnaInfo dnaInfoObj;
    private SysParamResult deviceStatusObj;

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_second_add, container, false);
    }

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        hxjBleClient = MyBleClient.getInstance(getContext().getApplicationContext());
        secondTextView = view.findViewById(R.id.textview_second);
        button = view.findViewById(R.id.button_second);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startScan();
            }
        });
    }

    private void startScan() {
        secondTextView.append("\nStart scan...");
        HxjScanner.getInstance().startScan(15000, getActivity().getApplicationContext(), new HxjScanCallback() {
            @Override
            public void onHxjScanResults(@NonNull List<HxjBluetoothDevice> results) {
                super.onHxjScanResults(results);
                if (results.size() > 0) {
                    HxjBluetoothDevice maxRSSIDevice = null;
                    for (final HxjBluetoothDevice result : results) {
                        if (!result.isPaired() && result.isDiscoverable() && result.getRssi() > -80) {
                            if (maxRSSIDevice == null) {
                                maxRSSIDevice = result;
                            }else if (maxRSSIDevice.getRssi() < result.getRssi()) {
                                maxRSSIDevice = result;
                            }
                        }
                    }
                    if (maxRSSIDevice != null) {
                        stopScan();
                        addDevice(maxRSSIDevice);
                        button.setVisibility(View.GONE);
                    }
                }
            }

            @Override
            public void onScanFailed(int errorCode) {
                super.onScanFailed(errorCode);
                secondTextView.append("\nScanFailed, errorCode: " + errorCode);
            }
        });
    }


    private void stopScan() {
        HxjScanner.getInstance().stopScan();
    }

    /**
     * addDevice，get DNA
     */
    public void addDevice(HxjBluetoothDevice hxjBluetoothDevice) {
        secondTextView.append("\nAdding device..." + hxjBluetoothDevice.getAddress() + " rssi = " + hxjBluetoothDevice.getRssi());
        //authAction 的生成有2种方法，使用任意一种都可以添加设备：
        //方法1：
//      BlinkyAuthAction authAction = new BlinkyAuthAction.Builder().hxjBluetoothDevice(hxjBluetoothDevice).build();

        //方法2:
        BlinkyAuthAction authAction = new BlinkyAuthAction.Builder()
                .mac(hxjBluetoothDevice.getMac())
                .build();
        hxjBleClient.addDevice(authAction, hxjBluetoothDevice.getChipType(), new FunCallback<DnaInfo>() {
            @Override
            public void onResponse(Response<DnaInfo> response) {
                if (response.code() == StatusCode.ACK_STATUS_SUCCESS) {
                    Log.d(TAG, "deviceDnaInfoStr: " + response.body().getDeviceDnaInfoStr());
                    dnaInfoObj = response.body();
                    saveAuthInfo(response.body());
                    getDeviceStatus();
                } else {
                    //retrunFail(response.code());
                    secondTextView.append("\n" + StatusCode.parse(response.code(), getContext()));
                    button.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void onFailure(Throwable t) {
                secondTextView.append("\nFailed," + t.getMessage());
                button.setVisibility(View.VISIBLE);
            }
        });
    }

    private void saveAuthInfo(DnaInfo dnaInfo) {

        baseAuthAction = new BlinkyAuthAction.Builder()
                .bleProtocolVer(dnaInfo.getProtocolVer())
                .authCode(dnaInfo.getAuthorizedRoot())
                .dnaKey(dnaInfo.getDnaAes128Key())
                .mac(dnaInfo.getMac())
                .keyGroupId(900)
                .build();
    }

    public void getDeviceStatus() {
        BlinkyAction hxBleAction = new BlinkyAction();
        hxBleAction.setBaseAuthAction(baseAuthAction);
        hxjBleClient.getSysParam(hxBleAction, new FunCallback<SysParamResult>() {
            @Override
            public void onResponse(Response<SysParamResult> response) {
                if (response.code() == StatusCode.ACK_STATUS_SUCCESS) {
                    Log.d(TAG, "deviceStatusStr: " + response.body().getDeviceStatusStr());
                    deviceStatusObj = response.body();
                    pairSuccessInd();//返回配对结果
                } else {
                    //retrunFail(response.code());
                    secondTextView.append("\n" + StatusCode.parse(response.code(), getContext()));
                    button.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void onFailure(Throwable t) {
                secondTextView.append("\nFailed," + t.getMessage());
                button.setVisibility(View.VISIBLE);
            }
        });
    }

    /**
     * Return to lock pairing result
     *
     */
    private void pairSuccessInd() {
        secondTextView.append("\nAddToServer...");
        AddToServer();

        Log.d(TAG, "pairSuccessInd() called with: authCode = [" + dnaInfoObj.getAuthorizedRoot() + "], dnaKey = [" + dnaInfoObj.getDnaAes128Key() + "]");
        secondTextView.append("\nPair success ind...");

        BlinkyAction hxBleAction = new BlinkyAction();

        hxBleAction.setBaseAuthAction(baseAuthAction);
        hxjBleClient.pairSuccessInd(hxBleAction, true, new FunCallback() {

            @Override
            public void onResponse(Response response) {
                //If the Bluetooth is not disconnected and the system detects that it is connected, the settings cannot be searched
                //You can also cache hxjBluetoothDevice to operate
                hxjBleClient.disConnectBle(null);

                if (response.isSuccessful()) {//添加成功
                    hxjBleClient.rfModulePairing(
                            hxBleAction,
                            "",
                            new FunCallback() {
                                @Override
                                public void onResponse(Response response) {
                                    Log.d(TAG, "rfModulePairing() called with: response = [" + response.toString() + "]");
                                }

                                @Override
                                public void onFailure(Throwable throwable) {
                                    Log.d(TAG, "rfModulePairing() called with: throwable = [" + throwable.toString() + "]");
                                }
                            }
                    );
                    secondTextView.append("\npair success...");
                  new Handler().postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            //如果包含NB-IoT模组，则获取模组信息
                            if (dnaInfoObj.getrFMoudleType() == 0x05) {
                                getNBIoTModuleInfo();
                            } else {
                                //页面跳转
                                if (getActivity() != null) {
                                    Intent replyIntent = new Intent();
                                    Lock.LockBuilder lockBuilder = Lock.LockBuilder.aLock();
                                    replyIntent.putExtra(EXTRA_REPLY, lockBuilder.build());
                                    getActivity().finish();
                                }
                            }
                        }
                    }, 3000);
                } else {
                    //添加失败
                    exitIn5s(response);
                }
            }

            @Override
            public void onFailure(Throwable t) {
                t.getMessage();
            }
        });
    }

    private void exitIn5s(Response response) {
        secondTextView.append("\nFailed, " + StatusCode.parse(response.code(), getContext()));
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent replyIntent = new Intent();
                if (getActivity() != null) {
                    getActivity().setResult(RESULT_CANCELED, replyIntent);
                    getActivity().finish();
                }
            }
        }, 5000);
    }

    private void getNBIoTModuleInfo() {
        secondTextView.append("\n Get NB-IoT Info...");
        ATConfigHelper helper = new ATConfigHelper(getContext(), hxjBleClient);
        helper.startSetting(baseAuthAction, new ATConfigHelper.ATCallBack() {
            @Override
            public void onAtGetSuccess(int rssi, String imsi, String imei) {
                secondTextView.append("\nResponse NB-IoT Info\nrssi: " + rssi +
                        "\nrssi: " + imsi +
                        "\nimei: " + imei +
                        "\nsuccess"
                );
            }

            @Override
            public void onError(String str) {
                secondTextView.append("\nError：" + str);
            }
        });
    }

    private void getCat1ModuleInfo() {
        secondTextView.append("\n Get Cat.1 Info...");
        Cat1ATConfigHelper helper = new Cat1ATConfigHelper(getContext(), hxjBleClient);
        helper.start(baseAuthAction, new Cat1ATConfigHelper.Cat1ATCallBack() {
            @Override
            public void onAtGetSuccess(String iccid, String imei, String imsi, String rssi, String rsrp, String sinr) {
                secondTextView.append("\nResponse Cat.1 Info\niccid: " + iccid +
                        "\nimei: " + imei +
                        "\nimsi: " + imsi +
                        "\nrssi: " + rssi +
                        "\nrsrp: " + rsrp +
                        "\nsinr: " + sinr +
                        "\nsuccess"
                );
            }

            @Override
            public void onError(String str) {
                secondTextView.append("\nError：" + str);
            }
        });
    }


    private void AddToServer() {

        // 将这2个值发送给服务器
        String deviceDnaInfoStr = dnaInfoObj.getDeviceDnaInfoStr();
        String deviceStatusStr =  deviceStatusObj.getDeviceStatusStr();

        Lock.LockBuilder lockBuilder = Lock.LockBuilder.aLock();
        lockBuilder.lockMac(dnaInfoObj.getMac())
                .protocolVer(dnaInfoObj.getProtocolVer())
                .deviceType(dnaInfoObj.getDeviceType())
                .lockName("")
                .hardWareVer(dnaInfoObj.getHardWareVer())
                .softWareVer(dnaInfoObj.getSoftWareVer())
                .lockFunctionType(dnaInfoObj.getLockFunctionType())
                .menuFeature(dnaInfoObj.getMenuFeature())
                .projectID(dnaInfoObj.getProjectID())
                .rFModuleMac(dnaInfoObj.getRFModuleMac())
                .rFModuleType(dnaInfoObj.getrFMoudleType())
                .lockSystemFunction(dnaInfoObj.getLockSystemFunction())
                .lockNetSystemFunction(dnaInfoObj.getLockNetSystemFunction())
                .adminAuthCode(dnaInfoObj.getAuthorizedRoot())
                .aesKey(dnaInfoObj.getDnaAes128Key());


        Lock lock = lockBuilder.build();

        //add to sqllite
        LockViewModel lockViewModel = new ViewModelProvider(this).get(LockViewModel.class);
        lockViewModel.insert(lock);
    }

    private static final String TAG = "AddSecondFragment";
}
