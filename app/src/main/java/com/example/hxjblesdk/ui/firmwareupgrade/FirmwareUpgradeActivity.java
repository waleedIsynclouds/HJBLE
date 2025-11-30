package com.example.hxjblesdk.ui.firmwareupgrade;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.example.HxjApp;
import com.example.hxjblesdk.R;
import com.example.hxjblesdk.db.lock.Lock;
import com.example.hxjblesdk.ui.dfu.DfuService;
import com.example.hxjblesdk.ui.other.AlertDialogFragment;
import com.example.hxjblesdk.viewmodel.LockViewModel;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.DnaInfo;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.profile.data.common.HxbleError;
import com.example.hxjblinklibrary.blinkble.profile.data.common.StatusCode;
import com.example.hxjblinklibrary.blinkble.scanner.HxjBluetoothDevice;
import com.example.hxjblinklibrary.blinkble.scanner.HxjScanCallback;
import com.example.hxjblinklibrary.blinkble.scanner.HxjScanner;
import com.example.utils.HXToast;
import com.example.utils.IntentExtraType;
import com.example.utils.MyBleClient;
import com.xiasuhuei321.loadingdialog.view.LoadingDialog;

import java.util.List;

import no.nordicsemi.android.dfu.DfuProgressListener;
import no.nordicsemi.android.dfu.DfuServiceController;
import no.nordicsemi.android.dfu.DfuServiceInitiator;
import no.nordicsemi.android.dfu.DfuServiceListenerHelper;

public class FirmwareUpgradeActivity extends AppCompatActivity {

    public static final String TAG = FirmwareUpgradeActivity.class.getSimpleName();

    private TextView filePathTV;
    private TextView tipsTV;
    private Button selectFileBtn;
    private Button startBtn;

    private static final int SELECT_FILE_REQUEST_CODE = 100;
    // .bin格式的固件包
    public static final String MIME_TYPE_OCTET_STREAM = "application/octet-stream";
    // zip格式的固件包
    public static final String MIME_TYPE_ZIP = "application/zip";
    private static final int BLEChipType_E = 3;

    private Uri fileUri;


    private String lockMac;
    private BlinkyAuthAction authAction;
    private HxjBluetoothDevice bleDevice;
    private DfuServiceController eUpgradeController;

    private boolean isStartEUpgrade;
    private LoadingDialog loadingDialog;

    private LockViewModel mLockViewModel;


    @Override
    protected void onCreate(@Nullable @org.jetbrains.annotations.Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initUI();

        lockMac = getIntent().getStringExtra(IntentExtraType.LockMac);
        loadLockAuthAction();
        // 先断开所有蓝牙锁连接
        MyBleClient hxjBleClient = MyBleClient.getInstance(HxjApp.getAppContext());
        hxjBleClient.disConnectBle(null);
    }

    private void initUI() {
        setContentView(R.layout.activity_firmware_upgrade);
        filePathTV = findViewById(R.id.tv_file_path);
        tipsTV = findViewById(R.id.tv_tips);
        selectFileBtn = findViewById(R.id.btn_select_file);
        startBtn = findViewById(R.id.btn_start);
        startBtn.setEnabled(false);
        selectFileBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                selectIMGFile();
            }
        });
        startBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isStartEUpgrade = false;
                startScanDevice();
            }
        });
    }

    public void loadLockAuthAction() {

        mLockViewModel = new ViewModelProvider(this).get(LockViewModel.class);
        mLockViewModel.getLockByMac(lockMac).observe(this, new Observer<Lock>() {
            @Override
            public void onChanged(Lock lock) {
                authAction = new BlinkyAuthAction.Builder()
                        .authCode(lock.getAdminAuthCode())
                        .dnaKey(lock.getAesKey())
                        .keyGroupId(900)
                        .bleProtocolVer(lock.getProtocolVer())
                        .mac(lockMac)
                        .build();
            }
        });
    }

    private void startScanDevice() {

        Context context = HxjApp.getAppContext();

        loadingDialog = new LoadingDialog(this);
        loadingDialog.setLoadingText(getString(R.string.scan_device)).show();

        HxjScanner.getInstance().startScan(15 * 1000, context, new HxjScanCallback() {
            @Override
            public void onHxjScanResults(@NonNull List<HxjBluetoothDevice> results) {
                super.onHxjScanResults(results);
                if (results.size() > 0) {
                    for (HxjBluetoothDevice device : results) {
                        if (device.getMac().equals(lockMac)) {
                            HxjScanner.getInstance().stopScan();
                            Log.d(TAG, "onHxjScanResults: 搜索成功");
                            bleDevice = device;
                            int chipType = device.getChipType();
                            if (chipType == 1) {

                            }else if (chipType == 2) {

                            }else if (chipType == BLEChipType_E) {
                                connectDevice();
                            }
                            break;
                        }
                    }
                }
            }

            @Override
            public void onScanFailed(int errorCode) {
                super.onScanFailed(errorCode);
                Log.d(TAG, "onScanFailed: errorCode = " + errorCode);
                String tips = getString(R.string.scan_lock_fail);
                if (errorCode == SCAN_FAILED_NO_LOCATION) {
                    tips = getString(R.string.open_mobile_location);
                }
                HXToast.show(tips);
                stopLoading();

            }
        });
    }

    private void connectDevice() {
        loadingDialog.setLoadingText(getString(R.string.connect_device)).show();
        MyBleClient hxjBleClient = MyBleClient.getInstance(HxjApp.getAppContext());
        BlinkyAction action = new BlinkyAction();
        action.setBaseAuthAction(authAction);
        hxjBleClient.connectBle(action, new FunCallback() {
            @Override
            public void onResponse(Response response) {
                if (response.isSuccessful()) {
                    Log.d(TAG, "onResponse: 开始升级");
                    if (!isStartEUpgrade) {
                        isStartEUpgrade = true;
                        startEUpgrade();
                    }
                }else {
                    if (!isStartEUpgrade) {
                        stopLoading();
                        String responseStr = StatusCode.parse(response.code(), HxjApp.getAppContext()) + " [" + response.code() + "]";
                        HXToast.show(responseStr);
                    }
                }
            }
            @Override
            public void onFailure(Throwable t) {
                if (!isStartEUpgrade) {
                    HXToast.show(t.getMessage());
                    stopLoading();
                }
            }
        });
    }

    private void startEUpgrade() {
        loadingDialog.setLoadingText(getString(R.string.waiting_for_upgrade)).show();
        addEListener();
        String deviceAddress = bleDevice.getDevice().getAddress();
        final DfuServiceInitiator starter = new DfuServiceInitiator(deviceAddress)
                .setDeviceName(deviceAddress)
                .setKeepBond(false)
                .setForceDfu(false)
                .setMtu(247)
                .setPacketsReceiptNotificationsEnabled(false)
                .setPacketsReceiptNotificationsValue(12)
                .setPrepareDataObjectDelay(300L)
                .setUnsafeExperimentalButtonlessServiceInSecureDfuEnabled(true);
        starter.setZip(fileUri, null);//uri和path有一个就好了
        Log.d(TAG, "startEUpgrade: uri = [" + fileUri + "], deviceAddress = [" + deviceAddress + "]");
        eUpgradeController = starter.start(this, DfuService.class);
    }

    private void addEListener() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            DfuServiceInitiator.createDfuNotificationChannel(this);
        }
        DfuServiceListenerHelper.registerProgressListener(this, new DfuProgressListener() {
            @Override
            public void onDeviceConnecting(@NonNull String deviceAddress) {
                Log.d(TAG, "onDeviceConnecting: deviceAddress = " + deviceAddress);
            }

            @Override
            public void onDeviceConnected(@NonNull String deviceAddress) {
                Log.d(TAG, "onDeviceConnected: deviceAddress = " + deviceAddress);
            }

            @Override
            public void onDfuProcessStarting(@NonNull String deviceAddress) {
                Log.d(TAG, "onDfuProcessStarting: deviceAddress = " + deviceAddress);
            }

            @Override
            public void onDfuProcessStarted(@NonNull String deviceAddress) {
                Log.d(TAG, "onDfuProcessStarted: deviceAddress = " + deviceAddress);
            }

            @Override
            public void onEnablingDfuMode(@NonNull String deviceAddress) {
                Log.d(TAG, "onEnablingDfuMode: deviceAddress = " + deviceAddress);
            }

            @Override
            public void onProgressChanged(@NonNull String deviceAddress, int percent, float speed, float avgSpeed, int currentPart, int partsTotal) {
                stopLoading();
                String tips = String.format(getString(R.string.upgrade_progress), percent);
                Log.d(TAG, "onProgressChanged: " + tips);
                tipsTV.setText(tips);
            }

            @Override
            public void onFirmwareValidating(@NonNull String deviceAddress) {
                Log.d(TAG, "onFirmwareValidating: deviceAddress = " + deviceAddress);
            }

            @Override
            public void onDeviceDisconnecting(String deviceAddress) {
                Log.d(TAG, "onDeviceDisconnecting: deviceAddress = " + deviceAddress);
            }

            @Override
            public void onDeviceDisconnected(@NonNull String deviceAddress) {
                stopLoading();
                Log.d(TAG, "onDeviceDisconnected: deviceAddress = " + deviceAddress);
            }

            @Override
            public void onDfuCompleted(@NonNull String deviceAddress) {
                String tips = getString(R.string.upgrade_completed);
                Log.d(TAG, "onDfuCompleted: " + tips);
                tipsTV.setText(tips);
                getDNAInfo();
            }

            @Override
            public void onDfuAborted(@NonNull String deviceAddress) {
                stopLoading();
                Log.d(TAG, "onDfuAborted: deviceAddress = " + deviceAddress);
            }

            @Override
            public void onError(@NonNull String deviceAddress, int error, int errorType, String message) {
                stopLoading();
                String tips = getString(R.string.upgrade_failed) + ", message = " + message + " (" + error + ")";
                Log.d(TAG, "onError: " + tips);
                tipsTV.setText(tips);
            }
        });
    }

    private void getDNAInfo() {

        loadingDialog = new LoadingDialog(this);
        loadingDialog.setLoadingText(getString(R.string.get_lock_dna_info)).show();
        MyBleClient hxjBleClient = MyBleClient.getInstance(HxjApp.getAppContext());
        BlinkyAction action = new BlinkyAction();
        action.setBaseAuthAction(authAction);
        hxjBleClient.getDna(action, new FunCallback<DnaInfo>() {
            @Override
            public void onResponse(Response<DnaInfo> response) {
                stopLoading();
                Context context = HxjApp.getAppContext();
                if (response.isSuccessful()) {
                    String softwareVersion = response.body().getSoftWareVer();
                    showAlertView(softwareVersion);
                }else {
                    String responseStr = StatusCode.parse(response.code(), context) + " [" + response.code() + "]";
                    HXToast.show(responseStr);
                }
            }

            @Override
            public void onFailure(Throwable t) {
                stopLoading();
                String responseStr = t.getMessage() + " [" + ((HxbleError) t).getmErrorCode() + "]";
                HXToast.show(responseStr);
            }
        });

    }

    private void showAlertView(String version) {
        String text = getString(R.string.upgrade_completed) + "\n\n" + getString(R.string.lock_softversion) + ": " + version;
        AlertDialogFragment alertDialogFragment = new AlertDialogFragment(getString(R.string.close), null, text,
                new AlertDialogFragment.OnButtonCallBack() {
                    @Override
                    public void onPositiveButtonClick() {
                       finish();
                    }

                    @Override
                    public void onNegativeButton() {
                        finish();

                    }
                }
        );
        alertDialogFragment.show(getSupportFragmentManager(), "");
    }


    /**
     * 选择固件文件
     */
    public void selectIMGFile() {
        final Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType(MIME_TYPE_ZIP);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        if (intent.resolveActivity(getPackageManager()) != null) {
            startActivityForResult(intent, SELECT_FILE_REQUEST_CODE);
        }
    }


    @Override
    public void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK)
            return;

        switch (requestCode) {
            case SELECT_FILE_REQUEST_CODE:
                fileUri = data.getData();
                Log.d(TAG, "onActivityResult: fileUri = " + fileUri + ", data = " + data);
                filePathTV.setText(fileUri.getPath());
                startBtn.setEnabled(true);
                break;
            default:
                break;
        }
    }

    private void stopLoading() {
        if (loadingDialog != null) {
            loadingDialog.close();
            loadingDialog = null;
        }
    }

}
