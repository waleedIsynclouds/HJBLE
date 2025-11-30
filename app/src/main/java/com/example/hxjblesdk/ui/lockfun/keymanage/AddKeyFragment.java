package com.example.hxjblesdk.ui.lockfun.keymanage;

import androidx.databinding.DataBindingUtil;
import androidx.fragment.app.DialogFragment;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.navigation.Navigation;

import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioGroup;
import android.widget.Toast;

import com.example.hxjblesdk.R;
import com.example.hxjblesdk.databinding.FragmentAddKeyBinding;
import com.example.hxjblesdk.ui.lockfun.LockFunViewModel;
import com.example.hxjblesdk.ui.lockfun.keymanage.bigdatakey.AddBigDataKeyHelper;
import com.example.hxjblesdk.ui.lockfun.keymanage.bigdatakey.BLESendBigKeyDataPhase;
import com.example.hxjblesdk.ui.lockfun.keymanage.bigdatakey.SendBigKeyDataCallback;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.AddLockKeyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BLEKeyValidTimeParam;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.AddLockKeyResult;
import com.example.hxjblinklibrary.blinkble.entity.reslut.LockKeyResult;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.profile.data.common.KSHWeek;
import com.example.hxjblinklibrary.blinkble.profile.data.common.KeyType;
import com.example.hxjblinklibrary.blinkble.profile.data.common.StatusCode;
import com.example.hxjblinklibrary.blinkble.utils_2.TimeUtils;
import com.example.utils.MyBleClient;
import com.xiasuhuei321.loadingdialog.view.LoadingDialog;

import java.util.Random;


public class AddKeyFragment extends DialogFragment {
    private static final String TAG = "AddKeyFragment";
    public static final int ADD_SIMPLE = 1;
    public static final int ADD_DAY_ROUND = 2;
    public static final int ADD_DAY_VALID = 3;
    private int addType;

    private AddKeyViewModel mViewModel;
    private LockFunViewModel lockFunViewModel;
    private int keyType;
    private FragmentAddKeyBinding fragmentAddKeyBinding;
    private BlinkyAuthAction blinkyAuthAction;

    private AddBigDataKeyHelper addBigDataKeyHelper;

    private LoadingDialog loadingDialog;


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        keyType = AddKeyFragmentArgs.fromBundle(getArguments()).getKeyType();
        fragmentAddKeyBinding = DataBindingUtil.inflate(inflater, R.layout.fragment_add_key, container, false);
        return fragmentAddKeyBinding.getRoot();
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(AddKeyViewModel.class);
        lockFunViewModel = new ViewModelProvider(getActivity()).get(LockFunViewModel.class);
        observeData();
        loadData();
        initListener();
        initView();
    }

    private int getKeyTypeImageResId() {
        int imageResId = 0;
        if (keyType == KeyType.FINGER) {
            imageResId = R.drawable.ic_fingerprint_24dp;
        } else if (keyType == KeyType.PASSWORD) {
            imageResId = R.drawable.ic_dialpad_24dp;
        } else if (keyType == KeyType.CARD) {
            imageResId = R.drawable.ic_credit_card_24dp;
        } else if (keyType == KeyType.REMOTE) {
            imageResId = R.drawable.ic_remote_24dp;
        } else if (keyType == KeyType.Face) {
            imageResId = R.drawable.face_icon;
        } else {
            imageResId = R.drawable.ic_key_24dp;
        }
        return imageResId;
    }

    private void initView() {

        fragmentAddKeyBinding.imageViewContent.setImageResource(getKeyTypeImageResId());

        if (keyType == KeyType.PASSWORD) {
            fragmentAddKeyBinding.password.setVisibility(View.VISIBLE);
            String randomNum = String.valueOf((int) ((Math.random() * 9 + 1) * 100000));
            fragmentAddKeyBinding.password.setText(randomNum);
        } else {
            fragmentAddKeyBinding.password.setVisibility(View.GONE);
        }

        addType = ADD_SIMPLE;
        fragmentAddKeyBinding.addKeyRadioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                if (checkedId == R.id.addKeyRadioButton) {
                    addType = ADD_DAY_ROUND;
                } else if (checkedId == R.id.addKeyRadioButton2) {
                    addType = ADD_SIMPLE;
                } else if (checkedId == R.id.addKeyRadioButton3) {
                    addType = ADD_DAY_VALID;
                }
            }
        });

    }

    private void initListener() {
        fragmentAddKeyBinding.nextButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (keyType == KeyType.Face) {
                    onSendFaceDataItem();
                    //onSendFingerprintDataItem();
                    return;
                }

                if (blinkyAuthAction != null) {

                    switch (addType) {
                        case ADD_SIMPLE:
                            cmdAddKeyBleMethod(keyType,
                                    Integer.parseInt(fragmentAddKeyBinding.userId.getText().toString()),
                                    fragmentAddKeyBinding.password.getText().toString(),
                                    blinkyAuthAction);
                            break;

                        case ADD_DAY_ROUND:

                            cmdAddKeyBleDayRoundMethod(keyType,
                                    Integer.parseInt(fragmentAddKeyBinding.userId.getText().toString()),
                                    fragmentAddKeyBinding.password.getText().toString(),
                                    blinkyAuthAction);

                            break;

                        case ADD_DAY_VALID:
                            //one day
                            cmdAddKeyBleDayValidMethod(keyType, Integer.parseInt(fragmentAddKeyBinding.userId.getText().toString()),
                                    fragmentAddKeyBinding.password.getText().toString(),
                                    blinkyAuthAction,
                                    TimeUtils.getNowMills() / 1000,
                                    (TimeUtils.getNowMills() / 1000) + 60 * 60 * 24 * 20,
                                    0,
                                    0,
                                    0,
                                    0);
                            break;
                    }
                } else {
                    Toast.makeText(getContext(), R.string.no_permission, Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    private void observeData() {
        lockFunViewModel.getAuthAction().observe(getViewLifecycleOwner(), new Observer<BlinkyAuthAction>() {
            @Override
            public void onChanged(BlinkyAuthAction blinkyAuthAction) {
                AddKeyFragment.this.blinkyAuthAction = blinkyAuthAction;
            }
        });
    }

    private void loadData() {
        lockFunViewModel.loadMyAuthAction();
    }


    /**
     * 添加蓝牙开锁钥匙  永久
     *
     * @param keyType
     * @param addedUserID
     * @param password
     * @param baseAuthAction
     */
    public void cmdAddKeyBleMethod(int keyType, int addedUserID, String password, BlinkyAuthAction baseAuthAction) {

        cmdAddKeyBleDayValidMethod(keyType, addedUserID, password, baseAuthAction, 0, 0XFFFFFFFF, 0, 60, 0, 0);
    }


    /**
     * 添加蓝牙开锁钥匙  周期
     *
     * @param keyType
     * @param addedUserID
     * @param password
     * @param baseAuthAction
     */
    public void cmdAddKeyBleDayRoundMethod(int keyType, int addedUserID, String password, BlinkyAuthAction baseAuthAction) {
        cmdAddKeyBleDayValidMethod(keyType, addedUserID, password, baseAuthAction, 0, 0XFFFFFFFF, 60 * 60, 60 * 60 * 2, 1, 1);
    }

    /**
     * 添加蓝牙开锁钥匙 自定义
     *
     * @param keyType
     * @param addedUserID
     * @param password
     * @param baseAuthAction
     * @param validStartTime
     * @param validEndTime
     * @param dayStartTimes
     * @param dayEndTimes
     * @param week
     * @param vaildMode
     */
    private void cmdAddKeyBleDayValidMethod(int keyType, int addedUserID, String password, BlinkyAuthAction baseAuthAction, long validStartTime, long validEndTime, int dayStartTimes, int dayEndTimes, int week, int vaildMode) {
        AddLockKeyAction blinkyAction = new AddLockKeyAction();
        blinkyAction.setBaseAuthAction(baseAuthAction);
        blinkyAction.setAddedKeyType(keyType);
        blinkyAction.setPassword(password);
        blinkyAction.setAddedKeyGroupId(addedUserID);
        blinkyAction.setLocalRemoteMode(1);
        blinkyAction.setModifyTimestamp((long) TimeUtils.getNowMills() / 1000);
        blinkyAction.setValidEndTime(validEndTime);
        blinkyAction.setValidStartTime(validStartTime);
        blinkyAction.setVaildNumber(0xFF);
        blinkyAction.setDayStartTimes(dayStartTimes);
        blinkyAction.setDayEndTimes(dayEndTimes);
        blinkyAction.setVaildMode(vaildMode);
        blinkyAction.setWeek(week);


        switch (keyType) {
            case KeyType.FINGER:
                blinkyAction.setAuthorMode(0);//直接添加
                blinkyAction.setAddedKeyType(0x01);
                break;
            case KeyType.PASSWORD:
                blinkyAction.setAuthorMode(1);//按内容添加
                blinkyAction.setAddedKeyType(0x02);
                if (password != null && password.length() >= 6 && password.length() <= 12) {
                    blinkyAction.setPassword(password);
                } else {
                }
                break;
            case KeyType.CARD:
                blinkyAction.setAuthorMode(0);  //直接添加
                blinkyAction.setAddedKeyType(0x04);
                break;
            case KeyType.REMOTE:
                blinkyAction.setAuthorMode(0);  //直接添加
                blinkyAction.setAddedKeyType(0x08);
                break;
        }

        MyBleClient.getInstance(getActivity().getApplicationContext()).addLockKey(blinkyAction, new FunCallback<AddLockKeyResult>() {
            @Override
            public void onResponse(Response<AddLockKeyResult> response) {
                if (response.isSuccessful()) {
                    Navigation.findNavController(fragmentAddKeyBinding.getRoot()).navigateUp();
                    Toast.makeText(getContext(), R.string.addSuccess, Toast.LENGTH_SHORT).show();
                } else if (response.code() == StatusCode.ACK_STATUS_NEXT) {
                    //根据不同的钥匙类，显示不同的提示语。
                    fragmentAddKeyBinding.textViewLog.setText(R.string.add_hint);
                    fragmentAddKeyBinding.textViewLog.append("\n第" + response.body().getAuthorTimes() + "/" + response.body().getAuthorNum() + "次");
                } else {
                    fragmentAddKeyBinding.textViewLog.setText(StatusCode.parse(response.code(), getContext()));
                }
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }

    private void onSendFingerprintDataItem() {
        String fingerPrintBase64Str = "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";
        startAddBidDataKey(fingerPrintBase64Str, KeyType.FINGER);
    }

    private void onSendFaceDataItem() {
        String faceBase64Str = "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";
        startAddBidDataKey(faceBase64Str, KeyType.Face);
    }

    private void startAddBidDataKey(String keyBase64Str, int keyType) {
        if (addBigDataKeyHelper == null) {
            addBigDataKeyHelper = new AddBigDataKeyHelper();
        }
        loadingDialog = new LoadingDialog(getContext());
        loadingDialog.setLoadingText(getString(R.string.Localizable_preBleSendKeyData)).show();
        int keyGroupId = 901;
        BLEKeyValidTimeParam param = getTimeParam();
        addBigDataKeyHelper.startWithBigDataBase64Str(keyBase64Str, blinkyAuthAction.getMac(), keyGroupId, keyType, param, blinkyAuthAction, new SendBigKeyDataCallback() {
            @Override
            public void onCallback(int statusCode, String reason, int phase, double progress, LockKeyResult keyObj) {
                Log.d(TAG, String.format("status = %d, reason = %s, phase = %d, progress = %f", statusCode, reason, phase, progress));
                if (phase == BLESendBigKeyDataPhase.end) {
                    loadingDialog.loadSuccess();
                } else {
                    String progressStr = String.format("%d%%", (int) (progress * 100));
                    String tips = String.format("%s\n%s", reason, progressStr);
                    if (statusCode != StatusCode.ACK_STATUS_SUCCESS) {
                        loadingDialog.setLoadingText(reason);
                        new Handler().postDelayed(() -> {
                            loadingDialog.close();
                        }, 3000);
                    }else {
                        loadingDialog.setLoadingText(tips);
                    }
                }
            }
        });
    }

    // 请根据实际情况设置人脸钥匙的有效期 (特别注意：keyGroupId为900的用户只支持添加永久钥匙)
    private BLEKeyValidTimeParam getTimeParam() {

        BLEKeyValidTimeParam param = new BLEKeyValidTimeParam();
        if (addType == ADD_DAY_VALID) {
            param.authMode = 1;
            //30天有效
            param.validStartTime = TimeUtils.getNowMills() / 1000;
            param.validEndTime = param.validStartTime + (30 * 24 * 60 * 60);
        } else if (addType == ADD_SIMPLE) {
            //永久有效
            param.authMode = 1;
            param.validStartTime = 0;
            param.validEndTime = 0xFFFFFFFF;
        } else {
            //周期重复时间段授权
            param.authMode = 2;
            // 下面是周一到周日都有效
            param.weeks = KSHWeek.monday | KSHWeek.tuesday | KSHWeek.wednesday | KSHWeek.thursday | KSHWeek.friday | KSHWeek.saturday | KSHWeek.sunday;
            //09:00 ~ 21:00
            param.dayStartTimes = 9 * 60;
            param.dayEndTimes = 21 * 60;

            //1天有效
            param.validStartTime = TimeUtils.getNowMills() / 1000;
            param.validEndTime = param.validStartTime + (24 * 60 * 60);
        }
        param.validNumber = 0xFF;
        return param;
    }

}
