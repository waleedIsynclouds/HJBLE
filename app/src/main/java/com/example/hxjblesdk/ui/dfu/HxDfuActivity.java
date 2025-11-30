package com.example.hxjblesdk.ui.dfu;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.example.hxjblesdk.R;

import no.nordicsemi.android.dfu.DfuBaseService;
import no.nordicsemi.android.dfu.DfuProgressListener;
import no.nordicsemi.android.dfu.DfuServiceController;
import no.nordicsemi.android.dfu.DfuServiceInitiator;
import no.nordicsemi.android.dfu.DfuServiceListenerHelper;

public class HxDfuActivity extends AppCompatActivity {

    private static final String TAG = "HxDfuActivity";
    private static final int SELECT_FILE_REQ = 1;
    public static final String MIME_TYPE_ZIP_STREAM = "application/zip";
    public static final String MIME_TYPE_OCTET_STREAM = "application/octet-stream";
    private String path;
    private Button btnSelectFile;
    private Button btnDfu;
    private TextView tvPath;
    private Uri uri;


    private DfuProgressListener dfuProgressListener = new DfuProgressListener() {
        @Override
        public void onDeviceConnecting(@NonNull String deviceAddress) {
            Log.d(TAG, "onDeviceConnecting() called with: deviceAddress = [" + deviceAddress + "]");
        }

        @Override
        public void onDeviceConnected(@NonNull String deviceAddress) {
            Log.d(TAG, "onDeviceConnected() called with: deviceAddress = [" + deviceAddress + "]");
        }

        @Override
        public void onDfuProcessStarting(@NonNull String deviceAddress) {
            Log.d(TAG, "onDfuProcessStarting() called with: deviceAddress = [" + deviceAddress + "]");
        }

        @Override
        public void onDfuProcessStarted(@NonNull String deviceAddress) {
            Log.d(TAG, "onDfuProcessStarted() called with: deviceAddress = [" + deviceAddress + "]");
        }

        @Override
        public void onEnablingDfuMode(@NonNull String deviceAddress) {
            Log.d(TAG, "onEnablingDfuMode() called with: deviceAddress = [" + deviceAddress + "]");
        }

        @Override
        public void onProgressChanged(@NonNull String deviceAddress, int percent, float speed, float avgSpeed, int currentPart, int partsTotal) {
            Log.d(TAG, "onProgressChanged() called with: deviceAddress = [" + deviceAddress + "], percent = [" + percent + "], speed = [" + speed + "], avgSpeed = [" + avgSpeed + "], currentPart = [" + currentPart + "], partsTotal = [" + partsTotal + "]");
        }

        @Override
        public void onFirmwareValidating(@NonNull String deviceAddress) {
            Log.d(TAG, "onFirmwareValidating() called with: deviceAddress = [" + deviceAddress + "]");
        }

        @Override
        public void onDeviceDisconnecting(String deviceAddress) {
            Log.d(TAG, "onDeviceDisconnecting() called with: deviceAddress = [" + deviceAddress + "]");
        }

        @Override
        public void onDeviceDisconnected(@NonNull String deviceAddress) {
            Log.d(TAG, "onDeviceDisconnected() called with: deviceAddress = [" + deviceAddress + "]");
        }

        @Override
        public void onDfuCompleted(@NonNull String deviceAddress) {
            Log.d(TAG, "onDfuCompleted() called with: deviceAddress = [" + deviceAddress + "]");
        }

        @Override
        public void onDfuAborted(@NonNull String deviceAddress) {
            Log.d(TAG, "onDfuAborted() called with: deviceAddress = [" + deviceAddress + "]");
        }

        @Override
        public void onError(@NonNull String deviceAddress, int error, int errorType, String message) {
            Log.d(TAG, "onError() called with: deviceAddress = [" + deviceAddress + "], error = [" + error + "], errorType = [" + errorType + "], message = [" + message + "]");
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_hx_dfu);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            DfuServiceInitiator.createDfuNotificationChannel(this);
        }

        tvPath = findViewById(R.id.textView_path);
        btnSelectFile = findViewById(R.id.button_select_file);
        btnDfu = findViewById(R.id.button_dfu_updata);

        btnSelectFile.setOnClickListener(v -> selectFile());
        btnDfu.setOnClickListener(v -> startDfu());


        DfuServiceListenerHelper.registerProgressListener(this, dfuProgressListener);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        DfuServiceListenerHelper.unregisterProgressListener(this, dfuProgressListener);

    }

    private void startDfu() {
         final DfuServiceInitiator starter = new DfuServiceInitiator("60:98:66:7D:36:5A")
//        final DfuServiceInitiator starter = new DfuServiceInitiator("01:BF:66:21:C2:00")
                .setDeviceName("设备名称")
                .setKeepBond(false)
                .setForceDfu(false)
                .setMtu(247)
                .setPacketsReceiptNotificationsEnabled(false)//ti禁用
                .setPacketsReceiptNotificationsValue(12)//可以自定义
                .setPrepareDataObjectDelay(300L)
                .setUnsafeExperimentalButtonlessServiceInSecureDfuEnabled(true);
        starter.setZip(uri, null);//uri和path有一个就好了
//        starter.setBinOrHex(DfuBaseService.TYPE_APPLICATION, uri);//uri和path有一个就好了

        DfuServiceController start = starter.start(this, DfuService.class);
        start.abort();
    }

    /**
     * 选择固件文件
     */
    public void selectFile() {
        final Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
//        intent.setType(MIME_TYPE_ZIP_STREAM);
        intent.setType(MIME_TYPE_OCTET_STREAM);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        if (intent.resolveActivity(getPackageManager()) != null) {
            // file browser has been found on the device
            startActivityForResult(intent, SELECT_FILE_REQ);
        }
    }


    @Override
    public void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK)
            return;

        switch (requestCode) {
            case SELECT_FILE_REQ:
                uri = data.getData(); // and read new one
                tvPath.setText(uri.getPath());
                break;
            default:
                break;
        }
    }

}