package com.example.hxjblesdk.ui.lockfun.locksetting;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.preference.ListPreference;
import androidx.preference.Preference;
import androidx.preference.PreferenceFragmentCompat;
import androidx.preference.PreferenceManager;
import androidx.preference.PreferenceViewHolder;
import androidx.preference.SwitchPreference;
import androidx.preference.SwitchPreferenceCompat;

import com.example.hxjblesdk.R;
import com.example.hxjblesdk.ui.lockfun.LockFunViewModel;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.SysParamResult;

public class LockSettingsFragment extends PreferenceFragmentCompat {
    private static final String TAG = "LockSettingsFragment";
    public static final String IS_SOUND = "isSound";
    public static final String SYS_VOLUME = "sysVolume";
    public static final String LOCK_SYSTEM_LANGUAGE = "lockSystemLanguage";
    public static final String LOCK_OPEN_AUTH = "lockOpenAuth";
    public static final String NORMALLY_OPEN = "normally_open";
    public static final String IS_TAMPER_WARN = "isTamperWarn";
    public static final String IS_CORN_WARN = "isLockCoreWarn";
    public static final String IS_LOCK_CAP = "isLockCap";
    private LockSettingViewModel mViewModel;
    private LockFunViewModel lockFunViewModel;
    private SwitchPreference isSound;
    private SwitchPreference lockOpenAuth;
    private SwitchPreference normally_open;
    private SwitchPreference isTamperWarn;
    private SwitchPreference isLockCoreWarn;
    private SwitchPreference isLockCap;
    private ListPreference sysVolume;
    private ListPreference lockSystemLanguage;
    private Preference.OnPreferenceChangeListener onPreferenceChangeListener;
    private BlinkyAuthAction blinkyAuthAction;
    private SysParamResult sysParamResult;

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        setPreferencesFromResource(R.xml.root_preferences, rootKey);
        isSound = findPreference(IS_SOUND);
        sysVolume = findPreference(SYS_VOLUME);
        lockSystemLanguage = findPreference(LOCK_SYSTEM_LANGUAGE);
        lockOpenAuth = findPreference(LOCK_OPEN_AUTH);
        normally_open = findPreference(NORMALLY_OPEN);
        isTamperWarn = findPreference(IS_TAMPER_WARN);
        isLockCoreWarn = findPreference(IS_CORN_WARN);
        isLockCap = findPreference(IS_LOCK_CAP);
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = super.onCreateView(inflater, container, savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(LockSettingViewModel.class);
        lockFunViewModel = new ViewModelProvider(getActivity()).get(LockFunViewModel.class);

        observer();
        setListener();
        lockFunViewModel.loadMyAuthAction();//获取鉴权
        return view;
    }

    private void setListener() {
        isLockCap.setOnPreferenceChangeListener(this::onPreferenceChange);
        isLockCoreWarn.setOnPreferenceChangeListener(this::onPreferenceChange);
        isTamperWarn.setOnPreferenceChangeListener(this::onPreferenceChange);
        normally_open.setOnPreferenceChangeListener(this::onPreferenceChange);
        lockOpenAuth.setOnPreferenceChangeListener(this::onPreferenceChange);
        lockSystemLanguage.setOnPreferenceChangeListener(this::onPreferenceChange);
        sysVolume.setOnPreferenceChangeListener(this::onPreferenceChange);
        isSound.setOnPreferenceChangeListener(this::onPreferenceChange);
    }

    private void observer() {
        //订阅系统设置
        mViewModel.getSysParamResultMutableLiveData().observe(getViewLifecycleOwner(), new Observer<SysParamResult>() {
            @Override
            public void onChanged(SysParamResult result) {
                sysParamResult = result;
                Log.d(TAG, "onChanged() called with: sysParamResult = [" + sysParamResult + "]");
                isSound.setChecked(sysParamResult.getIsSound() == 1);
                lockOpenAuth.setChecked(sysParamResult.getLockOpen() == 2);
                normally_open.setChecked(sysParamResult.getNormallyOpen() == 1);
                isTamperWarn.setChecked(sysParamResult.getIsTamperWarn() == 1);
                isLockCoreWarn.setChecked(sysParamResult.getIsLockCoreWarn() == 1);
                isLockCap.setChecked(sysParamResult.getIsLockCap() == 1);
                sysVolume.setValueIndex(sysParamResult.getSysVolume());
                lockSystemLanguage.setValueIndex(sysParamResult.getSystemLanguage());

            }
        });
        //订阅鉴权信息
        lockFunViewModel.getAuthAction().observe(getViewLifecycleOwner(), new Observer<BlinkyAuthAction>() {
            @Override
            public void onChanged(BlinkyAuthAction authAction) {
                blinkyAuthAction = authAction;
                mViewModel.bleLoadSysParam(blinkyAuthAction); //获取系统设置
            }
        });
    }


    public boolean onPreferenceChange(Preference preference, Object newValue) {
        if (sysParamResult == null) {
            Toast.makeText(getContext(), "Please wait, lock status update", Toast.LENGTH_SHORT).show();
            return false;
        }
        switch (preference.getKey()) {
            case IS_SOUND:
                sysParamResult.setIsSound((boolean) newValue ? 1 : 2);
                break;
            case SYS_VOLUME:
                sysParamResult.setSysVolume(Integer.parseInt((String) newValue));
                break;
            case LOCK_SYSTEM_LANGUAGE:
                sysParamResult.setSystemLanguage(Integer.parseInt((String) newValue));
                break;
            case LOCK_OPEN_AUTH:
                sysParamResult.setLockOpen((boolean) newValue ? 2 : 1);
                break;
            case NORMALLY_OPEN:
                sysParamResult.setNormallyOpen((boolean) newValue ? 1 : 2);
                break;
            case IS_TAMPER_WARN:
                sysParamResult.setIsTamperWarn((boolean) newValue ? 1 : 2);
                break;
            case IS_CORN_WARN:
                sysParamResult.setIsLockCoreWarn((boolean) newValue ? 1 : 2);
                break;
            case IS_LOCK_CAP:
                sysParamResult.setIsLockCap((boolean) newValue ? 1 : 2);
                break;
        }
        Log.d(TAG, "onPreferenceChange() called with: preference = [" + preference + "], newValue = [" + newValue + "]");
        mViewModel.bleSetSysParam(sysParamResult, blinkyAuthAction);
        return false;
    }
}