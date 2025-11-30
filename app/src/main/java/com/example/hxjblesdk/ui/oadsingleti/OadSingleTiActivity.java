package com.example.hxjblesdk.ui.oadsingleti;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.example.HxjApp;
import com.example.hxjblesdk.R;
import com.example.hxjblesdk.db.lock.Lock;
import com.example.hxjblesdk.viewmodel.LockViewModel;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.OpenLockAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.DnaInfo;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.utils.MyBleClient;
import com.hxj.bleoad.BleOadHelper;
import com.hxj.bleoad.IOtaListener;

import java.io.IOException;
import java.io.InputStream;


public class OadSingleTiActivity extends AppCompatActivity {
    private static final int SELECT_FILE_REQ = 1;
    public static final String MIME_TYPE_OCTET_STREAM = "application/octet-stream";
    private static final String TAG = "OadSingleActivity";
    private BlinkyAuthAction auth;
    private Uri uri;

    private TextView pathTv;
    private TextView oldTv;
    private TextView nameTv;
    private TextView tvProgress;
    private LockViewModel mLockViewModel;
    private TextView tvStatue;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_oad_single);
        auth = getIntent().getParcelableExtra("auth");
        mLockViewModel = new ViewModelProvider(this).get(LockViewModel.class);
        initView();
        initListener();
    }

    private void initView() {

        pathTv = findViewById(R.id.text_file_name);
        nameTv = findViewById(R.id.tv_name);
        oldTv = findViewById(R.id.tv_old);
        tvProgress = findViewById(R.id.tv_progress);
        tvStatue = findViewById(R.id.tv_statue);

        LiveData<Lock> lockByMac = mLockViewModel.getLockByMac(auth.getMac().toLowerCase());//子线程获取数据
        lockByMac.observe(OadSingleTiActivity.this, new Observer<Lock>() {
            @Override
            public void onChanged(Lock lock) {
                nameTv.setText(lock.getLockName());
                oldTv.setText("Hard:[" + lock.getHardWareVer() + "] ,Soft:[" + lock.getSoftWareVer() + "]");
            }
        });
    }

    private void initListener() {
        findViewById(R.id.button_select).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                selectFile();
            }
        });
        findViewById(R.id.button_updata).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (uri != null) {
                    oadConnectAuth(uri);
                } else {
                    Toast.makeText(OadSingleTiActivity.this, "请选择固件", Toast.LENGTH_SHORT);

                }
            }
        });
    }

    private void onRetry() {
        Log.d(TAG, "onRetry() called");
        //尝试断开
        MyBleClient.getInstance(OadSingleTiActivity.this).disConnectBle(null);

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                oadConnectAuth(uri);
            }
        }, 2000);
    }

    /**
     * 选择固件文件
     */
    public void selectFile() {
        final Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType(MIME_TYPE_OCTET_STREAM);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        if (intent.resolveActivity(getPackageManager()) != null) {
            // file browser has been found on the device
            startActivityForResult(intent, SELECT_FILE_REQ);
        }
    }

    /**
     * OAD 之前一定要鉴权。 注意一次连接仅可鉴权一次。
     *
     * @param uri
     */
    private void oadConnectAuth(final Uri uri) {
        OpenLockAction hxBleAction = new OpenLockAction();
        hxBleAction.setBaseAuthAction(auth);
        MyBleClient.getInstance(OadSingleTiActivity.this).getDna(hxBleAction, new FunCallback<DnaInfo>() {
            @Override
            public void onResponse(Response<DnaInfo> response) {
                InputStream inputStream = null;
                grantUriPermission(getPackageName(), uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
                try {
                    inputStream = getContentResolver().openInputStream(uri);
                } catch (IOException e) {
                    e.printStackTrace();
                }
//                Intent intentDfu = new Intent(OadSingleTiActivity.this, HxDfuActivity.class);
//                startActivity(intentDfu);
                //requestOad(auth.getMac(), inputStream);
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }

//    private void odaBx(String mac, InputStream inputStream) {
//        bxotaClient = new BXOTAClient(new IBxotaListener() {
//            @Override
//            public void onOtaRequeSuccess() {
//                // iBxotaListener.onOtaRequeSuccess();
//                bxotaClient.startOTATransfer(toByteArray(inputStream));
//            }
//
//            @Override
//            public void onComplete() {
//                //iBxotaListener.onComplete();
//            }
//
//            @Override
//            public void onUpdataProgress(float percent) {
//                //iBxotaListener.onUpdataProgress(percent);
//
//            }
//
//            @Override
//            public void onbindGattBXOTAService() {
//                Log.d("lanya---------", "onbindGattBXOTAService() called");
//            }
//
//            @Override
//            public void onConnected() {
//
//            }
//
//            @Override
//            public void onDisconnect() {
//
//            }
//
//            @Override
//            public void logPrint(String info) {
//                Log.d(TAG, "logPrint() called with: info = [" + info + "]");
//
//            }
//        }, OadSingleActivity.this, mac);
//
//        bxotaClient.connect(this);
//    }

    private void requestOad(String mac, InputStream inputStream) {

        BleOadHelper.getInstance().hxOadStart(mac, HxjApp.getInstance().getApplicationContext(), inputStream, new IOtaListener() {
            @Override
            public void onOtaRequeSuccess() {
                Log.d(TAG, "onOtaRequeSuccess() called");
                tvStatue.append("\nonOtaRequeSuccess");
            }

            @Override
            public void onComplete() {
                Log.d(TAG, "onComplete() called");
                tvStatue.append("\nonComplete waiting");
                //等待25秒，读取DNA，（对比固件版本和硬件版本是否为目标版本），并更新锁信息
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        readNewVersion();
                    }
                }, 25 * 1000);
            }

            @Override
            public void onUpdataProgress(float percent) {
                Log.d(TAG, "onUpdataProgress() called with: percent = [" + percent + "]");
                tvProgress.setText((int) percent + "%");
            }

            @Override
            public void onConnected() {
                Log.d(TAG, "onConnected() called");
                tvStatue.setText("onConnected");
            }

            @Override
            public void onDisconnect() {
                Log.d(TAG, "onDisconnect() called");
                tvStatue.append("\nonDisconnect");
            }

            @Override
            public void logPrint(String info) {
                Log.d(TAG, "logPrint() called with: info = [" + info + "]");
                tvStatue.append("\ninfo");
            }

            @Override
            public void transFailed() {
                //传输失败可以重试，但是要先断开之前的连接
                onRetry();
            }
        });
    }

    /**
     * 读取升级后的信息。并更新数据库或云端
     */
    private void readNewVersion() {
        BlinkyAction hxBleAction = new BlinkyAction();
        hxBleAction.setBaseAuthAction(auth);
        MyBleClient.getInstance(this).getDna(hxBleAction, new FunCallback<DnaInfo>() {
            @Override
            public void onResponse(Response<DnaInfo> response) {
                Log.d(TAG, "readNewVersion response = [" + response.body() + "]" + "[" + response.body().getHardWareVer() + "]");
                insetToDb(auth.getMac(), response);

            }

            @Override
            public void onFailure(Throwable t) {
            }
        });
    }

    /**
     * @param mac
     * @param response
     */
    private void insetToDb(String mac, Response<DnaInfo> response) {
        Lock.LockBuilder lockBuilder = Lock.LockBuilder.aLock();
        DnaInfo body = response.body();
        lockBuilder.lockMac(response.body().getMac().toLowerCase())//参数mac 和 response.body().getMac() 比对一下，不要添加到别的设备去了
                .protocolVer(body.getProtocolVer())
                .deviceType(body.getDeviceType())
                .lockName("新升级的" + mac)
                .hardWareVer(body.getHardWareVer())
                .softWareVer(body.getSoftWareVer())
                .lockFunctionType(body.getLockFunctionType())
                .maxUserNum(body.getMaximumUserNum())
                .maxVolume(body.getMaximumVolume())
                .menuFeature(body.getMenuFeature())
                .projectID(body.getProjectID())
                .rFModuleMac(body.getRFModuleMac())
                .rFModuleType(body.getrFMoudleType());
        Lock lock = lockBuilder.build();
        //add to sqllite
        LockViewModel lockViewModel = new ViewModelProvider(this).get(LockViewModel.class);
        lockViewModel.insert(lock);
    }


    @Override
    public void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK)
            return;

        switch (requestCode) {
            case SELECT_FILE_REQ:
                uri = data.getData(); // and read new one
                pathTv.setText(uri.getPath());
                break;
            default:
                break;
        }
    }


//    public byte[] toByteArray(InputStream input) {
//        ByteArrayOutputStream output = new ByteArrayOutputStream();
//        byte[] buffer = new byte[4096];
//        int n = 0;
//        while (true) {
//            try {
//                if (!(-1 != (n = input.read(buffer)))) break;
//            } catch (IOException e) {
//                e.printStackTrace();
//            }
//            output.write(buffer, 0, n);
//        }
//        byte[] pack = output.toByteArray();
//        return pack;
//    }
}