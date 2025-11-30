package com.example.hxjblesdk.ui.lockfun.newfeature;

import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.example.hxjblesdk.R;
import com.example.hxjblesdk.ui.lockfun.LockFunViewModel;
import com.example.hxjblinklibrary.blinkble.entity.Response;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.HeartbeatAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.NfcCardReadAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.NfcCardSetAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.NfcCardWriteAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.OpenLockAction;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.SetExpirationTimeAction;
import com.example.hxjblinklibrary.blinkble.entity.reslut.ExpirationTimeResult;
import com.example.hxjblinklibrary.blinkble.entity.reslut.LockKeyMessageResult;
import com.example.hxjblinklibrary.blinkble.entity.reslut.NfcCardReadNumResult;
import com.example.hxjblinklibrary.blinkble.entity.reslut.NfcCardReadResult;
import com.example.hxjblinklibrary.blinkble.entity.reslut.NfcCardSetResult;
import com.example.hxjblinklibrary.blinkble.profile.client.FunCallback;
import com.example.hxjblinklibrary.blinkble.profile.data.HXMutableData;
import com.example.hxjblinklibrary.blinkble.profile.data.common.StatusCode;
import com.example.hxjblinklibrary.blinkble.utils.ByteUtil;
import com.example.hxjblinklibrary.blinkble.utils_2.TimeUtils;
import com.example.utils.MyBleClient;
import com.example.utils.SPUtils;

import java.util.Arrays;
import java.util.List;

import no.nordicsemi.android.ble.data.Data;

public class NewFeatureFragment extends Fragment {

    private NewFeatureViewModel newFeatureViewModel;
    private LockFunViewModel lockFunViewModel;
    private BlinkyAuthAction mAuthion;
    private TextView tvLog;
    //清除，系统设置，安装
    private List<String> cardList = Arrays.asList("4D2E828D154D9AA589201B26C01C08DA7196F83DA4B57346DE7507B856EB94405953BFC2FB9A36A07483DC69BE249D55",
            "70D82B8C9E5D7B187BC2A69B8F67C7D07196F83DA4B57346DE7507B856EB94405B0B31F4E576A11310395163947FBF8E",
            "37E9A9DE9BB4E489E13A59C31BF88EEB1A16BCA8EF80CF8FA5BB5E3426032AD6068D69FF71710742B77A35ADC23A485C",
            " 37E9A9DE9BB4E489E13A59C31BF88EEB1A16BCA8EF80CF8FA5BB5E3426032AD6068D69FF71710742B77A35ADC23A485C");

    //清除，系统设置，安装
    private List<String> cardList2 = Arrays.asList("0C83BEFDA5B90F7799982EEBF8FE4FEB63B2DD4739EFB33ACFADE405B33170F4E1C8160664830C32085538D9D3836775",
            "61DF8F80881F9358A1FC92F1BFF689CC63B2DD4739EFB33ACFADE405B33170F479BDD9EEF5EB1D63602D2217587D6D52",
            "DFDF5587BEA0D97F395D4733BB111C247CE013AD306B3FE971B93E57EB1F0D1BF1897C3526FE58876C964552ACA4CEF0",
            "D1D6A62CAB5CD01DBD5A72A17C361F9CBFDAB48AB34444769214B69B2F95330C63E13729997AD71762EA21C56136D1D2");

//    private Button buttonReadLockInfo;
//    private Button buttonHeartBeat;
//    private Button btnGetAuthTime;
//    private Button btnSetAuthTime;

    private Button btnSetCard;
    private Button btnChangeMode;
    private EditText etChangeMode, editTextTextPersonName, editTextTextPersonName2, editTextTextPersonName3, editTextTextPersonName4;
    private int type;
    private Button button_read_card_num, button_write_card, button_read, button_change_write_mode, button_time_start, button_time_stop;
    private int writeType;

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        lockFunViewModel = new ViewModelProvider(getActivity()).get(LockFunViewModel.class);
        newFeatureViewModel = new ViewModelProvider(this).get(NewFeatureViewModel.class);

        View root = inflater.inflate(R.layout.fragment_new_feature_blecard, container, false);
        tvLog = root.findViewById(R.id.textViewLog);

//        buttonReadLockInfo = root.findViewById(R.id.buttonReadLockInfo);
//        buttonHeartBeat = root.findViewById(R.id.buttonHeartBeat);
//        btnGetAuthTime = root.findViewById(R.id.button_get_auth_time);
//        btnSetAuthTime = root.findViewById(R.id.button_set_auth_time);

        btnSetCard = root.findViewById(R.id.button_set);
        btnChangeMode = root.findViewById(R.id.button_change_mode);
        etChangeMode = root.findViewById(R.id.et_change_mode);

        button_read_card_num = root.findViewById(R.id.button_read_card_num);
        button_write_card = root.findViewById(R.id.button_write_card);
        button_change_write_mode = root.findViewById(R.id.button_change_write_mode);
        button_read = root.findViewById(R.id.button_read);
        button_time_start = root.findViewById(R.id.button_time_start);
        button_time_stop = root.findViewById(R.id.button_time_stop);
        editTextTextPersonName = root.findViewById(R.id.editTextTextPersonName);
        editTextTextPersonName2 = root.findViewById(R.id.editTextTextPersonName2);
        editTextTextPersonName3 = root.findViewById(R.id.editTextTextPersonName3);
        editTextTextPersonName4 = root.findViewById(R.id.editTextTextPersonName4);

        String pwd = SPUtils.getInstance().getString("pwd");
        if (TextUtils.isEmpty(pwd)) {
            editTextTextPersonName3.setText("FB949D0BA309");
        } else {
            editTextTextPersonName3.setText(pwd);
        }

        observer();
        loadData();
        initListener();
        return root;
    }


    Handler handler = new Handler();
    Runnable runnable = new Runnable() {
        @Override
        public void run() {
            HXMutableData hxTimeData = CardCmd.makeTimeCard().makeCardSum();
            Data dataHxTimeData = hxTimeData.encyptFun04(2);
            etChangeMode.setText(ByteUtil.bytesToHexString(dataHxTimeData.getValue()));
            cmdNfcCardSet(mAuthion);
            //要做的事情
            handler.postDelayed(this, 2000);
        }
    };

    private void observer() {
        newFeatureViewModel.getText().observe(getViewLifecycleOwner(), s -> {
            tvLog.setText(s);
        });
        lockFunViewModel.getText().observe(getViewLifecycleOwner(), s -> {
            tvLog.setText(s);
        });
        lockFunViewModel.getAuthAction().observe(getViewLifecycleOwner(), s -> {
            mAuthion = s;
        });
    }

    private void loadData() {
        lockFunViewModel.loadMyAuthAction();
    }

    private void initListener() {
//        buttonReadLockInfo.setOnClickListener(v -> cmdGetKeyDetail(mAuthion));
//        buttonHeartBeat.setOnClickListener(v -> cmdSetHeartbeat(mAuthion));
//        btnGetAuthTime.setOnClickListener(v -> cmdGetAuthTime(mAuthion));
//        btnSetAuthTime.setOnClickListener(v -> cmdSetAuthTime(mAuthion));


        button_time_stop.setOnClickListener(v -> handler.removeCallbacks(runnable));
        button_time_start.setOnClickListener(v -> handler.postDelayed(runnable, 2000));
        btnSetCard.setOnClickListener(v -> cmdNfcCardSet(mAuthion));
        btnChangeMode.setOnClickListener(new View.OnClickListener() {


            @Override
            public void onClick(View v) {
                if (type == 3) {
                    type = 0;
                } else {
                    type++;
                }
                byte[] hotelAES128 = {(byte) 0xB8, (byte) 0x2D, (byte) 0xC8, (byte) 0x7B, (byte) 0x2B, (byte) 0x43, (byte) 0x87, (byte) 0xB1, (byte) 0xDB, (byte) 0xFE, (byte) 0xA1, (byte) 0xAD, (byte) 0x48, (byte) 0x56, (byte) 0xBC, (byte) 0xD7}; // aes128
                byte[] hxjAES128 = {(byte) 0x92, (byte) 0xDA, (byte) 0xC9, (byte) 0xE8, (byte) 0xAB, (byte) 0x9F, (byte) 0x82, (byte) 0x87, (byte) 0x97, (byte) 0x8D, (byte) 0x5E, (byte) 0x75, (byte) 0xAB, (byte) 0xB6, (byte) 0x34, (byte) 0xF5}; // aes128

                HXMutableData hxTimeData = CardCmd.makeTimeCard().makeCardSum();

                HXMutableData hxSetData = CardCmd.makeSetCard(hotelAES128).makeCardSum();


                HXMutableData hxClearData = CardCmd.makeClearCard().makeCardSum();

                Data dataHxTimeData = hxTimeData.encyptFun04(2);


                Data dataHxSetData = hxSetData.encyptFun04(1);


                Data dataHxClearData = hxClearData.encyptFun04(1);
                btnChangeMode.setText(type == 0 ? "清除卡" : type == 1 ? "系统设置卡" : type == 2 ? "安装卡" : "自定义");
                etChangeMode.setText(type == 0 ? ByteUtil.bytesToHexString(dataHxClearData.getValue()) : type == 1 ? cardList.get(1) : type == 2 ? ByteUtil.bytesToHexString(dataHxSetData.getValue()) : ByteUtil.bytesToHexString(dataHxTimeData.getValue()));
            }
        });

        button_change_write_mode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (writeType == 3) {
                    writeType = 0;
                } else {
                    writeType++;
                }
                button_change_write_mode.setText(writeType == 0 ? "清除卡" : writeType == 1 ? "系统设置卡" : writeType == 2 ? "安装卡" : "校时卡");
                editTextTextPersonName4.setText(writeType == 0 ? cardList2.get(0) : writeType == 1 ? cardList2.get(1) : writeType == 2 ? cardList2.get(2) : cardList2.get(3));
            }
        });

        button_read_card_num.setOnClickListener(v -> cmdNfcCardReadNum(mAuthion));
        button_write_card.setOnClickListener(v -> cmdNfcCardWrite(mAuthion));
        button_read.setOnClickListener(v -> cmdNfcCardRead(mAuthion));
    }

    private void cmdNfcCardSet(BlinkyAuthAction mAuthion) {
        NfcCardSetAction hxBleAction = new NfcCardSetAction();
        hxBleAction.setBaseAuthAction(mAuthion);
        hxBleAction.setSimulationData(etChangeMode.getText().toString());
        MyBleClient.getInstance(getActivity().getApplicationContext()).nfcCardSet(hxBleAction, new FunCallback<NfcCardSetResult>() {
            @Override
            public void onResponse(Response<NfcCardSetResult> response) {
                tvLog.setText("nfcCardSet" + response.toString() + "\n" + StatusCode.parse(response.code(), getContext()) + TimeUtils.getNowString());
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }

    private void cmdNfcCardReadNum(BlinkyAuthAction mAuthion) {
        BlinkyAction hxBleAction = new BlinkyAction();
        hxBleAction.setBaseAuthAction(mAuthion);
        MyBleClient.getInstance(getActivity().getApplicationContext()).nfcCardReadNum(hxBleAction, new FunCallback<NfcCardReadNumResult>() {
            @Override
            public void onResponse(Response<NfcCardReadNumResult> response) {
                tvLog.setText("cmdNfcCardReadNum" + response.toString() + "\n" + StatusCode.parse(response.code(), getContext()));
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }

    private void cmdNfcCardWrite(BlinkyAuthAction mAuthion) {
        SPUtils.getInstance().put("pwd", editTextTextPersonName3.getText().toString());


        NfcCardWriteAction hxBleAction = new NfcCardWriteAction();
        hxBleAction.setBaseAuthAction(mAuthion);
        hxBleAction.setCardData(editTextTextPersonName4.getText().toString());
        hxBleAction.setCardSector(Integer.parseInt(editTextTextPersonName.getText().toString()));
        hxBleAction.setPasswordType(Integer.parseInt(editTextTextPersonName2.getText().toString()));
        hxBleAction.setPassword(editTextTextPersonName3.getText().toString());

        MyBleClient.getInstance(getActivity().getApplicationContext()).nfcCardWrite(hxBleAction, new FunCallback() {
            @Override
            public void onResponse(Response response) {
                tvLog.setText("cmdNfcCardWrite" + response.toString() + "\n" + StatusCode.parse(response.code(), getContext()));
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }


    private void cmdNfcCardRead(BlinkyAuthAction mAuthion) {
        NfcCardReadAction hxBleAction = new NfcCardReadAction();
        hxBleAction.setBaseAuthAction(mAuthion);
        hxBleAction.setCardSector(Integer.parseInt(editTextTextPersonName.getText().toString()));
        hxBleAction.setPasswordType(Integer.parseInt(editTextTextPersonName2.getText().toString()));
        hxBleAction.setPassword(editTextTextPersonName3.getText().toString());


        MyBleClient.getInstance(getActivity().getApplicationContext()).nfcCardRead(hxBleAction, new FunCallback<NfcCardReadResult>() {
            @Override
            public void onResponse(Response<NfcCardReadResult> response) {
                tvLog.setText("cmdNfcCardRead" + response.toString() + "\n" + StatusCode.parse(response.code(), getContext()));
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }

    private void cmdSetAuthTime(BlinkyAuthAction mAuthion) {

        SetExpirationTimeAction hxBleAction = new SetExpirationTimeAction();
        hxBleAction.setBaseAuthAction(mAuthion);
        hxBleAction.setPromptDays(1);
        hxBleAction.setRemainingTime(10);

        MyBleClient.getInstance(getActivity().getApplicationContext()).setExpirationTime(hxBleAction, new FunCallback() {
            @Override
            public void onResponse(Response response) {
                Log.d(TAG, "onResponse() called with: response = [" + response + "]");
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }

    private void cmdGetAuthTime(BlinkyAuthAction mAuthion) {
        BlinkyAction hxBleAction = new BlinkyAction();
        hxBleAction.setBaseAuthAction(mAuthion);
        MyBleClient.getInstance(getActivity().getApplicationContext()).getExpirationTime(hxBleAction, new FunCallback<ExpirationTimeResult>() {
            @Override
            public void onResponse(Response<ExpirationTimeResult> response) {
                tvLog.setText("cmdGetKeyDetail" + response.toString() + "\n" + StatusCode.parse(response.code(), getContext()));
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }

    /**
     * Applicable to new version devices which bleProtocolVer>=0x16
     *
     * @param baseAuthAction
     */
    public void cmdGetKeyDetail(BlinkyAuthAction baseAuthAction) {
        OpenLockAction hxBleAction = new OpenLockAction();
        hxBleAction.setBaseAuthAction(baseAuthAction);
        MyBleClient.getInstance(getActivity().getApplicationContext()).getKeyDetail(hxBleAction, new FunCallback<LockKeyMessageResult>() {
            @Override
            public void onResponse(Response<LockKeyMessageResult> response) {
                tvLog.setText("cmdGetKeyDetail" + response.toString() + "\n" + StatusCode.parse(response.code(), getContext()));
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }

    public void cmdSetHeartbeat(BlinkyAuthAction baseAuthAction) {
        HeartbeatAction hxBleAction = new HeartbeatAction();
        hxBleAction.setBaseAuthAction(baseAuthAction);
        hxBleAction.setHeartbeatTime(1);
        MyBleClient.getInstance(getActivity().getApplicationContext()).setHeartbeat(hxBleAction, new FunCallback() {
            @Override
            public void onResponse(Response response) {
                tvLog.setText("cmdSetHeartbeat" + response.toString() + "\n" + StatusCode.parse(response.code(), getContext()));
            }

            @Override
            public void onFailure(Throwable t) {

            }
        });
    }

    private static final String TAG = "NewFeatureFragment";

    @Override
    public void onDestroy() {
        super.onDestroy();
        handler.removeCallbacks(runnable);
    }
}
