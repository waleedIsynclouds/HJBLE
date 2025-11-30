package com.example.hxjblesdk.ui.lockfun;

import android.app.Application;
import android.os.Parcelable;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.example.hxjblesdk.db.lock.Lock;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.SyncLockKeyAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.LockKeyResult;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.profile.data.common.StatusCode;
import com.example.hxjblinklibrary.blinkble.scanner.HxjBluetoothDevice;
import com.example.hxjblinklibrary.blinkble.utils_2.TimeUtils;
import com.example.utils.MyBleClient;

import java.util.ArrayList;
import java.util.List;

public class LockFunViewModel extends AndroidViewModel {

    private static final String TAG = LockFunViewModel.class.getSimpleName();

    private MutableLiveData<String> mText;
    private MutableLiveData<BlinkyAuthAction> mAuthaction;
    private MutableLiveData<List<LockKeyResult>> mLiveLockKeyResults;
    private List<LockKeyResult> lockKeyResults = new ArrayList<>();

    private HxjBluetoothDevice hxjBluetoothDevice;
    private Lock lockObj;

    public LockFunViewModel(@NonNull Application application) {
        super(application);
        mText = new MutableLiveData<>();
        mText.setValue("This is LockFunViewModel");
    }

    public HxjBluetoothDevice getHxjBluetoothDevice() {
        return hxjBluetoothDevice;
    }

    public void setHxjBluetoothDevice(HxjBluetoothDevice hxjBluetoothDevice) {
        this.hxjBluetoothDevice = hxjBluetoothDevice;
    }

    public void setLockObj(Lock lockObj) {
        this.lockObj = lockObj;
    }

    public Lock getLockObj() {
        return lockObj;
    }

    public LiveData<String> getText() {
        return mText;
    }


    public LiveData<BlinkyAuthAction> getAuthAction() {
        mAuthaction = new MutableLiveData<>();
        return mAuthaction;
    }

    public MutableLiveData<List<LockKeyResult>> getmLiveLockKeyResults() {
        if (mLiveLockKeyResults == null)
            mLiveLockKeyResults = new MutableLiveData<>();
        return mLiveLockKeyResults;
    }

    public BlinkyAuthAction loadMyAuthAction() {

        BlinkyAuthAction authion = new BlinkyAuthAction.Builder()
                .authCode(lockObj.getAdminAuthCode())
                .dnaKey(lockObj.getAesKey())
                .keyGroupId(900)
                .bleProtocolVer(lockObj.getProtocolVer())
                .hxjBluetoothDevice(hxjBluetoothDevice)
                .mac(lockObj.getLockMac())
                .build();
        mAuthaction.setValue(authion);
        return authion;
    }


    public void cmdSyncLockKeys(BlinkyAuthAction baseAuthAction) {
        lockKeyResults.clear();

        SyncLockKeyAction hxBleAction = new SyncLockKeyAction((int) (TimeUtils.getNowMills() / 1000));
        hxBleAction.setBaseAuthAction(baseAuthAction);
        MyBleClient.getInstance(getApplication().getApplicationContext()).syncLockKey(hxBleAction, new FunCallback<LockKeyResult>() {
            @Override
            public void onResponse(Response<LockKeyResult> response) {
                if (response.isSuccessful()) {
                    Log.w(TAG, "response.isSuccessful()" + response.body().getKeyNum());
                    if (response.body() != null && response.body().getKeyNum() != 0) {
                        lockKeyResults.add(response.body());
                        mLiveLockKeyResults.setValue(lockKeyResults);
                    } else {
                        mLiveLockKeyResults.setValue(new ArrayList<>());
                    }
                } else if (response.code() == StatusCode.ACK_STATUS_NEXT) {
                    Log.w(TAG, "response.next()" + response.body().getKeyNum());
                    if (response.body() != null && response.body().getKeyNum() != 0) {
                        lockKeyResults.add(response.body());
                    }
                } else {
                    //mLiveLockKeyResults.setValue(new ArrayList<>());
                }
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }



}