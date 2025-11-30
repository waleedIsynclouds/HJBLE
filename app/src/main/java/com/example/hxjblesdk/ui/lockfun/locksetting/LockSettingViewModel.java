package com.example.hxjblesdk.ui.lockfun.locksetting;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.SetSysParamAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.SysParamResult;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.utils.MyBleClient;

public class LockSettingViewModel extends AndroidViewModel {

    private MutableLiveData<SysParamResult> sysParamResultMutableLiveData = new MutableLiveData<>();

    public LockSettingViewModel(@NonNull Application application) {
        super(application);
    }

    public LiveData<SysParamResult> getSysParamResultMutableLiveData() {
        return sysParamResultMutableLiveData;
    }

    /**
     * 获取系统设置信息
     *
     * @param baseAuthAction
     */
    public void bleLoadSysParam(BlinkyAuthAction baseAuthAction) {
        BlinkyAction hxBleAction = new BlinkyAction();
        hxBleAction.setBaseAuthAction(baseAuthAction);
        MyBleClient.getInstance(getApplication()).getSysParam(hxBleAction, new FunCallback<SysParamResult>() {
            @Override
            public void onResponse(Response<SysParamResult> response) {
                if (response.isSuccessful()) {
                    sysParamResultMutableLiveData.setValue(response.body());
                }
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }

    /**
     * 获取系统设置信息
     *
     * @param
     */
    public void bleSetSysParam(SysParamResult SysParamResult, BlinkyAuthAction baseAuthAction) {
        SetSysParamAction hxBleAction = new SetSysParamAction();
        hxBleAction.setBaseAuthAction(baseAuthAction);
        hxBleAction.setIsSound(SysParamResult.getIsSound());
        hxBleAction.setLockOpen(SysParamResult.getLockOpen());
        hxBleAction.setNormallyOpen(SysParamResult.getNormallyOpen());
        hxBleAction.setIsTamperWarn(SysParamResult.getIsTamperWarn());
        hxBleAction.setIsLockCoreWarn(SysParamResult.getIsLockCoreWarn());
        hxBleAction.setIsLockCap(SysParamResult.getIsLockCap());
//        hxBleAction.setSysVolume(SysParamResult.getSysVolume());
//        hxBleAction.setSystemLanguage(SysParamResult.getSystemLanguage());
        MyBleClient.getInstance(getApplication()).setSysParam(hxBleAction, new FunCallback() {
            @Override
            public void onResponse(Response response) {
                if (response.isSuccessful()) {
                    sysParamResultMutableLiveData.setValue(SysParamResult);
                }
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }
}